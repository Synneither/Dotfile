#!/bin/bash
# 删除壁纸文件脚本

CONFIG_FILE="/home/synneither/.cache/noctalia/wallpapers.json"
KEY="eDP-1"

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误：配置文件不存在: $CONFIG_FILE"
    exit 1
fi

# 检查是否安装了jq
if ! command -v jq &> /dev/null; then
    echo "错误：未安装 jq，请先安装：sudo apt install jq"
    exit 1
fi

python3 /home/synneither/Scripts/check_dark_mode.py

if [ $? -eq 0 ]; then
    # 提取文件路径
    WALLPAPER_PATH=$(jq -r '.wallpapers."eDP-1".dark' /home/synneither/.cache/noctalia/wallpapers.json)
else
    WALLPAPER_PATH=$(jq -r '.wallpapers."eDP-1".light' /home/synneither/.cache/noctalia/wallpapers.json)
fi

echo "找到壁纸文件：$WALLPAPER_PATH"

# 确认操作
read -p "确定要删除此文件吗？(y/N): " -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "操作已取消"
    exit 0
fi

# 删除文件
if [ -f "$WALLPAPER_PATH" ]; then
    if rm -v "$WALLPAPER_PATH"; then
        echo "✅ 文件删除成功"
    else
        echo "❌ 文件删除失败"
        exit 1
    fi
else
    echo "⚠️  文件不存在，可能已被删除"
fi
