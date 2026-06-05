# SyncWatch test ortami (Windows / Cygwin)

gcc.exe burada GOMULU DEGIL: bu ortamdan indirilemedigi icin, asagidaki adim
Cygwin'in resmi setup'ini SENIN makinende calistirip gcc-core + gdb kurar.
Uygulamayi sen derlersin (build task); hazir exe gelmez.

## Adimlar

1. `install-cygwin-gcc.bat` -> cift tikla.
   Cygwin setup'ini indirir ve `C:\cygwin64` altina `gcc-core` + `gdb` kurar.
   (Tek seferlik. Yonetici izni isteyebilir.)
   Sonunda `C:\cygwin64\bin\gcc.exe` ve `gdb.exe` olusur.

2. Bu klasoru VSCode'da ac. "ms-vscode.cpptools" eklentisini kur.

3. SyncWatch eklentisini kur:
   Extensions > "..." > Install from VSIX > syncwatch-0.0.1.vsix

4. F5 (GDB (Cygwin): threads_demo.exe). preLaunchTask
   `C:\cygwin64\bin\gcc.exe -g -O0` ile threads_demo.exe uretir.

5. inspect_point'te durunca: Komut Paleti > "SyncWatch: Paneli Ac".

## Notlar

- Cygwin gcc ile uretilen exe `cygwin1.dll`'e bagimlidir; launch.json PATH'e
  `C:\cygwin64\bin` ekledigi icin debug sirasinda bulunur.
- Cygwin yolun farkliysa (`C:\cygwin\...` vb.) tasks.json + launch.json
  icindeki yollari guncelle.
- cppdbg ile en sorunsuz GDB deneyimi MinGW (WinLibs/MSYS2) tarafindadir;
  Cygwin gdb calisir ama bazen /cygdrive yol cevriminden kaynakli ufak
  takiliklar olabilir.

## Dosyalar
- threads_demo.c              : custom thread + semaphore yapilari
- syncwatch.json             : ne izlenecek (karmasik root ornegi dahil)
- install-cygwin-gcc.bat/.ps1: Cygwin gcc-core + gdb kurar
- .vscode\                   : cppdbg launch + build task
- syncwatch-0.0.1.vsix        : SyncWatch eklentisi
