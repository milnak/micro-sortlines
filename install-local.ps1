param (
    [String]$MicroPlugPath = "~/.config/micro/plug",
    [switch]$Force
)

$InstallPath = Join-Path -Path (Resolve-Path -LiteralPath $MicroPlugPath -ErrorAction Stop) -ChildPath 'sortlines' -ErrorAction Stop
if (Test-Path -LiteralPath $InstallPath) {
    if (-not $Force) {
        Write-Host -ForegroundColor Yellow "Already installed at '$InstallPath'"
        Write-Host 'Specify -Force to reinstall/update.'
        exit 1
    }

    Remove-Item -Recurse -LiteralPath $InstallPath -ErrorAction Stop
}

Write-Host "Installing to '$InstallPath'"

mkdir $InstallPath -ErrorAction Stop | Out-Null

Copy-Item -Recurse -Path '*' -Destination $InstallPath -Exclude 'install-local.ps1' -ErrorAction Stop
