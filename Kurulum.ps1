$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms

function Show-Info([string]$Message) {
    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        'Metin Sağ Tık Araçları',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function Show-Error([string]$Message) {
    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        'Metin Sağ Tık Araçları - Kurulum Hatası',
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

function Add-Candidate([System.Collections.Generic.List[string]]$List, [string]$Path) {
    if (-not $Path) { return }
    $clean = $Path.Trim().Trim('"')
    if ($clean.ToLower().EndsWith('pythonw.exe')) {
        $clean = Join-Path (Split-Path $clean -Parent) 'python.exe'
    }
    if ($clean -like '*\WindowsApps\*') { return }
    if ((Test-Path $clean) -and -not $List.Contains($clean)) {
        $List.Add($clean)
    }
}

function Get-PythonCandidates {
    $items = New-Object 'System.Collections.Generic.List[string]'

    try {
        $launcher = Get-Command py.exe -ErrorAction SilentlyContinue
        if ($launcher) {
            & $launcher.Source -0p 2>$null | ForEach-Object {
                if ($_ -match '([A-Za-z]:\.*python(?:w)?\.exe)\s*$') {
                    Add-Candidate $items $Matches[1]
                }
            }
        }
    } catch {}

    foreach ($registryRoot in @(
        'HKCU:\Software\Python\PythonCore',
        'HKLM:\Software\Python\PythonCore',
        'HKLM:\Software\WOW6432Node\Python\PythonCore'
    )) {
        if (-not (Test-Path $registryRoot)) { continue }
        try {
            Get-ChildItem $registryRoot -ErrorAction SilentlyContinue | ForEach-Object {
                $installKey = Join-Path $_.PSPath 'InstallPath'
                if (Test-Path $installKey) {
                    $folder = (Get-Item $installKey).GetValue('')
                    if ($folder) { Add-Candidate $items (Join-Path $folder 'python.exe') }
                }
            }
        } catch {}
    }

    try {
        Get-Command python.exe -All -ErrorAction SilentlyContinue | ForEach-Object {
            Add-Candidate $items $_.Source
        }
    } catch {}

    return @($items)
}

function Find-Python([string[]]$Candidates, [string]$Imports) {
    foreach ($candidate in $Candidates) {
        try {
            & $candidate -c $Imports *> $null
            if ($LASTEXITCODE -eq 0) { return $candidate }
        } catch {}
    }
    return $null
}

function Get-Pythonw([string]$PythonExe) {
    $pythonw = Join-Path (Split-Path $PythonExe -Parent) 'pythonw.exe'
    if (-not (Test-Path $pythonw)) {
        throw "pythonw.exe bulunamadı: $pythonw"
    }
    return $pythonw
}

function Remove-Key([string]$SubKey) {
    try {
        [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($SubKey, $false)
    } catch {}
}

function Remove-OldMenus {
    $extensions = @('.jpg', '.jpeg', '.png')
    $imageIds = @(
        'MetinWebPrepare', 'MetinImagesToPdf', 'MetinMetadataClean',
        'MetinAvifKeep', 'MetinAvifDelete', 'MetinAvif'
    )
    foreach ($ext in $extensions) {
        foreach ($id in $imageIds) {
            Remove-Key "Software\Classes\SystemFileAssociations\$ext\shell\$id"
        }
    }

    foreach ($id in @(
        'MetinPdfLabel', 'MetinPdfToJpg', 'MetinPdfCompressHigh',
        'MetinPdfCompressEmail', 'MetinPdfEtiket'
    )) {
        Remove-Key "Software\Classes\SystemFileAssociations\.pdf\shell\$id"
    }

    foreach ($id in @('MetinCopyName', 'MetinCopyStem', 'MetinDatedCopy', 'MetinSha256', 'MetinToolbox')) {
        Remove-Key "Software\Classes\*\shell\$id"
    }

    foreach ($id in @(
        'MetinToolbox', 'MetinPdfEtiket', 'MetinAvif', 'MetinFolderCopyName',
        'MetinFolderList', 'MetinFolderListRecursive', 'MetinFolderDatedCopy',
        'MetinProjectBackup', 'MetinFolderWebPrepare', 'MetinFolderImagesToPdf',
        'MetinFolderMetadataClean', 'MetinFolderAvifKeep', 'MetinFolderAvifDelete',
        'MetinFolderPdfLabel'
    )) {
        Remove-Key "Software\Classes\Directory\shell\$id"
    }

    Remove-Key 'Software\Classes\Directory\Background\shell\MetinToolbox'
    Remove-Item (Join-Path $env:APPDATA 'Microsoft\Windows\SendTo\Metin Araç Kutusu.lnk') -Force -ErrorAction SilentlyContinue
}

function Set-Menu(
    [string]$BaseKey,
    [string]$Id,
    [string]$Label,
    [string]$Command,
    [string]$Icon,
    [string]$MultiSelectModel
) {
    $subKey = "$BaseKey\shell\$Id"
    Remove-Key $subKey
    $verb = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($subKey)
    try {
        $verb.SetValue('', $Label, [Microsoft.Win32.RegistryValueKind]::String)
        $verb.SetValue('Icon', $Icon, [Microsoft.Win32.RegistryValueKind]::String)
        $verb.SetValue('Position', 'Top', [Microsoft.Win32.RegistryValueKind]::String)
        $verb.SetValue('MultiSelectModel', $MultiSelectModel, [Microsoft.Win32.RegistryValueKind]::String)
        $commandKey = $verb.CreateSubKey('command')
        try {
            $commandKey.SetValue('', $Command, [Microsoft.Win32.RegistryValueKind]::String)
        } finally {
            $commandKey.Dispose()
        }
    } finally {
        $verb.Dispose()
    }
}

try {
    Remove-OldMenus

    $sourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $required = @(
        'pdf_core.py', 'avif_core.py', 'Pdf_Etiket_SagTik.pyw',
        'AVIF_SagTik.pyw', 'Gorsellerden_PDF.pyw'
    )
    foreach ($name in $required) {
        if (-not (Test-Path (Join-Path $sourceDir $name))) {
            throw "Kurulum dosyası eksik: $name`n`nZIP dosyasının tamamını aynı klasöre çıkarın."
        }
    }

    $candidates = @(Get-PythonCandidates)
    if ($candidates.Count -eq 0) {
        throw 'Python bulunamadı.'
    }

    $labelPython = Find-Python $candidates 'import tkinter, cv2, numpy, pytesseract, fitz'
    $imagePython = Find-Python $candidates "import tkinter; from PIL import Image; import pillow_avif"

    if (-not $labelPython) {
        throw "PDF etiket aracı için gerekli modülleri içeren Python bulunamadı.`n`nGerekli: opencv-python, numpy, pytesseract, PyMuPDF"
    }
    if (-not $imagePython) {
        throw "AVIF/PDF aracı için gerekli modülleri içeren Python bulunamadı.`n`nGerekli: Pillow, pillow-avif-plugin"
    }

    $labelPythonw = Get-Pythonw $labelPython
    $imagePythonw = Get-Pythonw $imagePython

    $installDir = Join-Path $env:LOCALAPPDATA 'MetinBasitSagTik'
    New-Item -Path $installDir -ItemType Directory -Force | Out-Null
    foreach ($name in $required) {
        Copy-Item (Join-Path $sourceDir $name) (Join-Path $installDir $name) -Force
    }

    $pdfScript = Join-Path $installDir 'Pdf_Etiket_SagTik.pyw'
    $avifScript = Join-Path $installDir 'AVIF_SagTik.pyw'
    $imagesPdfScript = Join-Path $installDir 'Gorsellerden_PDF.pyw'

    $pdfCommand = '"{0}" "{1}" "%1"' -f $labelPythonw, $pdfScript
    $avifFilesCommand = '"{0}" "{1}" %*' -f $imagePythonw, $avifScript
    $avifFolderCommand = '"{0}" "{1}" "%1"' -f $imagePythonw, $avifScript
    $imagesPdfCommand = '"{0}" "{1}" %*' -f $imagePythonw, $imagesPdfScript

    $labelIcon = '"{0}",0' -f $labelPythonw
    $imageIcon = '"{0}",0' -f $imagePythonw

    Set-Menu 'Software\Classes\SystemFileAssociations\.pdf' 'MetinPdfEtiket' `
        'Etiketleri oku ve resimleri döndür' $pdfCommand $labelIcon 'Single'

    foreach ($ext in @('.jpg', '.jpeg', '.png')) {
        $base = "Software\Classes\SystemFileAssociations\$ext"
        Set-Menu $base 'MetinAvif' "AVIF'e dönüştür (orijinali sil)" $avifFilesCommand $imageIcon 'Player'
        Set-Menu $base 'MetinImagesToPdf' 'Seçili görsellerden tek PDF oluştur' $imagesPdfCommand $imageIcon 'Player'
    }

    Set-Menu 'Software\Classes\Directory' 'MetinAvif' `
        "Klasördeki görselleri AVIF'e dönüştür (orijinalleri sil)" `
        $avifFolderCommand $imageIcon 'Single'

    Remove-Item (Join-Path $env:LOCALAPPDATA 'MetinToolsV4') -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item (Join-Path $env:LOCALAPPDATA 'MetinTools') -Recurse -Force -ErrorAction SilentlyContinue

    Show-Info "Kurulum tamamlandı.`n`nYalnızca şu araçlar kuruldu:`n`n- PDF: Etiketleri oku ve resimleri döndür`n- Görsel: AVIF'e dönüştür (orijinali sil)`n- Klasör: İçindeki görselleri AVIF'e dönüştür`n- Seçili görseller: Tek PDF oluştur`n`nGönder menüsüne hiçbir şey eklenmedi.`nBaşka dosya veya klasör aracı kurulmadı.`n`nMenüler görünmezse Windows Gezgini'ni yeniden başlatın."
}
catch {
    Show-Error $_.Exception.Message
    exit 1
}
