' ===== 小鲸鱼 静默启动器 =====
' 用 wscript 隐藏窗口运行 PowerShell 脚本，避免黑色控制台闪现
Set sh = CreateObject("WScript.Shell")
ps1 = "C:\Users\tongguangdong\WorkBuddy\2026-10-26-19-32-50\whale-pet\WhalePet.ps1"
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """"
sh.Run cmd, 0, False
