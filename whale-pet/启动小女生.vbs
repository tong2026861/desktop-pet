' ===== 小女生 静默启动器 =====
Set sh = CreateObject("WScript.Shell")
ps1 = "C:\Users\tongguangdong\WorkBuddy\2026-10-26-19-32-50\whale-pet\GirlPet.ps1"
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1 & """"
sh.Run cmd, 0, False
