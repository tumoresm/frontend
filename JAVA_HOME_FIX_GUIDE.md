# JAVA_HOME Fix Guide

## Problem
JAVA_HOME is set to an invalid directory that doesn't exist:
```
C:\Users\GoldSol\AppData\Roaming\Code\User\globalStorage\pleiades.java-extension-pack-jdk\java\latest
```

## Current Java Installation
You have Java 17 installed (OpenJDK 17.0.13), which is perfect for Android development.

## Quick Fix

### Option 1: Automated Fix (Recommended)
Run the automated script:
```bash
./fix_java_home.bat
```

This script will:
1. Find your Java 17 installation automatically
2. Set JAVA_HOME for the current session
3. Clear Gradle caches
4. Build your project
5. Show you how to make the fix permanent

### Option 2: Manual Fix

#### Step 1: Find Java Installation
Check these common locations for Java 17:
- `C:\Program Files\Java\jdk-17*`
- `C:\Program Files\Microsoft\jdk-17*`
- `C:\Program Files\Eclipse Adoptium\jdk-17*`
- `C:\Program Files\OpenJDK\jdk-17*`

#### Step 2: Set JAVA_HOME Temporarily
```bash
# Replace with your actual Java path
set JAVA_HOME=C:\Program Files\Microsoft\jdk-17.0.13.11-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%
```

#### Step 3: Verify Java Setup
```bash
echo %JAVA_HOME%
java -version
javac -version
```

#### Step 4: Clear Caches and Build
```bash
# Clear Gradle caches
rmdir /s /q "%USERPROFILE%\.gradle\caches"

# Clear Flutter cache
flutter clean

# Build project
flutter build apk --debug
```

## Make JAVA_HOME Permanent

### Windows 10/11 (Recommended Method):
1. **Open System Properties:**
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - OR Right-click "This PC" → Properties → Advanced system settings

2. **Environment Variables:**
   - Click "Environment Variables" button
   - Under "System variables" click "New"

3. **Add JAVA_HOME:**
   - Variable name: `JAVA_HOME`
   - Variable value: `C:\Program Files\Microsoft\jdk-17.0.13.11-hotspot` (your actual path)
   - Click OK

4. **Update PATH:**
   - Find "Path" in System variables, click "Edit"
   - Click "New" and add: `%JAVA_HOME%\bin`
   - Click OK on all dialogs

5. **Restart Command Prompt/IDE**

### Alternative Method (Command Line):
```bash
# Set permanently (requires admin privileges)
setx JAVA_HOME "C:\Program Files\Microsoft\jdk-17.0.13.11-hotspot" /M
setx PATH "%PATH%;%JAVA_HOME%\bin" /M
```

## Updated Configuration for Java 17

I've updated your project to use Java 17 compatible versions:

### Version Matrix:
- **Java**: 17 (your current installation)
- **Gradle**: 8.0 (perfect for Java 17)
- **Android Gradle Plugin**: 8.0.2 (compatible with Gradle 8.0)
- **Java Target**: 11 (required for AGP 8.0.2)
- **Kotlin**: 1.9.10 (maintained)

### Files Updated:
- `android/gradle/wrapper/gradle-wrapper.properties` → Gradle 8.0
- `android/build.gradle` → AGP 8.0.2
- `android/settings.gradle` → AGP 8.0.2
- `android/gradle.properties` → Java 17 optimizations

## Verification Steps

After fixing JAVA_HOME:

1. **Check Environment:**
   ```bash
   echo %JAVA_HOME%
   java -version
   ```

2. **Check Flutter:**
   ```bash
   flutter doctor --verbose
   ```

3. **Test Build:**
   ```bash
   flutter build apk --debug
   ```

## Common Java Installation Locations

### Microsoft OpenJDK:
- `C:\Program Files\Microsoft\jdk-17.0.13.11-hotspot`
- `C:\Program Files\Microsoft\jdk-17*`

### Eclipse Adoptium:
- `C:\Program Files\Eclipse Adoptium\jdk-17.0.13.11-hotspot`
- `C:\Program Files\Eclipse Adoptium\jdk-17*`

### Oracle JDK:
- `C:\Program Files\Java\jdk-17.0.13`
- `C:\Program Files\Java\jdk-17*`

### OpenJDK:
- `C:\Program Files\OpenJDK\jdk-17.0.13`
- `C:\Program Files\OpenJDK\jdk-17*`

## Troubleshooting

### If Java is not found:
1. **Install Java 17:**
   - Download from: https://adoptium.net/temurin/releases/
   - Choose Java 17 LTS
   - Install with default settings

2. **Check installation:**
   ```bash
   where java
   java -version
   ```

### If JAVA_HOME still shows old path:
1. **Restart Command Prompt/PowerShell**
2. **Restart your IDE (VS Code, Android Studio)**
3. **Restart your computer** (if environment variables don't update)

### If build still fails:
1. **Clear all caches:**
   ```bash
   rmdir /s /q "%USERPROFILE%\.gradle"
   flutter clean
   flutter pub cache clean
   ```

2. **Check Flutter doctor:**
   ```bash
   flutter doctor --verbose
   ```

## Expected Results

After fixing JAVA_HOME:
- ✅ No "JAVA_HOME is set to an invalid directory" errors
- ✅ Gradle 8.0 downloads and works with Java 17
- ✅ Successful build completion
- ✅ Google Maps functionality working
- ✅ Faster builds with optimized configuration

## Benefits of Java 17 + Gradle 8.0

### Stability:
- ✅ **LTS Version**: Java 17 is Long Term Support
- ✅ **Proven Compatibility**: Gradle 8.0 + Java 17 is well-tested
- ✅ **Android Support**: Perfect for Android development
- ✅ **Performance**: Optimized for modern development

### Features:
- ✅ **Modern Java Features**: Records, pattern matching, etc.
- ✅ **Better Performance**: Improved JVM optimizations
- ✅ **Enhanced Security**: Latest security patches
- ✅ **Tool Support**: Excellent IDE and tool support

## Notes

- Java 17 is the recommended version for Android development
- This configuration is more stable than Java 21 for current Android tools
- All Google Maps functionality will work perfectly
- The fix is permanent once environment variables are set correctly