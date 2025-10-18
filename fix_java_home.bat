@echo off
echo Fixing JAVA_HOME environment variable...

echo.
echo Current Java version detected:
java -version

echo.
echo Step 1: Finding a valid Java 17 installation...

set "JAVA_HOME_CANDIDATE="

if exist "C:\Program Files\Eclipse Adoptium\jdk-17*" (
    for /d %%i in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do (
        if not defined JAVA_HOME_CANDIDATE (
            echo Found Adoptium Java 17 at: %%i
            set "JAVA_HOME_CANDIDATE=%%i"
        )
    )
)

if not defined JAVA_HOME_CANDIDATE (
    if exist "C:\Program Files\Microsoft\jdk-17*" (
        for /d %%i in ("C:\Program Files\Microsoft\jdk-17*") do (
            if not defined JAVA_HOME_CANDIDATE (
                echo Found Microsoft Java 17 at: %%i
                set "JAVA_HOME_CANDIDATE=%%i"
            )
        )
    )
)

if not defined JAVA_HOME_CANDIDATE (
    if exist "C:\Program Files\Java\jdk-17*" (
        for /d %%i in ("C:\Program Files\Java\jdk-17*") do (
            if not defined JAVA_HOME_CANDIDATE (
                echo Found Java 17 at: %%i
                set "JAVA_HOME_CANDIDATE=%%i"
            )
        )
    )
)

echo.
echo Step 2: Setting JAVA_HOME for current session...
if defined JAVA_HOME_CANDIDATE (
    set "JAVA_HOME=%JAVA_HOME_CANDIDATE%"
    echo JAVA_HOME set to: %JAVA_HOME%
    
    echo.
    echo Step 3: Verifying Java installation...
    "%JAVA_HOME%\bin\java" -version
    
    echo.
    echo Step 4: Clearing Gradle caches...
    rmdir /s /q "%USERPROFILE%\.gradle\caches" 2>nul
    
    echo.
    echo Step 5: Clearing Flutter cache...
    call flutter clean
    
    echo.
    echo Step 6: Building with correct JAVA_HOME...
    call flutter build apk --debug
    
    echo.
    if %ERRORLEVEL% EQU 0 (
        echo SUCCESS! To make this permanent, add this to your system environment variables:
        echo JAVA_HOME=%JAVA_HOME%
        echo PATH=%JAVA_HOME%\bin;%%PATH%%
    ) else (
        echo ERROR: Build failed even with a valid JDK. Further investigation is needed.
    )
) else (
    echo ERROR: Could not find a valid Java 17 installation.
    echo Please install Java 17 from: https://adoptium.net/temurin/releases/
    echo Or check if Java is installed in a different location.
)

echo.
