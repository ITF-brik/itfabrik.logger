function Invoke-FileSink {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Options,
        [Parameter(Mandatory)][string]$Component,
        [Parameter(Mandatory)][string]$Message,
        [Parameter(Mandatory)][ValidateSet('Info','Success','Warning','Error','Debug','Verbose')][string]$Severity,
        [int]$IndentLevel = 0
    )

    $path = $Options.Path
    if (-not $path) { return }
    $format   = ($Options.Format   | ForEach-Object { $_ }) -as [string]; if (-not $format) { $format = 'Default' }
    $rotation = ($Options.Rotation | ForEach-Object { $_ }) -as [string]
    $maxSizeMB = [double]($(if ($Options.ContainsKey('MaxSizeMB')) { $Options.MaxSizeMB } else { 5 }))
    $maxRolls  = [int]  ($(if ($Options.ContainsKey('MaxRolls'))  { $Options.MaxRolls }  else { 3 }))
    $encoding  = $(if ($Options.ContainsKey('Encoding')) { $Options.Encoding } else { 'UTF8BOM' })

    $effectivePath = $path
    if ($rotation -match 'Daily') {
        $dir = Split-Path -Parent $path
        $leaf = Split-Path -Leaf $path
        $date = Get-Date -Format 'yyyy-MM-dd'
        if ($leaf -match '\.log$') {
            $base = [System.IO.Path]::GetFileNameWithoutExtension($leaf)
            $ext  = [System.IO.Path]::GetExtension($leaf)
            $effectivePath = Join-Path $dir ("{0}.{1}{2}" -f $base,$date,$ext)
        } else {
            $effectivePath = Join-Path $dir ("{0}.{1}" -f $leaf,$date)
        }
    }

    $dirToEnsure = Split-Path -Parent $effectivePath
    if ($dirToEnsure -and -not (Test-Path -LiteralPath $dirToEnsure)) { New-Item -ItemType Directory -Path $dirToEnsure -Force | Out-Null }

    # Rotation mode: NewFile -> archive existing file once per session before first write
    if ($rotation -match 'NewFile') {
        if (-not $script:FileSinkInitialized) { $script:FileSinkInitialized = @{} }
        $initKey = "newfile::" + $effectivePath
        if (-not $script:FileSinkInitialized.ContainsKey($initKey)) {
            try {
                if (Test-Path -LiteralPath $effectivePath) {
                    $dir = Split-Path -Parent $effectivePath
                    $base = Split-Path -Leaf $effectivePath
                    for ($i = $maxRolls; $i -ge 1; $i--) {
                        $dstLeaf = "$base.$i"
                        $dst = Join-Path $dir $dstLeaf
                        if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue }
                        if ($i -eq 1) {
                            if (Test-Path -LiteralPath $effectivePath) { Rename-Item -LiteralPath $effectivePath -NewName $dstLeaf -Force -ErrorAction SilentlyContinue }
                        } else {
                            $srcLeaf = "$base.$($i-1)"
                            $src = Join-Path $dir $srcLeaf
                            if (Test-Path -LiteralPath $src) { Rename-Item -LiteralPath $src -NewName $dstLeaf -Force -ErrorAction SilentlyContinue }
                        }
                    }
                }
            } catch { }
            $script:FileSinkInitialized[$initKey] = $true
        }
    }

    if ($rotation -match 'Size') {
        try {
            if (Test-Path -LiteralPath $effectivePath) {
                $lenBytes = (Get-Item -LiteralPath $effectivePath).Length
                $lenMB = $lenBytes / 1MB
                if ($lenMB -ge $maxSizeMB) {
                    $dir = Split-Path -Parent $effectivePath
                    $base = Split-Path -Leaf $effectivePath
                    for ($i = $maxRolls; $i -ge 1; $i--) {
                        $dstLeaf = "$base.$i"
                        $dst = Join-Path $dir $dstLeaf
                        if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue }
                        if ($i -eq 1) {
                            if (Test-Path -LiteralPath $effectivePath) { Rename-Item -LiteralPath $effectivePath -NewName $dstLeaf -Force -ErrorAction SilentlyContinue }
                        } else {
                            $srcLeaf = "$base.$($i-1)"
                            $src = Join-Path $dir $srcLeaf
                            if (Test-Path -LiteralPath $src) { Rename-Item -LiteralPath $src -NewName $dstLeaf -Force -ErrorAction SilentlyContinue }
                        }
                    }
                }
            }
        } catch { }
    }

    $indent = if ($IndentLevel -gt 0) { ' ' * ($IndentLevel * 2) } else { '' }
    $now = Get-Date

    switch -Regex ($format) {
        '^cmtrace$' {
            $ts = $now.ToString('MM-dd-yyyy HH:mm:ss.fff')
            $line = Format-LoggerLineCmtrace -Timestamp $ts -Severity $Severity -Component $Component -Message $Message -IndentLevel $IndentLevel
        }
        default {
            $ts = $now.ToString('yyyy-MM-dd HH:mm:ss')
            $line = Format-LoggerLineDefault -Timestamp $ts -Severity $Severity -Component $Component -Message $Message -IndentLevel $IndentLevel
        }
    }

    try {
        $encObj = switch -Regex ($encoding) {
            '^UTF8$'      { New-Object System.Text.UTF8Encoding($false); break }
            '^UTF8BOM$'   { New-Object System.Text.UTF8Encoding($true); break }
            '^ASCII$'     { [System.Text.Encoding]::ASCII; break }
            '^Unicode$'   { [System.Text.Encoding]::Unicode; break }
            '^UTF7$'      { [System.Text.Encoding]::UTF7; break }
            '^UTF32$'     { [System.Text.Encoding]::UTF32; break }
            '^Default$'   { [System.Text.Encoding]::Default; break }
            '^OEM$'       { [System.Text.Encoding]::GetEncoding([System.Console]::OutputEncoding.CodePage); break }
            default       { New-Object System.Text.UTF8Encoding($false) }
        }
        if (-not $script:FileSinkInitialized) { $script:FileSinkInitialized = @{} }
        $firstWrite = $false
        if (-not $rotation) {
            if (-not $script:FileSinkInitialized.ContainsKey($effectivePath)) {
                $script:FileSinkInitialized[$effectivePath] = $true
                $firstWrite = $true
            }
        }

        if ($firstWrite) {
            [System.IO.File]::WriteAllText($effectivePath, $line + [Environment]::NewLine, $encObj)
        } else {
            [System.IO.File]::AppendAllText($effectivePath, $line + [Environment]::NewLine, $encObj)
        }
    } catch { }
}
