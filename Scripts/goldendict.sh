#!/bin/bash

# GoldenDict 选中文本翻译脚本
# 功能：获取GNOME桌面环境中选中的文本并调用GoldenDict进行翻译

# 检查GoldenDict是否安装
if ! command -v goldendict &> /dev/null; then
    echo "错误: 未找到 GoldenDict。请先安装：sudo apt install goldendict" >&2
    exit 1
fi

# 检查xclip工具是否安装
if ! command -v xclip &> /dev/null; then
    echo "错误: 未找到 xclip 工具。请先安装：sudo apt install xclip" >&2
    exit 1
fi

# 函数：获取选中的文本
get_selected_text() {
    # 从X11 PRIMARY选区获取选中的文本
    local selected_text
    selected_text=$(xclip -selection primary -o 2>/dev/null)
    
    # 检查是否成功获取文本
    if [ $? -ne 0 ] || [ -z "$selected_text" ]; then
        echo "错误: 无法获取选中的文本。请确保："
        echo "1. 在GNOME桌面环境中运行此脚本"
        echo "2. 已用鼠标选中要翻译的文本"
        return 1
    fi
    
    # 清理文本：去除首尾空白字符，限制长度
    selected_text=$(echo "$selected_text" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | head -c 500)
    
    if [ -z "$selected_text" ]; then
        echo "错误: 选中的文本为空或仅包含空白字符" >&2
        return 1
    fi
    
    echo "$selected_text"
    return 0
}

# 函数：调用GoldenDict进行翻译
translate_with_goldendict() {
    local text_to_translate="$1"
    
    if [ -z "$text_to_translate" ]; then
        echo "错误: 翻译文本为空" >&2
        return 1
    fi
    
    echo "正在翻译: \"$text_to_translate\""
    
    # 调用GoldenDict进行翻译
    # 使用nohup和&让GoldenDict在后台运行，避免阻塞终端
    nohup goldendict "$text_to_translate" >/dev/null 2>&1 &
    
    local pid=$!
    
    # 等待GoldenDict启动（最多3秒）
    for i in {1..30}; do
        if ps -p $pid > /dev/null; then
            sleep 0.1
        else
            break
        fi
    done
    
    echo "翻译窗口已打开，GoldenDict进程ID: $pid"
    return 0
}

# 主函数
main() {
    local selected_text
    
    echo "=== GoldenDict 翻译工具 ==="
    
    # 获取选中的文本
    selected_text=$(get_selected_text)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # 显示选中的文本（预览）
    echo "选中的文本: \"$selected_text\""
    echo "------------------------"
    
    # 调用GoldenDict翻译
    translate_with_goldendict "$selected_text"
    
    # 检查GoldenDict是否成功启动
    sleep 1
    if pgrep -f "goldendict.*$selected_text" > /dev/null; then
        echo "✓ 翻译任务已成功发送到GoldenDict"
    else
        echo "⚠ 注意: 无法确认GoldenDict是否成功处理翻译请求"
        echo "请检查GoldenDict窗口是否正常显示"
    fi
}

# 脚本入口点
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi
