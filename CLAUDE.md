# SyncWatch — proje bağlamı (Claude Code devam dosyası)

Bu dosya, claude.ai'de yürütülen çalışmanın özetidir. Claude Code bunu okuyup
bağlamı yeniden kurabilir; kullanıcıya baştan anlattırma.

## Proje nedir

VSCode eklentisi. GDB (cppdbg) ile C programı debug edilirken durulduğunda,
kullanıcının KENDİ global yapıları üzerinden custom thread ve semaphore
listelerini gezip sekmeli bir Webview panelinde gösterir. pthread değil,
kullanıcının kendi TCB/semaphore struct'ları hedefleniyor (RTOS/scheduler tarzı).

Ne izleneceği tamamen `syncwatch.json`'dan gelir; eklenti struct'ları bilmez.

## Klasör yapısı

- `extension/`            : eklentinin KAYNAK projesi (derlenip paketlenir)
  - `src/extension.ts`    : tüm mantık
  - `package.json`, `tsconfig.json`, `.vscodeignore`, `LICENSE`, `README.md`
  - `syncwatch.json`      : örnek config (şema referansı)
- `dist/syncwatch-0.0.1.vsix` : son paketlenmiş eklenti
- `test-workspace/`      : Cygwin/Windows test ortamı
  - `threads_demo.c`     : standart kütüphane KULLANMAYAN örnek (no #include)
  - `syncwatch.json`     : karmaşık root örneğiyle config
  - `.vscode/`           : cppdbg launch + build task + eklenti önerisi
  - `install-cygwin-gcc.bat/.ps1` : gcc-core + gdb'yi makineye kurar
  - `KURULUM.md`

## Mimari / alınan önemli kararlar

1. DAP tracker (`registerDebugAdapterTrackerFactory`, tip `cppdbg`) ile
   `stopped`/`continued` event'leri dinlenir. `stopped`'ta panel yenilenir.
2. GDB'ye komut: `session.customRequest('evaluate', { expression: '-exec <cmd>',
   context: 'repl', frameId })`. frameId, durmuş thread'in üst frame'inden alınır.
3. Traversal CONFIG-DRIVEN ve generic (`collectSection`):
   - `linked_list`: cursor GDB convenience variable'ında tutulur ($swt / $sws),
     `next` NULL olana kadar gezilir. Alanlar `cursor->expr`.
   - `array`: `count` kadar, alanlar `(root)[i]<access>expr` (access default ".").
   - `root` herhangi bir C ifadesi olabilir; KARMAŞIK root destekleniyor ve
     test edildi: `g_kernel.pools[0]->thread_list`.
4. `cleanValue()`: GDB çıktısından `$N =` önekini ve `(gdb)` prompt gürültüsünü
   temizler. (Bir bug burada bulunup düzeltildi: bazı adapter yolları "(gdb) "
   ekleyebiliyor; regex ona göre sağlamlaştırıldı.)
5. `isNull()`: `\b0x0\b` ile NULL pointer tespiti (geçerli adresleri yakalamaz).
6. Sadece global OKUNUR; fonksiyon çağrılmaz → debuggee'nin durumu bozulmaz.
   (Semaphore değeri için sem_getvalue çağırma fikri bilinçli olarak EKLENMEDİ.)
7. İki bölüm + sekmeli Webview:
   - threads: ID, Name, State, Priority, Stack Start (stack_base), Stack Size.
     State → renkli badge (RUNNING/READY/BLOCKED/WAITING).
   - semaphores: ID, Count, Max, Waiting, Discipline. Discipline → badge,
     Count==0 → kırmızı, Waiting>0 → sarı. Üstte özet satırı.
   - Webview tema değişkenleri (var(--vscode-...)) kullanır; CSP + nonce var.
8. Test örneği standart kütüphane kullanmaz: `#include` yok, printf yerine
   `inspect_point` içinde `volatile` global'e yazılır (breakpoint anchor).
   NOT: kaynak stdlib'siz olsa da exe, `main` için varsayılan C runtime
   başlangıç kodundan dolayı yine msvcrt/cygwin1.dll import eder. Tamamen
   runtime'sız binary istenirse `-nostdlib -nostartfiles -e <entry>` + ExitProcess.

## Build / paketleme

    cd extension
    npm install
    npm run compile        # tsc -> out/extension.js
    npx vsce package       # syncwatch-0.0.1.vsix üretir
    # geliştirme: extension/ klasörünü VSCode'da aç, F5 (Extension Dev Host)

## Test etme

`test-workspace/` klasörünü ayrı bir VSCode penceresinde aç:
1. `install-cygwin-gcc.bat` ile gcc + gdb kur (Windows) — ya da sistemdeki
   MinGW/MSYS2 yollarını `.vscode` içinde göster.
2. `dist/syncwatch-0.0.1.vsix`'i kur (Install from VSIX).
3. F5 → `inspect_point`'te dur → "SyncWatch: Paneli Aç".

## Doğrulanan durum (gerçek GDB 15.1 ile, claude.ai oturumunda)

- TypeScript hatasız derlendi, vsix paketlendi.
- Linked_list (karmaşık root dahil) + array + semaphore traversal, eklentinin
  gönderdiği komut dizisinin AYNISIYLA gerçek binary'de doğrulandı.
- E2E (Node'dan gerçek gdb sürülerek collectSection ile): 10/10 PASS
  (4 thread + stack start/size, 3 semaphore + count/max/waiting/discipline).
- Parse/badge birim testleri: 14/14 PASS.
- Henüz MANUEL kalan: VSCode UI (panel render, tracker tetiklemesi) F5 ile —
  bu container'da GUI çalıştırılamadığı için test edilemedi.

## Olası sonraki adımlar

- Mutex için üçüncü bir bölüm (pthread_mutex __data.__owner vb. veya custom).
- array modunda pointer dizileri için `access: "->"` örneği.
- Windows'ta MinGW (WinLibs/MSYS2) varyantı için `.vscode` yolları.
- Freestanding (-nostdlib) test binary varyantı.
- cppdbg `evaluate` çıktı formatı sürüme göre değişirse `cleanValue`'da ayar.

## Bilinmesi gereken kısıt

Bu paketin içinde gcc.exe/gdb.exe YOK. Önceki ortamdan derleyici binary'leri
indirilemedi (ağ kısıtı). Toolchain, `install-cygwin-gcc.bat` ile kullanıcının
makinesine kurulur. (Alternatif: `zig cc` — clang tabanlı, gdb'siz.)
