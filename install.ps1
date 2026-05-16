# DWS Skill 安装脚本 for Claude Code
# 用法: irm https://raw.githubusercontent.com/hzqedison/dws-skill/main/install.ps1 | iex

$ErrorActionPreference = "Stop"
$repo = "hzqedison/dws-skill"
$skillDir = Join-Path $env:USERPROFILE ".claude\skills"
$tmpDir = Join-Path $env:TEMP "dws-skill-install"

Write-Host ">>> 安装 dws skill for Claude Code" -ForegroundColor Cyan

# 检查 Claude Code 是否安装
if (-not (Test-Path $skillDir)) {
    New-Item -ItemType Directory -Path $skillDir -Force | Out-Null
    Write-Host "    已创建目录: $skillDir"
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
$srcDir = Join-Path $tmpDir "dws-skill-main\skills"

# 复制文件（覆盖已有版本）
Write-Host ">>> 安装中..."
$targets = @("dws.md", "dws-refs", "dws-scripts")
foreach ($t in $targets) {
    $src = Join-Path $srcDir $t
    $dst = Join-Path $skillDir $t
    if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
    Copy-Item $src $dst -Recurse -Force
}

# 清理临时文件
Remove-Item $zipPath -Force
Remove-Item $tmpDir -Recurse -Force

Write-Host ""
Write-Host ">>> 安装完成！" -ForegroundColor Green
Write-Host ""
Write-Host "前置条件：需要安装 Wukong（悟空）桌面端" -ForegroundColor Yellow
Write-Host "下载地址：https://wukong.dingtalk.com"
Write-Host ""
Write-Host "首次使用时，Claude 会提示运行：dws auth login"
Write-Host "重启 Claude Code 后即可使用，直接说「帮我查一下钉钉文档」即可触发。"
