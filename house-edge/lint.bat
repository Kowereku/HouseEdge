@echo off
REM Lint + format-check all GDScript in the project (Windows).
REM First-time setup:  pip install gdtoolkit
REM Usage:
REM   lint.bat        - report style problems
REM   lint.bat fix    - auto-format all scripts in place

where gdlint >nul 2>nul
if errorlevel 1 (
    echo gdtoolkit is not installed. Run:  pip install gdtoolkit
    exit /b 1
)

if "%1"=="fix" (
    echo Formatting scripts...
    gdformat scripts globals
    echo Done.
    exit /b 0
)

echo === Syntax check (gdparse) ===
for /r scripts %%f in (*.gd) do gdparse "%%f" >nul || echo SYNTAX ERROR: %%f
for /r globals %%f in (*.gd) do gdparse "%%f" >nul || echo SYNTAX ERROR: %%f

echo === Style check (gdlint) ===
gdlint scripts globals
