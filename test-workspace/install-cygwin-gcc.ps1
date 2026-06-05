$ErrorActionPreference = 'Stop'
$root   = 'C:\cygwin64'
$gcc    = Join-Path $root 'bin\gcc.exe'
$mirror = 'https://mirrors.kernel.org/sourceware/cygwin/'

if (Test-Path $gcc) {
  Write-Host "Cygwin gcc zaten kurulu: $gcc"
  & $gcc --version | Select-Object -First 1
  exit 0
}

$setup = Join-Path $env:TEMP 'cygwin-setup-x86_64.exe'
Write-Host "Cygwin setup indiriliyor..."
Invoke-WebRequest -Uri 'https://www.cygwin.com/setup-x86_64.exe' -OutFile $setup -UseBasicParsing

Write-Host "gcc-core + gdb kuruluyor ($root) ..."
$cache = Join-Path $root 'var\cache\setup'
$args = @('-q','-n','-d','-N',
          '-P','gcc-core,gdb',
          '-s', $mirror,
          '-R', $root,
          '-l', $cache)
Start-Process -FilePath $setup -ArgumentList $args -Wait

if (Test-Path $gcc) {
  Write-Host "`nOK -> $gcc"
  & $gcc --version | Select-Object -First 1
  if (Test-Path (Join-Path $root 'bin\gdb.exe')) { Write-Host "gdb.exe mevcut." }
  else { Write-Host "UYARI: gdb.exe yok; setup'i tekrar calistirip 'gdb' paketini sec." }
} else {
  throw "Kurulum sonrasi gcc.exe bulunamadi: $gcc"
}
