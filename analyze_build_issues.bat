@echo off
echo ========================================
echo Flutter Build Analysis Script
echo ========================================
echo.

echo [1/10] Checking Flutter Installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    echo Please install Flutter or add it to your PATH
    pause
    exit /b 1
)
echo.

echo [2/10] Checking Java Installation...
java -version
if %errorlevel% neq 0 (
    echo ERROR: Java not found
    echo Please install Java JDK
    pause
    exit /b 1
)
echo.

echo [3/10] Checking JAVA_HOME...
echo JAVA_HOME: %JAVA_HOME%
if "%JAVA_HOME%"=="" (
    echo WARNING: JAVA_HOME not set
)
echo.

echo [4/10] Checking Android SDK...
echo ANDROID_HOME: %ANDROID_HOME%
if "%ANDROID_HOME%"=="" (
    echo WARNING: ANDROID_HOME not set
)
echo.

echo [5/10] Running Flutter Doctor...
flutter doctor -v
echo.

echo [6/10] Checking pubspec.yaml dependencies...
type pubspec.yaml
echo.

echo [7/10] Checking for .env file...
if exist .env (
    echo .env file found
) else (
    echo WARNING: .env file not found
    echo Creating .env from .env.example...
    if exist .env.example (
        copy .env.example .env
    ) else (
        echo ERROR: .env.example not found
    )
)
echo.

echo [8/10] Cleaning Flutter cache...
flutter clean
echo.

echo [9/10] Getting dependencies...
flutter pub get
echo.

echo [10/10] Attempting verbose build...
echo Starting Flutter build with verbose output...
echo This will show detailed build information...
echo.
flutter build apk --debug --verbose

echo.
echo ========================================
echo Build Analysis Complete
echo ========================================
echo.
echo If build failed, check the verbose output above for specific errors.
echo Common issues:
echo - JDK version compatibility (use JDK 8, 11, or 17)
echo - Missing Android SDK components
echo - Gradle cache corruption
echo - Missing environment variables
echo.
pause