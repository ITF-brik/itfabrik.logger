$ErrorActionPreference = 'Stop'

Describe 'File Sink (formats, rotation, encodings)' {
    BeforeAll {
        $modulePath = Join-Path $PSScriptRoot '..\ITFabrik.Logger.psd1'
        Import-Module $modulePath -Force
    }

    It 'writes CMTrace XML-like line' {
        InModuleScope 'ITFabrik.Logger' {
            $file = Join-Path $env:TEMP ("cmtrace_{0}.log" -f ([guid]::NewGuid().ToString('N')))
            Invoke-FileSink -Options @{ Path = $file; Format = 'Cmtrace'; Rotation = 'Size'; MaxSizeMB = 10; MaxRolls = 2; Encoding = 'UTF8BOM' } -Component 'Comp' -Message 'Msg' -Severity 'Info' -IndentLevel 0
            $text = Get-Content -LiteralPath $file -Raw
            $text | Should -Match '<!\[LOG\[Msg\]LOG\]!><time="\d{2}:\d{2}:\d{2}\.\d{6}" date="\d{1,2}-\d{1,2}-\d{4}" component="Comp" context=".+" type="1" thread="\d+" file="">'
            Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
        }
    }

    It 'applies Daily rotation naming with .log extension' {
        InModuleScope 'ITFabrik.Logger' {
            $base = Join-Path $env:TEMP ("daily_{0}.log" -f ([guid]::NewGuid().ToString('N')))
            Invoke-FileSink -Options @{ Path = $base; Format = 'Default'; Rotation = 'Daily'; MaxSizeMB = 10; MaxRolls = 2; Encoding = 'UTF8BOM' } -Component 'C' -Message 'M' -Severity 'Info' -IndentLevel 0
            $date = Get-Date -Format 'yyyy-MM-dd'
            $expected = Join-Path (Split-Path -Parent $base) ("{0}.{1}.log" -f ([System.IO.Path]::GetFileNameWithoutExtension((Split-Path -Leaf $base))), $date)
            Test-Path -LiteralPath $expected | Should -BeTrue
            Remove-Item -LiteralPath $expected -Force -ErrorAction SilentlyContinue
        }
    }

    It 'supports all declared encodings' {
        InModuleScope 'ITFabrik.Logger' {
            $encs = 'UTF8','UTF8BOM','ASCII','Unicode','UTF7','UTF32','Default','OEM'
            foreach ($e in $encs) {
                $file = Join-Path $env:TEMP ("enc_{0}_{1}.log" -f $e,([guid]::NewGuid().ToString('N')))
                Invoke-FileSink -Options @{ Path = $file; Format = 'Default'; Rotation = 'Size'; MaxSizeMB = 10; MaxRolls = 2; Encoding = $e } -Component 'E' -Message "Hello-$e" -Severity 'Verbose' -IndentLevel 1
                Test-Path -LiteralPath $file | Should -BeTrue
                (Get-Item -LiteralPath $file).Length | Should -BeGreaterThan 0
                Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

