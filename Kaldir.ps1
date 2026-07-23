$ErrorActionPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms

function Remove-Key([string]$SubKey) {
    try { [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($SubKey, $false) } catch {}
}

foreach ($ext in @('.jpg', '.jpeg', '.png')) {
    Remove-Key "Software\Classes\SystemFileAssociations\$ext\shell\MetinAvif"
    Remove-Key "Software\Classes\SystemFileAssociations\$ext\shell\MetinImagesToPdf"
}
Remove-Key 'Software\Classes\SystemFileAssociations\.pdf\shell\MetinPdfEtiket'
Remove-Key 'Software\Classes\Directory\shell\MetinAvif'
Remove-Item (Join-Path $env:LOCALAPPDATA 'MetinBasitSagTik') -Recurse -Force

[System.Windows.Forms.MessageBox]::Show(
    'Kurulan dört sağ tık aracı kaldırıldı.',
    'Metin Sağ Tık Araçları',
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
) | Out-Null
