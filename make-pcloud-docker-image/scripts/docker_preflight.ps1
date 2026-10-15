[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string]$Distro = "Ubuntu-24.04"
)

$ErrorActionPreference = "Stop"
$project = (Resolve-Path -LiteralPath $ProjectPath).Path

if (-not (Test-Path -LiteralPath (Join-Path $project "Dockerfile") -PathType Leaf)) {
    throw "Dockerfile not found in: $project"
}

$dockerIgnore = Join-Path $project ".dockerignore"
if (-not (Test-Path -LiteralPath $dockerIgnore -PathType Leaf)) {
    Write-Warning ".dockerignore is missing"
} else {
    $ignoreText = Get-Content -Raw -LiteralPath $dockerIgnore
    foreach ($requiredPattern in @(".env", ".git", ".venv", "*.db")) {
        if ($ignoreText -notmatch [regex]::Escape($requiredPattern)) {
            Write-Warning ".dockerignore does not mention $requiredPattern"
        }
    }
}

$registered = Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" |
    ForEach-Object { (Get-ItemProperty $_.PSPath).DistributionName }
if ($registered -notcontains $Distro) {
    throw "WSL distribution is not registered: $Distro"
}

$previousLocation = Get-Location
try {
    Set-Location "$env:SystemDrive\"
    $probe = & wsl.exe -d $Distro -u root -- docker info --format '{{.ServerVersion}}|{{.OSType}}|{{.Architecture}}|{{.Driver}}' 2>&1
    $probeExit = $LASTEXITCODE
} finally {
    Set-Location $previousLocation
}

if ($probeExit -ne 0) {
    $detail = ($probe | Out-String).Trim()
    if (-not $detail) {
        $detail = "no diagnostic output"
    }
    throw "WSL Docker daemon check failed (exit=$probeExit): $detail. If exit is -1, inspect the WSL relay before retrying a build."
}

$parts = (($probe | Out-String).Trim()) -split '\|'
if ($parts.Count -lt 4) {
    throw "Unexpected docker info output: $probe"
}

[pscustomobject]@{
    ProjectPath   = $project
    Distro        = $Distro
    DockerServer  = $parts[0]
    OS            = $parts[1]
    Architecture  = $parts[2]
    StorageDriver = $parts[3]
    Ready         = ($parts[1] -eq "linux" -and $parts[2] -eq "x86_64")
} | Format-List
