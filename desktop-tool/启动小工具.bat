@echo off
rem ===== 桌面小工具 启动器 =====
rem 用 Edge 的 --app 模式打开一个无边框小窗，像原生小程序一样
chcp 65001 >nul
cd /d "%~dp0"

set "EDGE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if not exist "%EDGE%" set "EDGE=C:\Program Files\Microsoft\Edge\Application\msedge.exe"

start "" "%EDGE%" --app="file:///%~dp0index.html" --window-size=400,620

exit
