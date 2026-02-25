#!/usr/bin/env python3

import subprocess
import sys
import os
import shutil

class GoldenDictTranslator:
    def __init__(self):
        self.desktop_env = self.detect_desktop_environment()
        
    def detect_desktop_environment(self):
        """检测桌面环境"""
        if os.environ.get('WAYLAND_DISPLAY'):
            return 'wayland'
        elif os.environ.get('DISPLAY'):
            return 'x11'
        else:
            return 'unknown'
    
    def check_dependencies(self):
        """检查必要的依赖工具"""
        # 检查GoldenDict
        if not shutil.which('goldendict'):
            print("错误: 未找到 GoldenDict。", file=sys.stderr)
            print("在Arch Linux上安装: sudo pacman -S goldendict", file=sys.stderr)
            return False
        
        # 根据桌面环境检查剪贴板工具
        if self.desktop_env == 'x11':
            if not shutil.which('xclip'):
                print("错误: 未找到 xclip 工具。", file=sys.stderr)
                print("在Arch Linux上安装: sudo pacman -S xclip", file=sys.stderr)
                return False
        elif self.desktop_env == 'wayland':
            if not shutil.which('wl-paste'):
                print("错误: 未找到 wl-clipboard 工具。", file=sys.stderr)
                print("在Arch Linux上安装: sudo pacman -S wl-clipboard", file=sys.stderr)
                return False
        else:
            print("错误: 无法检测到可用的桌面环境。", file=sys.stderr)
            return False
            
        return True
    
    def get_selected_text(self):
        """获取选中的文本"""
        try:
            if self.desktop_env == 'x11':
                result = subprocess.run(
                    ['xclip', '-selection', 'primary', '-o'],
                    capture_output=True, text=True, timeout=5
                )
            elif self.desktop_env == 'wayland':
                result = subprocess.run(
                    ['wl-paste', '-p'],
                    capture_output=True, text=True, timeout=5
                )
            else:
                return None
            
            if result.returncode != 0 or not result.stdout.strip():
                return None
                
            # 清理文本
            text = result.stdout.strip()
            if not text:
                return None
                
            # 限制文本长度
            if len(text) > 500:
                text = text[:500]
                
            return text
            
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError):
            return None
    
    def is_goldendict_running(self):
        """检查GoldenDict是否正在运行"""
        try:
            result = subprocess.run(['pgrep', '-x', 'goldendict'], 
                                  capture_output=True, text=True)
            return result.returncode == 0
        except subprocess.SubprocessError:
            return False
    
    def translate_with_goldendict(self, text):
        """使用GoldenDict进行翻译"""
        if not text:
            print("错误: 翻译文本为空", file=sys.stderr)
            return False
        
        try:
            # 启动GoldenDict进行翻译
            process = subprocess.Popen(['goldendict', text], 
                                     stdout=subprocess.DEVNULL, 
                                     stderr=subprocess.DEVNULL)
            
            # 检查进程是否成功启动
            import time
            time.sleep(0.5)
            if process.poll() is None:
                print(f"✓ GoldenDict进程已启动 (PID: {process.pid})")
                return True
            else:
                print("⚠ GoldenDict可能已退出，但翻译窗口可能已打开")
                return True
                
        except Exception as e:
            print(f"错误: 无法启动GoldenDict - {e}", file=sys.stderr)
            return False
    
    def run(self):
        """主运行函数"""
        print("=== GoldenDict 翻译工具 (Python版) ===")
        print(f"检测到的桌面环境: {self.desktop_env}")
        print()
        
        # 检查依赖
        if not self.check_dependencies():
            sys.exit(1)
        
        # 检查GoldenDict运行状态
        if self.is_goldendict_running():
            print("✓ GoldenDict已在运行")
        else:
            print("ℹ GoldenDict未运行，将启动新实例")
        print()
        
        # 获取选中的文本
        print("正在获取选中的文本...")
        selected_text = self.get_selected_text()
        
        if not selected_text:
            print("错误: 无法获取选中的文本。请确保：", file=sys.stderr)
            print("1. 在桌面环境中运行此脚本", file=sys.stderr)
            print("2. 已用鼠标选中要翻译的文本", file=sys.stderr)
            sys.exit(1)
        
        # 显示选中的文本
        print(f"选中的文本: \"{selected_text}\"")
        print("-" * 40)
        
        # 进行翻译
        print(f"正在翻译: \"{selected_text}\"")
        success = self.translate_with_goldendict(selected_text)
        
        if success:
            print("\n✓ 翻译任务已成功发送到GoldenDict")
        else:
            print("\n✗ 翻译任务发送失败", file=sys.stderr)
            sys.exit(1)
        
        print("\n提示: 您可以将此脚本绑定到快捷键以便快速翻译")

def main():
    """主函数"""
    translator = GoldenDictTranslator()
    translator.run()

if __name__ == "__main__":
    main()

