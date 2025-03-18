@echo off
setlocal EnableDelayedExpansion

:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% == 0 (
    goto :AdminRights
) else (
    echo Requesting administrative privileges...
    powershell Start-Process "%~f0" -Verb RunAs
    exit /b
)

:AdminRights
cls
echo Running with Administrator privileges.

:MainMenu
cls
echo DNS Changer Script
echo ---------------------
echo.
echo 1. Set DNS to Custom (Choose Provider)
echo 2. Disable Custom DNS (Revert to DHCP, Flush DNS, Reset Network)
echo.
set /p choice=Enter your choice (1 or 2): 

if "%choice%"=="1" goto :ChooseDNSProvider
if "%choice%"=="2" goto :DisableDNS_Extended
echo.
echo Invalid choice. Please enter 1 or 2.
pause
goto :MainMenu

:ChooseDNSProvider
cls
echo Choose DNS Provider:
echo ----------------------
echo.
echo 1. Cloudflare (1.1.1.1, 1.0.0.1) - Fast ^& Privacy Focused
echo 2. Google Public DNS (8.8.8.8, 8.8.4.4) - Reliable ^& Widely Used
echo 3. Quad9 (9.9.9.9, 149.112.112.112) - Security ^& Malware Blocking
echo 4. OpenDNS (208.67.222.222, 208.67.220.220) - Reliable with Filtering Options
echo.
set /p dns_choice=Enter your DNS provider choice (1-4): 

if "%dns_choice%"=="1" goto :SetDNS_Cloudflare
if "%dns_choice%"=="2" goto :SetDNS_Google
if "%dns_choice%"=="3" goto :SetDNS_Quad9
if "%dns_choice%"=="4" goto :SetDNS_OpenDNS
echo.
echo Invalid DNS provider choice. Please enter 1-4.
pause
goto :ChooseDNSProvider

:SetDNS_Cloudflare
set "primary_dns=1.1.1.1"
set "secondary_dns=1.0.0.1"
goto :SetDNS_Execute

:SetDNS_Google
set "primary_dns=8.8.8.8"
set "secondary_dns=8.8.4.4"
goto :SetDNS_Execute

:SetDNS_Quad9
set "primary_dns=9.9.9.9"
set "secondary_dns=149.112.112.112"
goto :SetDNS_Execute

:SetDNS_OpenDNS
set "primary_dns=208.67.222.222"
set "secondary_dns=208.67.220.220"
goto :SetDNS_Execute

:SetDNS_Execute
cls
echo Setting DNS to Primary: %primary_dns%, Secondary: %secondary_dns%...

:: List all network adapters and let user choose
echo.
echo Available Network Adapters:
echo --------------------------

:: Create a temporary file to store adapter names
set "temp_file=%temp%\adapters.txt"
wmic nic where "NetEnabled=true AND NetConnectionID IS NOT NULL" get NetConnectionID /value > "%temp_file%"

:: Count and display adapters
set "index=0"
for /f "tokens=2 delims==" %%a in ('type "%temp_file%" ^| findstr /r /c:"NetConnectionID="') do (
    set /a "index+=1"
    set "adapter[!index!]=%%a"
    echo !index!. %%a
)

del "%temp_file%" 2>nul

if !index! equ 0 (
    echo No active network adapters found.
    pause
    goto :MainMenu
)

echo.
set /p adapter_choice=Enter the number of your network adapter (1-%index%): 

:: Validate choice
if !adapter_choice! lss 1 (
    echo Invalid adapter choice.
    pause
    goto :MainMenu
)
if !adapter_choice! gtr !index! (
    echo Invalid adapter choice.
    pause
    goto :MainMenu
)

set "adapter_name=!adapter[%adapter_choice%]!"

echo.
echo Using Network Adapter: !adapter_name!

:: Set primary DNS (using interface name)
netsh interface ipv4 set dns name="!adapter_name!" static %primary_dns%
if %errorlevel% neq 0 (
    echo.
    echo Error setting primary DNS to %primary_dns%
    echo Error Code: %errorlevel%
    pause
    goto :MainMenu
)

:: Set secondary DNS
netsh interface ipv4 add dns name="!adapter_name!" %secondary_dns% index=2
if %errorlevel% neq 0 (
    echo.
    echo Error setting secondary DNS to %secondary_dns%
    echo Error Code: %errorlevel%
    pause
    goto :MainMenu
)

echo.
echo DNS successfully set to %primary_dns% and %secondary_dns% for adapter "!adapter_name!".
pause
goto :MainMenu

:DisableDNS_Extended
cls
echo Disabling custom DNS, reverting to DHCP, flushing DNS and resetting network...

:: List all network adapters and let user choose
echo.
echo Available Network Adapters:
echo --------------------------

:: Create a temporary file to store adapter names
set "temp_file=%temp%\adapters.txt"
wmic nic where "NetEnabled=true AND NetConnectionID IS NOT NULL" get NetConnectionID /value > "%temp_file%"

:: Count and display adapters
set "index=0"
for /f "tokens=2 delims==" %%a in ('type "%temp_file%" ^| findstr /r /c:"NetConnectionID="') do (
    set /a "index+=1"
    set "adapter[!index!]=%%a"
    echo !index!. %%a
)

del "%temp_file%" 2>nul

if !index! equ 0 (
    echo No active network adapters found.
    pause
    goto :MainMenu
)

echo.
set /p adapter_choice=Enter the number of your network adapter (1-%index%): 

:: Validate choice
if !adapter_choice! lss 1 (
    echo Invalid adapter choice.
    pause
    goto :MainMenu
)
if !adapter_choice! gtr !index! (
    echo Invalid adapter choice.
    pause
    goto :MainMenu
)

set "adapter_name=!adapter[%adapter_choice%]!"

echo.
echo Using Network Adapter: !adapter_name!

:: Revert DNS to DHCP
netsh interface ipv4 set dns "!adapter_name!" dhcp
if %errorlevel% neq 0 (
    echo.
    echo Error reverting DNS to DHCP
    echo Error Code: %errorlevel%
    pause
    goto :MainMenu
)

echo.
echo DNS reverted to DHCP for adapter "!adapter_name!".

:: Flush DNS Resolver Cache
ipconfig /flushdns
if %errorlevel% neq 0 (
    echo.
    echo Error flushing DNS resolver cache.
    echo Error Code: %errorlevel%
    echo Proceeding with network reset anyway...
) else (
    echo.
    echo DNS resolver cache flushed successfully.
)

:: Reset Winsock Catalog
netsh winsock reset catalog
if %errorlevel% neq 0 (
    echo.
    echo Error resetting Winsock catalog.
    echo Error Code: %errorlevel%
    echo Proceeding with network reset anyway...
) else (
    echo.
    echo Winsock catalog reset successfully.
)

:: Reset TCP/IP Stack
netsh int ip reset resetlog.txt
if %errorlevel% neq 0 (
    echo.
    echo Error resetting TCP/IP stack.
    echo Error Code: %errorlevel%
) else (
    echo.
    echo TCP/IP stack reset successfully.
    echo Please check "resetlog.txt" in the script's directory for reset details.
)

echo.
echo Network settings reset completed. You may need to restart your computer for some changes to take full effect.
pause
goto :MainMenu
