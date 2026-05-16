# DWS Skill 安装脚本 for Claude Code
# 用法: irm https://raw.githubusercontent.com/hzqedison/tools/main/dws-skill/install.ps1 | iex

$ErrorActionPreference = "Stop"
$repo = "hzqedison/tools"
$skillDir   = Join-Path $env:USERPROFILE ".claude\skills"
$commandDir = Join-Path $env:USERPROFILE ".claude\commands"
$tmpDir     = Join-Path $env:TEMP "dws-skill-install"

Write-Host ">>> 安装 dws skill for Claude Code" -ForegroundColor Cyan

# 确保目录存在
foreach ($d in @($skillDir, $commandDir)) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
        Write-Host "    已创建目录: $d"
    }
}

# 下载最新 release zip
Write-Host ">>> 下载中..."
$zipUrl = "https://github.com/$repo/archive/refs/heads/main.zip"
$zipPath = Join-Path $env:TEMP "dws-skill.zip"

try {
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
} catch {
    Write-Host "下载失败，请检查网络连接" -ForegroundColor Red
    exit 1
}

# 解压
if (Test-Path $tmpDir) { Remove-Item $tmpDir -Recurse -Force }
Expand-Archive -Path $zipPath -DestinationPath $tmpDir -Force
$srcSkills   = Join-Path $tmpDir "tools-main\dws-skill\skills"
$srcCommands = Join-Path $tmpDir "tools-main\dws-skill\commands"

# 安装 skill 文件
Write-Host ">>> 安装 skill 文件..."
foreach ($t in @("dws.md", "dws-refs", "dws-scripts")) {
    $src = Join-Path $srcSkills $t
    $dst = Join-Path $skillDir $t
    if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
    Copy-Item $src $dst -Recurse -Force
}

# 安装 /dws 斜杠命令
Write-Host ">>> 安装 /dws 斜杠命令..."
$src = Join-Path $srcCommands "dws.md"
$dst = Join-Path $commandDir "dws.md"
if (Test-Path $dst) { Remove-Item $dst -Force }
Copy-Item $src $dst -Force

# 清理临时文件
Remove-Item $zipPath -Force
Remove-Item $tmpDir -Recurse -Force

Write-Host ""
Write-Host ">>> 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "前置条件：需要安装 Wukong（悟空）桌面端" -ForegroundColor Yellow
Write-Host "下载地址：https://wukong.dingtalk.com"
Write-Host ""
Write-Host "使用方式："
Write-Host "  · 直接描述钉钉任务，Claude 自动触发"
Write-Host "  · 或输入 /dws <任务> 显式触发，例如：/dws 查我今天的日程"
