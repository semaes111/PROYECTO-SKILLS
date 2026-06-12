@echo off
REM ============================================================
REM install-efficiency-pack.bat
REM Instala el pack de eficiencia (9 skills) en Windows
REM Destino: %USERPROFILE%\.claude\skills\  (Claude Code + Cowork)
REM Uso: ejecutar desde la raiz del repo proyecto-skills
REM ============================================================
setlocal enabledelayedexpansion

set "REPO=%~dp0.."
set "DEST=%USERPROFILE%\.claude\skills"

echo Destino: %DEST%
if not exist "%DEST%" mkdir "%DEST%"

REM --- Skills en formato FOLDER (carpeta\SKILL.md) ---
call :installFolder "09-SKILLS-UTILIDADES\compactacion-estrategica" "strategic-compact"
call :installFolder "05-SKILLS-DEVOPS-INFRA\monitoreo-coste-tokens-llm" "cost-tracking"
call :installFolder "05-SKILLS-DEVOPS-INFRA\pipeline-llm-cost-aware" "cost-aware-llm-pipeline"
call :installFolder "05-SKILLS-DEVOPS-INFRA\optimizacion-consumo-tokens-openclaw" "optimizacion-tokens-openclaw"
call :installFolder "09-SKILLS-UTILIDADES\busqueda-antes-codigo-disciplina" "search-first"

REM --- Skills en formato FLAT (archivo-SKILL.md) ---
call :installFlat "09-SKILLS-UTILIDADES\auditoria-contexto-tokens-SKILL.md" "context-budget"
call :installFlat "09-SKILLS-UTILIDADES\aprendizaje-continuo-v2-instintos-SKILL.md" "continuous-learning-v2"
call :installFlat "09-SKILLS-UTILIDADES\verificacion-quality-gates-SKILL.md" "verification-loop"
call :installFlat "09-SKILLS-UTILIDADES\tdd-workflow-test-driven-SKILL.md" "tdd-workflow"

echo.
echo === Instalacion completada ===
dir /b "%DEST%"
echo.
echo Las skills se invocaran automaticamente en Claude Code y Cowork.
goto :eof

:installFolder
set "src=%REPO%\%~1"
set "name=%~2"
if not exist "%DEST%\%name%" mkdir "%DEST%\%name%"
copy /Y "%src%\SKILL.md" "%DEST%\%name%\SKILL.md" >nul
if exist "%src%\references" xcopy /E /I /Y "%src%\references" "%DEST%\%name%\references" >nul
if exist "%src%\scripts" xcopy /E /I /Y "%src%\scripts" "%DEST%\%name%\scripts" >nul
echo   [OK] %name%
goto :eof

:installFlat
set "src=%REPO%\%~1"
set "name=%~2"
if not exist "%DEST%\%name%" mkdir "%DEST%\%name%"
copy /Y "%src%" "%DEST%\%name%\SKILL.md" >nul
echo   [OK] %name%
goto :eof
