#!/usr/bin/env python3
# 保存为 `check_dark_mode.py`
import sys
import subprocess
import platform

def is_windows_dark():
    """检测 Windows 深色模式"""
    try:
        import winreg
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER,
                             r"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize")
        value, _ = winreg.QueryValueEx(key, "AppsUseLightTheme")
        return value == 0
    except Exception:
        return False

def is_macos_dark():
    """检测 macOS 深色模式"""
    try:
        # 方法1：使用 defaults 命令
        cmd = ['defaults', 'read', '-g', 'AppleInterfaceStyle']
        result = subprocess.run(cmd, capture_output=True, text=True)
        return 'Dark' in result.stdout
    except Exception:
        return False

def is_linux_gnome_dark():
    """检测 Linux GNOME 深色模式"""
    try:
        # 尝试读取 color-scheme (GNOME 42+)
        cmd = ['gsettings', 'get', 'org.gnome.desktop.interface', 'color-scheme']
        result = subprocess.run(cmd, capture_output=True, text=True)
        if 'dark' in result.stdout.lower():
            print("深色模式")
            return True

        # 回退到检查 gtk-theme
        cmd = ['gsettings', 'get', 'org.gnome.desktop.interface', 'gtk-theme']
        result = subprocess.run(cmd, capture_output=True, text=True)
        return 'dark' in result.stdout.lower()
    except Exception:
        print("浅色模式")
        return False

def main():
    system = platform.system()
    is_dark = False

    if system == 'Windows':
        is_dark = is_windows_dark()
    elif system == 'Darwin':  # macOS
        is_dark = is_macos_dark()
    elif system == 'Linux':
        # 这里主要针对 GNOME，其他桌面环境可能需要调整
        is_dark = is_linux_gnome_dark()
    else:
        print(f"未适配的操作系统: {system}", file=sys.stderr)
        sys.exit(2)

    # 输出结果
    if is_dark:
        print("true")
        sys.exit(0)
    else:
        print("false")
        sys.exit(1)

if __name__ == '__main__':
    main()
