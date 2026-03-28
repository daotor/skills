#!/usr/bin/env bash
# ensure-pandoc.sh - 确保 pandoc 可用，不存在则从 GitHub 自动下载
# 输出: PANDOC_PATH=<二进制完整路径>  供调用方捕获
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TOOLS_DIR="$SKILL_DIR/tools/pandoc"
PANDOC_BIN="$TOOLS_DIR/bin/pandoc"

# ---- 已存在则直接返回 ----
if [[ -x "$PANDOC_BIN" ]]; then
    VER=$("$PANDOC_BIN" --version | head -1)
    echo "pandoc already available: $VER"
    echo "PANDOC_PATH=$PANDOC_BIN"
    exit 0
fi

echo "pandoc not found in $TOOLS_DIR, downloading from GitHub..."

# ---- 检测平台 ----
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64)  ASSET_PATTERN="linux-amd64.tar.gz" ;;
            aarch64) ASSET_PATTERN="linux-arm64.tar.gz" ;;
            *)       echo "ERROR: Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac
        ;;
    Darwin)
        case "$ARCH" in
            x86_64) ASSET_PATTERN="x86_64-macOS.zip" ;;
            arm64)  ASSET_PATTERN="arm64-macOS.zip" ;;
            *)      echo "ERROR: Unsupported architecture: $ARCH" >&2; exit 1 ;;
        esac
        ;;
    *)
        echo "ERROR: Unsupported OS: $OS (use ensure-pandoc.ps1 for Windows)" >&2
        exit 1
        ;;
esac

# ---- 获取最新版本 ----
RELEASE_JSON=$(curl -sL -H "User-Agent: pandoc-skill-installer" \
    "https://api.github.com/repos/jgm/pandoc/releases/latest")
VERSION=$(echo "$RELEASE_JSON" | grep '"tag_name"' | head -1 | sed 's/.*": "\(.*\)".*/\1/')
echo "Latest release: $VERSION"

# ---- 获取下载链接 ----
DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep "browser_download_url" | grep "$ASSET_PATTERN" | head -1 | sed 's/.*"\(https:\/\/[^"]*\)".*/\1/')
if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "ERROR: Cannot find asset matching '$ASSET_PATTERN' in release $VERSION" >&2
    exit 1
fi

TMPDIR_DL=$(mktemp -d)
ARCHIVE="$TMPDIR_DL/pandoc-archive"
trap 'rm -rf "$TMPDIR_DL"' EXIT

# ---- 下载 ----
echo "Downloading: $DOWNLOAD_URL"
curl -sL "$DOWNLOAD_URL" -o "$ARCHIVE"
echo "Download complete."

# ---- 解压 ----
echo "Extracting..."
mkdir -p "$TOOLS_DIR"

case "$ASSET_PATTERN" in
    *.tar.gz)
        tar xzf "$ARCHIVE" -C "$TMPDIR_DL"
        EXTRACTED=$(find "$TMPDIR_DL" -maxdepth 1 -type d -name "pandoc-*" | head -1)
        if [[ -z "$EXTRACTED" ]]; then
            echo "ERROR: Unexpected archive structure" >&2; exit 1
        fi
        cp -r "$EXTRACTED"/* "$TOOLS_DIR/"
        ;;
    *.zip)
        unzip -q "$ARCHIVE" -d "$TMPDIR_DL"
        EXTRACTED=$(find "$TMPDIR_DL" -maxdepth 1 -type d -name "pandoc-*" | head -1)
        if [[ -z "$EXTRACTED" ]]; then
            echo "ERROR: Unexpected archive structure" >&2; exit 1
        fi
        cp -r "$EXTRACTED"/* "$TOOLS_DIR/"
        ;;
esac

# ---- 设置可执行权限 ----
find "$TOOLS_DIR" -name "pandoc" -type f -exec chmod +x {} \;
find "$TOOLS_DIR" -name "pandoc-*" -type f -exec chmod +x {} \;

# ---- 验证 ----
if [[ -x "$PANDOC_BIN" ]]; then
    VER=$("$PANDOC_BIN" --version | head -1)
    echo "Successfully installed: $VER"
    echo "PANDOC_PATH=$PANDOC_BIN"
    exit 0
fi

FOUND=$(find "$TOOLS_DIR" -name "pandoc" -type f 2>/dev/null | head -1)
if [[ -n "$FOUND" ]]; then
    chmod +x "$FOUND"
    VER=$("$FOUND" --version | head -1)
    echo "Successfully installed: $VER"
    echo "PANDOC_PATH=$FOUND"
    exit 0
fi

echo "ERROR: Installation failed - pandoc binary not found" >&2
exit 1
