@echo off
chcp 65001 >nul
echo ========================================
echo    jshERP Docker 快速启动脚本
echo ========================================
echo.

echo [1/4] 检查 Docker 是否运行...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 未运行，请先启动 Docker Desktop
    pause
    exit /b 1
)
echo [成功] Docker 正在运行
echo.

echo [2/4] 创建必要的目录...
if not exist "upload" mkdir upload
if not exist "tmp" mkdir tmp
echo [成功] 目录创建完成
echo.

echo [3/4] 启动 Docker 服务...
docker-compose up -d
if %errorlevel% neq 0 (
    echo [错误] 服务启动失败
    pause
    exit /b 1
)
echo [成功] 服务启动成功
echo.

echo [4/4] 等待服务就绪...
timeout /t 5 /nobreak >nul
echo.

echo ========================================
echo    部署完成！
echo ========================================
echo.
echo 访问地址：
echo   前端：http://localhost:8080
echo   后端：http://localhost:9999/jshERP-boot
echo   MySQL：localhost:3306
echo   Redis：localhost:6380
echo.
echo 默认登录信息：
echo   租户账号：jsh
echo   管理员账号：admin
echo   密码：123456
echo.
echo 查看日志命令：
echo   docker-compose logs -f
echo.
echo 停止服务命令：
echo   docker-compose stop
echo.
pause
