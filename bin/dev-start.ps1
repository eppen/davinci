# Dev startup: Docker MySQL + Maven build + run Davinci server
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$env:DAVINCI3_HOME = $ProjectRoot

foreach ($dir in @("userfiles", "davinci-ui", "logs\sys", "logs\user\opt", "logs\user\sql")) {
    $path = Join-Path $ProjectRoot $dir
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

& "$PSScriptRoot\docker-mysql-up.ps1"

Write-Host "Building server..."
Set-Location "$ProjectRoot\server"
mvn -q clean package -DskipTests
if ($LASTEXITCODE -ne 0) { throw "Maven build failed" }

$cp = @(
    "target\classes",
    (Get-ChildItem "target\lib\*.jar" | ForEach-Object { $_.FullName }
)
$classpath = ($cp -join ";")

Write-Host "Starting Davinci on http://127.0.0.1:8080 ..."
java -Dfile.encoding=UTF-8 `
    -cp $classpath `
    edp.DavinciServerApplication `
    --spring.config.additional-location="file:$ProjectRoot/config/application.yml"
