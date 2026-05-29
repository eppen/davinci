# Start MySQL in Docker and wait until healthy.
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

function Get-DockerExe {
    $cmd = Get-Command docker -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $desktop = "${env:ProgramFiles}\Docker\Docker\resources\bin\docker.exe"
    if (Test-Path $desktop) { return $desktop }
    throw "未找到 Docker。请先安装 Docker Desktop 并确保 docker 命令可用。"
}

$docker = Get-DockerExe
Write-Host "Using docker: $docker"

& $docker compose up -d mysql
if ($LASTEXITCODE -ne 0) {
    & $docker-compose up -d mysql
    if ($LASTEXITCODE -ne 0) { throw "启动 MySQL 容器失败" }
}

Write-Host "Waiting for MySQL to become healthy..."
$deadline = (Get-Date).AddMinutes(3)
do {
    $status = & $docker inspect --format "{{.State.Health.Status}}" davinci-mysql 2>$null
    if ($status -eq "healthy") {
        Write-Host "MySQL is ready (davinci0.3 initialized from bin/davinci.sql on first run)."
        exit 0
    }
    Start-Sleep -Seconds 3
} while ((Get-Date) -lt $deadline)

throw "MySQL 容器未在预期时间内就绪，请执行: docker logs davinci-mysql"
