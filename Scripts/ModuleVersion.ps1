Set-StrictMode -Version Latest

function Get-LoggerReleaseVersionPattern {
    [CmdletBinding()]
    param()

    return '^(?<base>\d+\.\d+\.\d+)(?:-(?<prerelease>[0-9A-Za-z][0-9A-Za-z\.-]*))?$'
}

function Get-LoggerReleaseVersionInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ManifestPath
    )

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        throw "Manifest not found: $ManifestPath"
    }

    $manifest = Import-PowerShellDataFile -LiteralPath $ManifestPath
    $moduleVersion = [string]$manifest.ModuleVersion
    if ([string]::IsNullOrWhiteSpace($moduleVersion)) {
        throw 'ModuleVersion missing in manifest.'
    }

    $pattern = Get-LoggerReleaseVersionPattern
    if ($moduleVersion -notmatch '^\d+\.\d+\.\d+$') {
        throw "ModuleVersion '$moduleVersion' must use a stable SemVer numeric format such as X.Y.Z."
    }

    $prerelease = $null
    if ($manifest.ContainsKey('PrivateData') -and $null -ne $manifest.PrivateData) {
        $privateData = $manifest.PrivateData
        if ($privateData.ContainsKey('PSData')) {
            $psData = $privateData['PSData']
            if ($null -ne $psData -and $psData.ContainsKey('Prerelease')) {
                $rawPrerelease = [string]$psData['Prerelease']
                if (-not [string]::IsNullOrWhiteSpace($rawPrerelease)) {
                    $prerelease = $rawPrerelease.Trim()
                }
            }
        }

        if ($null -eq $prerelease -and $privateData.ContainsKey('Prerelease')) {
            $rawPrerelease = [string]$privateData['Prerelease']
            if (-not [string]::IsNullOrWhiteSpace($rawPrerelease)) {
                $prerelease = $rawPrerelease.Trim()
            }
        }
    }

    if ($prerelease -and $prerelease -notmatch '^[0-9A-Za-z][0-9A-Za-z\.-]*$') {
        throw "Prerelease '$prerelease' contains unsupported characters."
    }

    $effectiveVersion = if ($prerelease) {
        '{0}-{1}' -f $moduleVersion, $prerelease
    } else {
        $moduleVersion
    }

    if ($effectiveVersion -notmatch $pattern) {
        throw "Effective version '$effectiveVersion' does not match the supported release format."
    }

    return [pscustomobject]@{
        ManifestPath = (Resolve-Path -LiteralPath $ManifestPath).Path
        ModuleVersion = $moduleVersion
        Prerelease = $prerelease
        EffectiveVersion = $effectiveVersion
        TagName = "v$effectiveVersion"
        IsPrerelease = ($null -ne $prerelease)
    }
}

function Get-LoggerTagVersionInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$TagName
    )

    if ([string]::IsNullOrWhiteSpace($TagName)) {
        throw 'TagName is required.'
    }

    $tagVersion = $TagName.Trim()
    if ($tagVersion.StartsWith('v', [System.StringComparison]::OrdinalIgnoreCase)) {
        $tagVersion = $tagVersion.Substring(1)
    }

    $pattern = Get-LoggerReleaseVersionPattern
    if ($tagVersion -notmatch $pattern) {
        throw "Tag '$TagName' must use a format like vX.Y.Z or vX.Y.Z-alpha1."
    }

    $prerelease = if ($Matches.ContainsKey('prerelease') -and $Matches['prerelease']) {
        $Matches['prerelease']
    } else {
        $null
    }

    return [pscustomobject]@{
        TagName = $TagName
        EffectiveVersion = $tagVersion
        ModuleVersion = $Matches['base']
        Prerelease = $prerelease
        IsPrerelease = ($null -ne $prerelease)
    }
}

function Test-LoggerTagMatchesManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ManifestPath,
        [Parameter(Mandatory)][string]$TagName
    )

    $releaseInfo = Get-LoggerReleaseVersionInfo -ManifestPath $ManifestPath
    $tagInfo = Get-LoggerTagVersionInfo -TagName $TagName

    return $releaseInfo.EffectiveVersion -eq $tagInfo.EffectiveVersion
}
