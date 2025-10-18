@echo off
setlocal enabledelayedexpansion

echo ========================================
echo FLUTTER VERBOSE BUILD ANALYZER
echo ========================================
echo.
echo This script will:
echo 1. Run Flutter build with maximum verbosity
echo 2. Capture all output to a log file
echo 3. Analyze the output for common failure patterns
echo 4. Provide specific recommendations
echo.

:: Create timestamped log file
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set LOGFILE=flutter_build_verbose_%TIMESTAMP%.log

echo Starting verbose build analysis...
echo Log file: %LOGFILE%
echo.

:: Clear any existing build artifacts
echo [1/5] Cleaning previous build artifacts...
flutter clean > nul 2>&1

:: Get fresh dependencies
echo [2/5] Getting dependencies...
flutter pub get > nul 2>&1

:: Check environment before build
echo [3/5] Checking environment...
echo ========== ENVIRONMENT CHECK ========== > %LOGFILE%
echo Date/Time: %date% %time% >> %LOGFILE%
echo. >> %LOGFILE%

echo Flutter Version: >> %LOGFILE%
flutter --version >> %LOGFILE% 2>&1
echo. >> %LOGFILE%

echo Java Version: >> %LOGFILE%
java -version >> %LOGFILE% 2>&1
echo. >> %LOGFILE%

echo Environment Variables: >> %LOGFILE%
echo JAVA_HOME: %JAVA_HOME% >> %LOGFILE%
echo ANDROID_HOME: %ANDROID_HOME% >> %LOGFILE%
echo. >> %LOGFILE%

echo Flutter Doctor: >> %LOGFILE%
flutter doctor -v >> %LOGFILE% 2>&1
echo. >> %LOGFILE%

:: Start the verbose build
echo [4/5] Starting verbose build (this may take 5-10 minutes)...
echo ========== VERBOSE BUILD OUTPUT ========== >> %LOGFILE%

:: Run build with maximum verbosity and capture everything
flutter build apk --debug --verbose --dart-define=FLUTTER_WEB_USE_SKIA=true >> %LOGFILE% 2>&1
set BUILD_EXIT_CODE=%errorlevel%

echo. >> %LOGFILE%
echo ========== BUILD COMPLETED ========== >> %LOGFILE%
echo Exit Code: %BUILD_EXIT_CODE% >> %LOGFILE%
echo End Time: %date% %time% >> %LOGFILE%

:: Analyze the build output
echo [5/5] Analyzing build output...
echo.

if %BUILD_EXIT_CODE% equ 0 (
    echo ✅ BUILD SUCCESSFUL!
    echo.
    echo The APK was built successfully.
    echo Check build\app\outputs\flutter-apk\ for the generated APK.
) else (
    echo ❌ BUILD FAILED (Exit Code: %BUILD_EXIT_CODE%)
    echo.
    echo Analyzing failure patterns...
    
    :: Create error analysis file
    set ERRORFILE=build_error_analysis_%TIMESTAMP%.txt
    echo BUILD ERROR ANALYSIS > %ERRORFILE%
    echo ==================== >> %ERRORFILE%
    echo. >> %ERRORFILE%
    
    :: Check for specific error patterns
    echo Checking for common error patterns...
    
    :: JDK/Java errors
    findstr /i "jdk\|java.*version\|unsupported.*class.*file\|major.*version" %LOGFILE% > temp_errors.txt
    if not errorlevel 1 (
        echo ❌ JDK/Java Version Issues Detected >> %ERRORFILE%
        echo ================================== >> %ERRORFILE%
        type temp_errors.txt >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo SOLUTION: >> %ERRORFILE%
        echo - Use JDK 8, 11, or 17 ^(avoid JDK 18+^) >> %ERRORFILE%
        echo - Set JAVA_HOME to correct JDK path >> %ERRORFILE%
        echo - Restart terminal/IDE after setting JAVA_HOME >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo ❌ JDK/Java compatibility issues found
    )
    
    :: Gradle errors
    findstr /i "gradle.*failed\|could not.*gradle\|gradle.*exception" %LOGFILE% > temp_errors.txt
    if not errorlevel 1 (
        echo ❌ Gradle Issues Detected >> %ERRORFILE%
        echo ======================= >> %ERRORFILE%
        type temp_errors.txt >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo SOLUTION: >> %ERRORFILE%
        echo - Clear Gradle cache: rmdir /s /q "%USERPROFILE%\.gradle\caches" >> %ERRORFILE%
        echo - Clear project cache: rmdir /s /q "android\.gradle" >> %ERRORFILE%
        echo - Check Gradle version compatibility >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo ❌ Gradle build issues found
    )
    
    :: Android SDK errors
    findstr /i "android.*sdk\|license.*not.*accepted\|build-tools" %LOGFILE% > temp_errors.txt
    if not errorlevel 1 (
        echo ❌ Android SDK Issues Detected >> %ERRORFILE%
        echo ============================= >> %ERRORFILE%
        type temp_errors.txt >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo SOLUTION: >> %ERRORFILE%
        echo - Accept licenses: flutter doctor --android-licenses >> %ERRORFILE%
        echo - Update Android SDK in Android Studio >> %ERRORFILE%
        echo - Check ANDROID_HOME path >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo ❌ Android SDK issues found
    )
    
    :: Dependency errors
    findstr /i "dependency.*failed\|package.*not.*found\|pub.*get.*failed" %LOGFILE% > temp_errors.txt
    if not errorlevel 1 (
        echo ❌ Dependency Issues Detected >> %ERRORFILE%
        echo ============================ >> %ERRORFILE%
        type temp_errors.txt >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo SOLUTION: >> %ERRORFILE%
        echo - Run: flutter clean >> %ERRORFILE%
        echo - Run: flutter pub get >> %ERRORFILE%
        echo - Check pubspec.yaml for version conflicts >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo ❌ Dependency issues found
    )
    
    :: Memory/Resource errors
    findstr /i "out.*of.*memory\|heap.*space\|gc.*overhead" %LOGFILE% > temp_errors.txt
    if not errorlevel 1 (
        echo ❌ Memory Issues Detected >> %ERRORFILE%
        echo ========================= >> %ERRORFILE%
        type temp_errors.txt >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo SOLUTION: >> %ERRORFILE%
        echo - Increase Gradle memory in gradle.properties >> %ERRORFILE%
        echo - Close other applications >> %ERRORFILE%
        echo - Use release build: flutter build apk --release >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo ❌ Memory/resource issues found
    )
    
    :: Network/Download errors
    findstr /i "download.*failed\|connection.*timeout\|network.*error" %LOGFILE% > temp_errors.txt
    if not errorlevel 1 (
        echo ❌ Network Issues Detected >> %ERRORFILE%
        echo ========================== >> %ERRORFILE%
        type temp_errors.txt >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo SOLUTION: >> %ERRORFILE%
        echo - Check internet connection >> %ERRORFILE%
        echo - Try again later >> %ERRORFILE%
        echo - Use VPN if behind firewall >> %ERRORFILE%
        echo. >> %ERRORFILE%
        echo ❌ Network/download issues found
    )
    
    :: Clean up temp file
    if exist temp_errors.txt del temp_errors.txt
    
    echo.
    echo 📄 Detailed error analysis saved to: %ERRORFILE%
    echo 📄 Full verbose log saved to: %LOGFILE%
    echo.
    echo IMMEDIATE ACTIONS TO TRY:
    echo =========================
    echo 1. Check the error analysis file above
    echo 2. Run the appropriate fix script:
    echo    - JDK issues: run JDK17_COMPATIBILITY_FIX.bat
    echo    - Cache issues: run nuclear_fix.bat
    echo    - General issues: run COMPLETE_JDK_FIX.bat
    echo.
    echo 3. If issues persist, share the log files for further analysis
)

echo.
echo ========================================
echo ANALYSIS COMPLETE
echo ========================================
echo.
echo Files generated:
echo - Verbose build log: %LOGFILE%
if exist %ERRORFILE% (
    echo - Error analysis: %ERRORFILE%
)
echo.
echo To run this analysis again: flutter_verbose_build_analyzer.bat
echo.

pause