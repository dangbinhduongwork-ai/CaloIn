@echo off
echo ===================================================
echo [CaloIn] Running Full QA & Verification Suite
echo ===================================================

echo.
echo [1/4] Running flutter pub get...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] flutter pub get failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/4] Running flutter analyze...
call flutter analyze
if %ERRORLEVEL% neq 0 (
    echo [ERROR] flutter analyze found issues!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/4] Running flutter test...
call flutter test
if %ERRORLEVEL% neq 0 (
    echo [ERROR] flutter test failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [4/4] Building Android APK (debug)...
call flutter build apk --debug
if %ERRORLEVEL% neq 0 (
    echo [ERROR] flutter build apk failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ===================================================
echo [SUCCESS] All checks passed! Ready to run on device.
echo ===================================================
pause
