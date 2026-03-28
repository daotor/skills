# ensure-pandoc.ps1 - 确保 pandoc 可用，不存在则从 GitHub 自动下载
# 输出: PANDOC_PATH=<二进制完整路径>  供调用方捕获
param(
    [string]$SkillDir = (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
)

$ErrorActionPreference = "Stop"
$ToolsDir = Join-Path $SkillDir "tools\pandoc"
$PandocExe = Join-Path $ToolsDir "pandoc.exe"

if (Test-Path $PandocExe) {
    $ver = & $PandocExe --version 2>&1 | Select-Object -First 1
    Write-Host "pandoc already available: $ver"
    Write-Host "PANDOC_PATH=$PandocExe"
    exit 0
}

Write-Host "pandoc not found in $ToolsDir, downloading from GitHub..."

# ---- 获取最新 release 信息 ----
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/jgm/pandoc/releases/latest" `
        -Headers @{ "User-Agent" = "pandoc-skill-installer" }
} catch {
    Write-Error "Failed to query GitHub API: $_"
    exit 1
}

$version = $release.tag_name
Write-Host "Latest release: $version"

# ---- 定位 Windows x86_64 zip 资产 ----
$asset = $release.assets | Where-Object { $_.name -match "windows-x86_64\.zip$" } | Select-Object -First 1
if (-not $asset) {
    Write-Error "Cannot find windows-x86_64.zip in release $version"
    exit 1
}

$downloadUrl = $asset.browser_download_url
$fileName = $asset.name
$zipFile = Join-Path $env:TEMP $fileName
$extractDir = Join-Path $env:TEMP "pandoc-extract-$version"

# ---- 下载 ----
Write-Host "Downloading $fileName ($([math]::Round($asset.size / 1MB, 1)) MB)..."
try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
} catch {
    Write-Error "Download failed: $_"
    exit 1
}
Write-Host "Download complete."

# ---- 解压 ----
Write-Host "Extracting..."
if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force

$pandocSubDir = Get-ChildItem $extractDir -Directory | Where-Object { $_.Name -like "pandoc-*" } | Select-Object -First 1
if (-not $pandocSubDir) {
    $pandocSubDir = Get-ChildItem $extractDir -Directory | Select-Object -First 1
}
if (-not $pandocSubDir) {
    Write-Error "Unexpected archive structure - no subdirectory found"
    exit 1
}

# ---- 复制到 tools/pandoc/ ----
if (-not (Test-Path $ToolsDir)) {
    New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null
}
Copy-Item -Path "$($pandocSubDir.FullName)\*" -Destination $ToolsDir -Recurse -Force

# ---- 清理临时文件 ----
Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue

# ---- 验证 ----
if (Test-Path $PandocExe) {
    $ver = & $PandocExe --version 2>&1 | Select-Object -First 1
    Write-Host "Successfully installed: $ver"
    Write-Host "PANDOC_PATH=$PandocExe"
    exit 0
} else {
    Write-Error "Installation failed - pandoc.exe not found at $PandocExe"
    exit 1
}
