@echo off
setlocal enabledelayedexpansion

echo ========================================
echo DETAILED FLUTTER BUILD ANALYSIS
echo ========================================
echo.

:: Create log file
set LOGFILE=build_analysis_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log
echo Logging to: %LOGFILE%
echo Build Analysis Started at %date% %time% > %LOGFILE%

echo [STEP 1] Environment Check...
echo ========================================

echo Checking Flutter...
flutter --version >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter not found
    echo ERROR: Flutter not found >> %LOGFILE%
) else (
    echo ✅ Flutter found
    flutter --version
)

echo.
echo Checking Java...
java -version >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    echo ❌ Java not found
    echo ERROR: Java not found >> %LOGFILE%
) else (
    echo ✅ Java found
    java -version 2>&1 | findstr "version"
)

echo.
echo Checking Environment Variables...
echo JAVA_HOME: %JAVA_HOME%
echo ANDROID_HOME: %ANDROID_HOME%
echo PATH (Flutter): 
echo %PATH% | findstr flutter

echo Environment Variables: >> %LOGFILE%
echo JAVA_HOME: %JAVA_HOME% >> %LOGFILE%
echo ANDROID_HOME: %ANDROID_HOME% >> %LOGFILE%

echo.
echo [STEP 2] Project Structure Check...
echo ========================================

echo Checking critical files...
if exist pubspec.yaml (
    echo ✅ pubspec.yaml found
) else (
    echo ❌ pubspec.yaml missing
)

if exist android\build.gradle (
    echo ✅ android\build.gradle found
) else (
    echo ❌ android\build.gradle missing
)

if exist android\app\build.gradle (
    echo ✅ android\app\build.gradle found
) else (
    echo ❌ android\app\build.gradle missing
)

if exist .env (
    echo ✅ .env file found
) else (
    echo ⚠️  .env file missing
    if exist .env.example (
        echo Creating .env from .env.example...
        copy .env.example .env
    )
)

echo.
echo [STEP 3] Configuration Analysis...
echo ========================================

echo Gradle Wrapper Version:
if exist android\gradle\wrapper\gradle-wrapper.properties (
    findstr "distributionUrl" android\gradle\wrapper\gradle-wrapper.properties
) else (
    echo ❌ gradle-wrapper.properties not found
)

echo.
echo Android Gradle Plugin Version:
if exist android\build.gradle (
    findstr "com.android.tools.build:gradle" android\build.gradle
) else (
    echo ❌ android\build.gradle not found
)

echo.
echo Java Compatibility Settings:
if exist android\app\build.gradle (
    findstr "sourceCompatibility\|targetCompatibility\|jvmTarget" android\app\build.gradle
) else (
    echo ❌ android\app\build.gradle not found
)

echo.
echo [STEP 4] Flutter Doctor Analysis...
echo ========================================
flutter doctor -v
flutter doctor -v >> %LOGFILE% 2>&1

echo.
echo [STEP 5] Dependency Check...
echo ========================================
echo Running flutter pub get...
flutter pub get >> %LOGFILE% 2>&1
if %errorlevel% neq 0 (
    echo ❌ flutter pub get failed
    echo Check %LOGFILE% for details
) else (
    echo ✅ Dependencies resolved successfully
)

echo.
echo [STEP 6] Cache Status...
echo ========================================
echo Checking for cache issues...

if exist "%USERPROFILE%\.gradle\caches" (
    echo ✅ Gradle cache exists
    for /f %%i in ('dir "%USERPROFILE%\.gradle\caches" /s /-c ^| find "File(s)"') do echo Gradle cache size: %%i
) else (
    echo ⚠️  Gradle cache not found
)

if exist "android\.gradle" (
    echo ✅ Project Gradle cache exists
) else (
    echo ⚠️  Project Gradle cache not found
)

echo.
echo [STEP 7] Build Attempt with Verbose Output...
echo ========================================
echo Starting build with maximum verbosity...
echo This may take several minutes...
echo.

echo Build attempt started at %date% %time% >> %LOGFILE%
flutter build apk --debug --verbose >> %LOGFILE% 2>&1
set BUILD_RESULT=%errorlevel%

if %BUILD_RESULT% equ 0 (
    echo ✅ BUILD SUCCESSFUL!
    echo Build completed successfully at %date% %time% >> %LOGFILE%
) else (
    echo ❌ BUILD FAILED!
    echo Build failed with exit code %BUILD_RESULT% at %date% %time% >> %LOGFILE%
    echo.
    echo Analyzing failure...
    
    :: Check for common error patterns
    findstr /i "error\|exception\|failed\|could not" %LOGFILE% > build_errors.txt
    if exist build_errors.txt (
        echo.
        echo DETECTED ERRORS:
        echo ================
        type build_errors.txt
        echo.
        echo Full error details saved to: build_errors.txt
    )
)

echo.
echo [STEP 8] Recommendations...
echo ========================================

if %BUILD_RESULT% neq 0 (
    echo Based on common issues, try these solutions:
    echo.
    echo 1. JDK Issues:
    echo    - Ensure you're using JDK 8, 11, or 17
    echo    - Set JAVA_HOME correctly
    echo    - Restart your terminal/IDE
    echo.
    echo 2. Cache Issues:
    echo    - Run: flutter clean
    echo    - Delete: %USERPROFILE%\.gradle\caches
    echo    - Delete: android\.gradle
    echo.
    echo 3. Gradle Issues:
    echo    - Check Gradle version compatibility
    echo    - Update Android Gradle Plugin
    echo    - Check android/build.gradle settings
    echo.
    echo 4. Environment Issues:
    echo    - Update Android SDK
    echo    - Accept Android licenses: flutter doctor --android-licenses
    echo    - Check ANDROID_HOME path
    echo.
    echo 5. Dependencies:
    echo    - Run: flutter pub get
    echo    - Check pubspec.yaml for conflicts
    echo    - Update Flutter: flutter upgrade
)

echo.
echo ========================================
echo ANALYSIS COMPLETE
echo ========================================
echo.
echo Full log saved to: %LOGFILE%
if exist build_errors.txt (
    echo Error summary saved to: build_errors.txt
)
echo.
echo Next steps:
echo 1. Review the verbose output above
echo 2. Check the log file for detailed information
echo 3. Apply recommended solutions based on error type
echo 4. Run specific fix scripts if available
echo.

pause