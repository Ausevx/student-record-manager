@echo off
REM Batch setup script for Windows

REM Get the local IP address (excluding loopback)
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr /i "IPv4" ^| findstr /v "127.0.0.1"') do (
    set HOST_IP=%%i
    goto :found_ip
)

:found_ip
REM Remove leading spaces
set HOST_IP=%HOST_IP: =%

if "%HOST_IP%"=="" (
    echo Warning: Could not determine host IP address. Using localhost.
    set HOST_IP=localhost
)

echo Using HOST_IP: %HOST_IP%

REM Build Docker images
echo Building backend Docker image...
docker build -t studentbackend --build-arg HOST_IP="%HOST_IP%" -f ./backend/Dockerfile ./backend

echo Building frontend Docker image...
docker build -t studentfrontend --build-arg HOST_IP="%HOST_IP%" -f ./frontend/Dockerfile ./frontend

REM Start services with docker-compose
echo Starting services with docker-compose...
docker-compose -f docker-compose.yml up -d

REM Open the application in default browser
echo Opening application in browser...
start http://localhost:80

pause
