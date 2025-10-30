param(
    [string]$ReadmePath = (Join-Path $PSScriptRoot '..\README.md')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-GitOutput([string]$args) {
    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = 'git'
        $pinfo.Arguments = $args
        $pinfo.RedirectStandardOutput = $true
        $pinfo.RedirectStandardError = $true
        $pinfo.UseShellExecute = $false
        $pinfo.CreateNoWindow = $true
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        [void]$p.Start()
        $out = $p.StandardOutput.ReadToEnd()
        $err = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        if ($p.ExitCode -ne 0) { return $null }
        return $out.Trim()
    } catch { return $null }
}

function Get-GitHubSlugFromOrigin([string]$url) {
    if (-not $url) { return $null }
    $m = [regex]::Match($url, 'github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?$')
    if ($m.Success) { return "$($m.Groups[1].Value)/$($m.Groups[2].Value)" }
    return $null
}

if (-not (Test-Path -LiteralPath $ReadmePath)) { Write-Host "README not found: $ReadmePath"; exit 0 }

$inRepo = Get-GitOutput 'rev-parse --is-inside-work-tree'
if ($inRepo -ne 'true') { Write-Host 'Not a git repository. Skipping badge update.'; exit 0 }

$origin = Get-GitOutput 'remote get-url origin'
if (-not $origin) { Write-Host 'No git remote "origin" found. Skipping badge update.'; exit 0 }

$slug = Get-GitHubSlugFromOrigin $origin
if (-not $slug) { Write-Host 'Origin is not a GitHub URL. Skipping badge update.'; exit 0 }

# Try to get current branch; fallback to main
$branch = Get-GitOutput 'symbolic-ref --short HEAD'
if (-not $branch) { $branch = 'main' }

$content = Get-Content -LiteralPath $ReadmePath -Raw
$new = $content
$new = $new -replace 'OWNER/REPO', [regex]::Escape($slug).Replace('\/','/')
$new = $new -replace 'branch=main', ('branch=' + [regex]::Escape($branch))

if ($new -ne $content) {
    Set-Content -LiteralPath $ReadmePath -Value $new -Encoding UTF8
    Write-Host "README badge updated to $slug (branch=$branch)."
} else {
    Write-Host 'README badge already up to date or placeholder not found.'
}

