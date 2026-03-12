@echo off
REM Executa o script PowerShell RepararHardware.ps1
REM Recomendado: configure o atalho deste .bat para executar como Administrador.

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_PATH=%SCRIPT_DIR%RepararHardware.ps1"

REM Verifica se o arquivo existe
if not exist "%SCRIPT_PATH%" (
    echo Arquivo RepararHardware.ps1 nao encontrado em "%SCRIPT_DIR%".
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

REM Executa o PowerShell com politica de execucao liberada apenas para esta chamada
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"

echo.
echo Script concluido. Pressione qualquer tecla para fechar...
pause >nul

