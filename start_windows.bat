@echo off
setlocal enabledelayedexpansion

REM 端口配置
set PORT=5001
set APP_NAME=PDF小册子裁剪工具

REM 显示帮助信息
if "%1"=="help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help

REM 主逻辑
if "%1"=="" goto :start_service
if "%1"=="start" goto :start_service
if "%1"=="stop" goto :stop_service
if "%1"=="restart" goto :restart_service
if "%1"=="status" goto :check_status
echo 未知命令: %1
goto :show_help

:show_help
echo 用法: %0 [start^|stop^|restart^|status]
echo.
echo 命令:
echo   start    启动服务
echo   stop     停止服务
echo   restart  重启服务
echo   status   查看服务状态
echo   无参数   默认启动服务
echo.
pause
exit /b 0

:check_status
echo 正在检查服务状态...
netstat -ano | findstr ":%PORT%" >nul
if errorlevel 1 (
    echo ✗ %APP_NAME% 未运行
) else (
    echo ✓ %APP_NAME% 正在运行 (端口 %PORT%)
)
pause
exit /b 0

:stop_service
echo 正在停止 %APP_NAME%...

REM 查找并杀死相关进程
for /f "tokens=5" %%i in ('netstat -ano ^| findstr ":%PORT%"') do (
    set PID=%%i
    echo 找到进程PID: !PID!
    taskkill /PID !PID! /F >nul 2>&1
)

REM 再次检查是否还有进程在运行
netstat -ano | findstr ":%PORT%" >nul
if errorlevel 1 (
    echo ✓ 服务已停止
) else (
    echo ⚠ 仍有进程在运行，尝试强制终止...
    for /f "tokens=5" %%i in ('netstat -ano ^| findstr ":%PORT%"') do (
        taskkill /PID %%i /F >nul 2>&1
    )
    echo ✓ 服务已强制停止
)
pause
exit /b 0

:start_service
REM 检查服务是否已在运行
netstat -ano | findstr ":%PORT%" >nul
if not errorlevel 1 (
    echo ⚠ 服务已在运行，如需重启请使用: %0 restart
    pause
    exit /b 0
)

echo ========================================
echo    %APP_NAME% - Windows启动脚本
echo ========================================
echo.

REM 检查Python是否安装
python --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Python，请先安装Python 3.7或更高版本
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM 检查pip是否可用
python -m pip --version >nul 2>&1
if errorlevel 1 (
    echo 错误: pip不可用，请确保Python安装正确
    pause
    exit /b 1
)

echo 正在检查依赖包...
echo.

REM 检查并安装Flask
python -c "import flask" >nul 2>&1
if errorlevel 1 (
    echo 安装Flask...
    python -m pip install Flask==2.3.3
    if errorlevel 1 (
        echo 错误: Flask安装失败
        pause
        exit /b 1
    )
) else (
    echo ✓ Flask已安装
)

REM 检查并安装PyPDF2
python -c "import PyPDF2" >nul 2>&1
if errorlevel 1 (
    echo 安装PyPDF2...
    python -m pip install PyPDF2==3.0.1
    if errorlevel 1 (
        echo 错误: PyPDF2安装失败
        pause
        exit /b 1
    )
) else (
    echo ✓ PyPDF2已安装
)

REM 检查并安装Werkzeug
python -c "import werkzeug" >nul 2>&1
if errorlevel 1 (
    echo 安装Werkzeug...
    python -m pip install Werkzeug==2.3.7
    if errorlevel 1 (
        echo 错误: Werkzeug安装失败
        pause
        exit /b 1
    )
) else (
    echo ✓ Werkzeug已安装
)

echo.
echo ========================================
echo           依赖检查完成！
echo ========================================
echo.

REM 创建必要的目录
if not exist "uploads" mkdir uploads
if not exist "processed" mkdir processed

echo 正在启动PDF小册子裁剪工具...
echo.
echo 访问地址: http://localhost:%PORT%
echo 按 Ctrl+C 停止服务
echo.

REM 启动Flask应用
python app.py

pause
exit /b 0

:restart_service
call :stop_service
ping -n 3 127.0.0.1 >nul
call :start_service
exit /b 0