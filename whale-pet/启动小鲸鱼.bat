@echo off
rem ===== 小鲸鱼 电子宠物 启动器（桌面常驻版） =====
chcp 65001 >nul

rem 用绝对路径，保证从任何位置启动都能找到文件
set "APP=C:\Users\tongguangdong\WorkBuddy\2026-10-26-19-32-50\whale-pet\index.html"

set "EDGE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" set "EDGE=C:\Program Files\Microsoft\Edge\Application\msedge.exe"

rem 独立 user-data-dir，避免和日常 Edge 窗口混在一起
set "PROFILE=%TEMP%\whale-pet-profile"

rem --app 无边框窗口；较小尺寸贴近桌面宠物；屏幕右侧居中偏下
start "" "%EDGE%" --user-data-dir="%PROFILE%" --app="file:///%APP%" --window-size=280,500 --window-position=1150,260

exit
