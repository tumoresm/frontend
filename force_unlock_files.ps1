# PowerShell script to force unlock and delete stubborn build files
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FORCE FILE UNLOCK AND DELETION SCRIPT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Targeting locked build directories..." -ForegroundColor Yellow

# Define paths to clean
$pathsToClean = @(
    "build",
    "android\app\build",
    "android\build",
    "android\.gradle",
    "build\app\intermediates\assets\debug",
    "build\app\intermediates"
)

# Function to force delete with multiple attempts
function Force-DeletePath {
    param([string]$Path)
    
    if (Test-Path $Path) {
        Write-Host "Attempting to delete: $Path" -ForegroundColor White
        
        try {
            # First attempt: Normal deletion
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Successfully deleted: $Path" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "⚠️  Normal deletion failed, trying alternative methods..." -ForegroundColor Yellow
            
            try {
                # Second attempt: Take ownership and delete
                takeown /f $Path /r /d y 2>$null
                icacls $Path /grant administrators:F /t 2>$null
                Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
                Write-Host "✅ Successfully deleted with ownership change: $Path" -ForegroundColor Green
                return $true
            }
            catch {
                Write-Host "❌ Failed to delete: $Path" -ForegroundColor Red
                Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
                return $false
            }
        }
    }
    else {
        Write-Host "ℹ️  Path does not exist: $Path" -ForegroundColor Gray
        return $true
    }
}

# Function to kill processes that might lock files
function Stop-LockingProcesses {
    Write-Host "Stopping processes that might lock files..." -ForegroundColor Yellow
    
    $processesToKill = @(
        "flutter", "dart", "java", "javaw", "gradle", "gradlew",
        "studio64", "studio", "kotlin-compiler", "kotlin-daemon"
    )
    
    foreach ($process in $processesToKill) {
        try {
            Get-Process -Name $process -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            Write-Host "Stopped process: $process" -ForegroundColor White
        }
        catch {
            # Process not running, ignore
        }
    }
}

# Main execution
Write-Host "Step 1: Stopping locking processes..." -ForegroundColor Cyan
Stop-LockingProcesses

Write-Host ""
Write-Host "Step 2: Waiting for file handles to release..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "Step 3: Force deleting locked directories..." -ForegroundColor Cyan

$allSuccess = $true
foreach ($path in $pathsToClean) {
    $result = Force-DeletePath -Path $path
    if (-not $result) {
        $allSuccess = $false
    }
}

Write-Host ""
if ($allSuccess) {
    Write-Host "🎉 SUCCESS! All locked files and directories have been cleared!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Run: flutter clean" -ForegroundColor White
    Write-Host "2. Run: flutter pub get" -ForegroundColor White
    Write-Host "3. Run: flutter build apk --debug" -ForegroundColor White
}
else {
    Write-Host "⚠️  Some files could not be deleted. Manual intervention may be required." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Try these steps:" -ForegroundColor Yellow
    Write-Host "1. Restart your computer" -ForegroundColor White
    Write-Host "2. Run this script as Administrator" -ForegroundColor White
    Write-Host "3. Check for antivirus interference" -ForegroundColor White
    Write-Host "4. Close all IDEs and file explorers" -ForegroundColor White
}

Write-Host ""
Write-Host "Script completed." -ForegroundColor Cyan
