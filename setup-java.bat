@echo off
echo ===================================================
echo Java Setup Helper for Windows
echo ===================================================
echo.
echo This script will help you download and install Amazon Corretto JDK 21
echo and set up the necessary environment variables.
echo.
echo Requirements:
echo - Internet connection
echo - Administrator privileges (for installation)
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause > nul

echo.
echo Checking if Java is already installed...
where java > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Java is already installed. Checking version...
    java -version
    echo.
    echo If this is not JDK 21, you may want to continue with the installation.
    echo.
    echo Press any key to continue with installation or Ctrl+C to cancel...
    pause > nul
) else (
    echo Java is not installed or not in PATH.
)

echo.
echo Creating temporary directory...
if not exist "%TEMP%\java-setup" mkdir "%TEMP%\java-setup"
cd /d "%TEMP%\java-setup"

echo.
echo Downloading Amazon Corretto JDK 21...
echo This may take a few minutes depending on your internet connection.
powershell -Command "& {Invoke-WebRequest -Uri 'https://corretto.aws/downloads/latest/amazon-corretto-21-x64-windows-jdk.msi' -OutFile 'amazon-corretto-21.msi'}"

if not exist "amazon-corretto-21.msi" (
    echo Failed to download the installer. Please check your internet connection and try again.
    echo You can also download it manually from: https://docs.aws.amazon.com/corretto/latest/corretto-21-ug/downloads-list.html
    goto cleanup
)

echo.
echo Download complete. Starting installation...
echo Please follow the installation wizard and make sure to check the option to set JAVA_HOME environment variable.
echo.
echo Press any key to start the installer...
pause > nul

start /wait msiexec /i amazon-corretto-21.msi /qn ADDLOCAL=ALL

echo.
echo Installation complete. Verifying installation...
echo.
echo Please open a new command prompt after this script finishes and run:
echo java -version
echo.
echo If you see output showing Amazon Corretto 21, the installation was successful.
echo.
echo If you don't see the correct output, please refer to JAVA_INSTALLATION.md for manual setup instructions.

:cleanup
echo.
echo Cleaning up temporary files...
cd /d "%USERPROFILE%"
rmdir /s /q "%TEMP%\java-setup"

echo.
echo Setup complete. Press any key to exit...
pause > nul