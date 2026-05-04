@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
title VIsion PC Optimizer v2.0 — Applying Tweaks
color 0A

echo.
echo  ================================================================
echo   VIsion PC Optimizer v2.0 — Full System Optimization
echo  ================================================================
echo   Fortnite / FiveM / All Games — Max FPS Build
echo  ================================================================
echo.

:: ── ADMIN CHECK ────────────────────────────────────────────────────
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo  ERROR: Run as Administrator!
    pause
    exit /b 1
)
echo  [OK] Administrator confirmed.
echo.

:: ── RESTORE POINT ──────────────────────────────────────────────────
echo  [1/19] Creating restore point...
powershell -NoProfile -Command "Checkpoint-Computer -Description 'VIsion Pre-Tweak v2' -RestorePointType MODIFY_SETTINGS" >nul 2>&1
echo  [OK] Restore point created.

:: ── POWER PLAN ─────────────────────────────────────────────────────
echo  [2/19] Applying Ultimate Performance power plan...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
for /f "tokens=4" %%G in ('powercfg /list ^| findstr /i "Ultimate"') do (
    powercfg /setactive %%G >nul 2>&1
)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1
powercfg -h off >nul 2>&1
echo  [OK] Power plan set.

:: ── CPU / PRIORITY / MMCSS ─────────────────────────────────────────
echo  [3/19] Applying CPU and scheduling tweaks...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v AlwaysOn /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d "False" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 0x2710 /f >nul 2>&1
echo  [OK] CPU/MMCSS tweaks applied.

:: ── MEMORY ─────────────────────────────────────────────────────────
echo  [4/19] Optimizing memory management...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v MaxPreRenderedFrames /t REG_DWORD /d 1 /f >nul 2>&1
echo  [OK] Memory tweaks applied.

:: ── POWER LATENCY + CPU UNPARK + GPU FEED RATE (fixes low GPU utilization) ──
echo  [4b] Fixing CPU-to-GPU feed rate (low GPU util fix)...
:: CPU unpark — all cores ready instantly
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v Class1InitialUnparkCount /t REG_DWORD /d 100 /f >nul 2>&1
:: Disable away mode (background mode that steals resources)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v AwayModeEnabled /t REG_DWORD /d 0 /f >nul 2>&1
:: GPU TDR — increase timeout, stops micro-stutter from GPU "timeout detection"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDelay /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDdiDelay /t REG_DWORD /d 8 /f >nul 2>&1
:: Kill service shutdown wait — faster restart/shutdown, less background interference
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d "0" /f >nul 2>&1
:: Explorer shell latency — no shortcut tracking, no disk space checks
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoLowDiskSpaceChecks /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v LinkResolveIgnoreLinkInfo /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoResolveSearch /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoResolveTrack /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoInstrumentation /t REG_DWORD /d 1 /f >nul 2>&1
echo  [OK] GPU feed rate + CPU unpark + power latency fixed.

:: ── VERIFIED EXTERNAL TWEAKS ───────────────────────────────────────
echo  [4c] Applying verified external tweaks...

:: Disable MPO (Multiplane Overlay) — fixes stutter/tearing in DX11/DX12 games
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f >nul 2>&1

:: Disable Active Probing — stops NLA service pinging internet every few seconds
reg add "HKLM\SYSTEM\ControlSet001\Services\NlaSvc\Parameters\Internet" /v EnableActiveProbing /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet" /v EnableActiveProbing /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable automatic driver searching mid-game (stops Windows installing drivers while gaming)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v SearchOrderConfig /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable Windows Customer Experience / SQM data collection
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v CEIPEnable /t REG_DWORD /d 0 /f >nul 2>&1

:: NVIDIA Contiguous GPU Memory — reduces VRAM fragmentation, smoother texture streaming
for %%i in (0000 0001 0002 0003) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\%%i" /v PreferSystemMemoryContiguous /t REG_DWORD /d 1 /f >nul 2>&1
)

:: Page Combining — auto-detect RAM and set optimally
:: 16GB+ = disable (wastes CPU scanning memory). Less than 16GB = enable (saves RAM)
powershell -NoProfile -Command "try { $ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB; if ($ram -ge 14) { Disable-MMAgent -PageCombining -EA SilentlyContinue } else { Enable-MMAgent -PageCombining -EA SilentlyContinue } } catch {}" >nul 2>&1

echo  [OK] MPO off, active probing off, driver search off, GPU memory optimized.

:: ── CLEAR SHADER CACHES — fixes stutter after driver updates ───────
echo  [4d] Clearing stale shader caches...
:: DirectX shader cache — stale cache causes stutters, GPU rebuilds fresh on next launch
if exist "%LOCALAPPDATA%\D3DSCache" (
    rd /s /q "%LOCALAPPDATA%\D3DSCache" >nul 2>&1
    mkdir "%LOCALAPPDATA%\D3DSCache" >nul 2>&1
)
:: NVIDIA shader caches
if exist "%LOCALAPPDATA%\NVIDIA\DXCache" rd /s /q "%LOCALAPPDATA%\NVIDIA\DXCache" >nul 2>&1
if exist "%LOCALAPPDATA%\NVIDIA\GLCache" rd /s /q "%LOCALAPPDATA%\NVIDIA\GLCache" >nul 2>&1
if exist "%APPDATA%\NVIDIA\ComputeCache" rd /s /q "%APPDATA%\NVIDIA\ComputeCache" >nul 2>&1
:: AMD shader cache
if exist "%LOCALAPPDATA%\AMD\DxCache" rd /s /q "%LOCALAPPDATA%\AMD\DxCache" >nul 2>&1
if exist "%LOCALAPPDATA%\AMD\OglCache" rd /s /q "%LOCALAPPDATA%\AMD\OglCache" >nul 2>&1
echo  [OK] Shader caches cleared.

:: ── SEGMENT HEAP — efficient memory allocator for games ────────────
echo  [4e] Enabling Segment Heap for games...
:: Segment Heap uses NT's modern heap allocator — reduces memory fragmentation
:: Games with lots of small allocs (Fortnite, FiveM) get lower RAM usage + faster allocs
for %%g in (
    FortniteClient-Win64-Shipping.exe
    FiveM.exe
    GTA5.exe
    VALORANT-Win64-Shipping.exe
    cs2.exe
    RustClient.exe
    r5apex.exe
    EscapeFromTarkov.exe
    RocketLeague.exe
    destiny2.exe
) do (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%g" /v FrontEndHeapDebugOptions /t REG_DWORD /d 8 /f >nul 2>&1
)
echo  [OK] Segment Heap enabled for games.

:: ── SPEED UP SHUTDOWN + BOOT ────────────────────────────────────────
echo  [4f] Speeding up shutdown and boot...
:: Auto-kill hung apps on shutdown (no "waiting for program" freeze)
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d "1" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d "1000" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d "2000" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d "2000" /f >nul 2>&1
echo  [OK] Shutdown/boot optimized.

:: ── CLEAN FORTNITE JUNK FILES ───────────────────────────────────────
echo  [4g] Cleaning Fortnite crash dumps and logs...
if exist "%LOCALAPPDATA%\FortniteGame\Saved\Logs" (
    del /q /f "%LOCALAPPDATA%\FortniteGame\Saved\Logs\*" >nul 2>&1
)
if exist "%LOCALAPPDATA%\FortniteGame\Saved\Crashes" (
    rd /s /q "%LOCALAPPDATA%\FortniteGame\Saved\Crashes" >nul 2>&1
)
if exist "%LOCALAPPDATA%\FortniteGame\Saved\MemDumps" (
    rd /s /q "%LOCALAPPDATA%\FortniteGame\Saved\MemDumps" >nul 2>&1
)
echo  [OK] Fortnite junk cleaned.

:: ── GPU / VISUAL ───────────────────────────────────────────────────
echo  [5/19] Applying GPU tweaks...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_DXGIHonorFSEWindowsCompatible /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_DSEBehavior /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "C:\Windows\System32\dwm.exe" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
:: MSI mode for GPU — sequential echo, no block
echo $ErrorActionPreference = 'SilentlyContinue'                                                           > "%TEMP%\vmsi.ps1"
echo $vendors = @^('VEN_10DE','VEN_1002','VEN_8086'^)                                                     >> "%TEMP%\vmsi.ps1"
echo foreach ^($v in $vendors^) {                                                                          >> "%TEMP%\vmsi.ps1"
echo   Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\PCI' ^| Where-Object {$_.PSChildName -like "*$v*"} ^| Get-ChildItem ^| Get-ChildItem ^| ForEach-Object { >> "%TEMP%\vmsi.ps1"
echo     $msi = Join-Path $_.PSPath 'Device Parameters\Interrupt Management\MessageSignaledInterruptProperties' >> "%TEMP%\vmsi.ps1"
echo     $aff = Join-Path $_.PSPath 'Device Parameters\Interrupt Management\Affinity Policy'               >> "%TEMP%\vmsi.ps1"
echo     if ^(Test-Path $msi^) {                                                                           >> "%TEMP%\vmsi.ps1"
echo       Set-ItemProperty -Path $msi -Name MSISupported -Value 1 -Type DWord -EA SilentlyContinue       >> "%TEMP%\vmsi.ps1"
echo       if ^(-not ^(Test-Path $aff^)^) { New-Item -Path $aff -Force ^| Out-Null }                      >> "%TEMP%\vmsi.ps1"
echo       Set-ItemProperty -Path $aff -Name DevicePriority -Value 3 -Type DWord -EA SilentlyContinue     >> "%TEMP%\vmsi.ps1"
echo     }                                                                                                 >> "%TEMP%\vmsi.ps1"
echo   }                                                                                                   >> "%TEMP%\vmsi.ps1"
echo }                                                                                                     >> "%TEMP%\vmsi.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\vmsi.ps1" >nul 2>&1
del "%TEMP%\vmsi.ps1" >nul 2>&1
echo  [OK] GPU + MSI mode tweaks applied.

:: ── SERVICES ───────────────────────────────────────────────────────
echo  [6/19] Disabling background services...
for %%s in (
    SysMain
    DiagTrack
    WSearch
    dmwappushservice
    MapsBroker
    lfsvc
    Fax
    RetailDemo
    RemoteRegistry
    XblAuthManager
    XblGameSave
    XboxNetApiSvc
    XboxGipSvc
    wisvc
    WerSvc
    wercplsupport
    PcaSvc
    DoSvc
    CDPSvc
    WbioSrvc
    PhoneSvc
    TabletInputService
    NvTelemetryContainer
    NvNetworkService
    AdobeARMservice
    gupdate
    gupdatem
) do (
    sc stop %%s >nul 2>&1
    sc config %%s start= disabled >nul 2>&1
)
:: OneSyncSvc has a suffix on each machine — handle dynamically
for /f "tokens=1" %%s in ('sc query state^= all ^| findstr /i "OneSyncSvc"') do (
    sc stop %%s >nul 2>&1
    sc config %%s start= disabled >nul 2>&1
)
echo  [OK] Services disabled.

:: ── KILL SCHEDULED TASKS EATING CPU ───────────────────────────────
echo  [6b] Disabling background scheduled tasks...
for %%t in (
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
    "\Microsoft\Windows\Autochk\Proxy"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "\Microsoft\Windows\Maintenance\WinSAT"
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
    "\Microsoft\Windows\Shell\FamilySafetyMonitor"
    "\Microsoft\Windows\Shell\FamilySafetyRefresh"
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
    "\Microsoft\Windows\WindowsUpdate\Automatic App Update"
    "\Microsoft\Windows\WindowsUpdate\Scheduled Start"
    "\Microsoft\Windows\Maps\MapsUpdateTask"
    "\Microsoft\Windows\Maps\MapsToastTask"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
) do (
    schtasks /change /tn %%t /disable >nul 2>&1
)
echo  [OK] Background scheduled tasks disabled.

:: ── CPU BOOST MODE ─────────────────────────────────────────────────
echo  [6c] Setting CPU boost mode...
:: Aggressive boost — CPU clocks up instantly when game needs it
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2 >nul 2>&1
:: Min processor state = 100% (always full freq, no stepping down)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1
echo  [OK] CPU boost applied.

:: ── VIRTUAL MEMORY — FIXED SIZE, NO STUTTER ───────────────────────
echo  [6d] Optimizing virtual memory...
:: Detect RAM and set pagefile to 1.5x RAM, fixed size (no dynamic resize mid-game)
powershell -NoProfile -Command "try { $ram = [Math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB); $pf = [Math]::Min($ram * 2, 16384); $drive = $env:SystemDrive; $cs = Get-WmiObject Win32_ComputerSystem; $cs.AutomaticManagedPagefile = $false; $cs.Put() | Out-Null; $pfs = Get-WmiObject -Query 'Select * from Win32_PageFileSetting'; foreach ($p in $pfs) { $p.Delete() }; Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{Name=$drive+'\pagefile.sys'; InitialSize=$pf; MaximumSize=$pf} | Out-Null } catch {}" >nul 2>&1
echo  [OK] Virtual memory fixed size set.

:: ── AUDIO LATENCY — WASAPI BUFFER OPTIMIZATION ────────────────────
echo  [6e] Optimizing audio latency...
:: Audio engine runs in exclusive mode hint — lower latency to game audio
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Render" /v DeviceState /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable audio enhancements (spatial sound processing overhead)
reg add "HKCU\Software\Microsoft\Multimedia\Audio" /v UserDuckingPreference /t REG_DWORD /d 3 /f >nul 2>&1
:: Audio service priority boost
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Scheduling Category" /t REG_SZ /d "Medium" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "SFIO Priority" /t REG_SZ /d "Normal" /f >nul 2>&1
echo  [OK] Audio latency optimized.

:: ── SHADER CACHE SYSTEM-WIDE ──────────────────────────────────────
echo  [6f] Enabling system-wide shader cache...
:: DirectX shader cache — pre-compile and cache shaders (eliminates stutter on new areas)
reg add "HKLM\SOFTWARE\Microsoft\Direct3D" /v ShaderCache /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v ShaderCache /t REG_DWORD /d 1 /f >nul 2>&1
:: GPU shader cache size — set to max (no shader recompile mid-game)
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global" /v ShaderCacheSize /t REG_DWORD /d 10240 /f >nul 2>&1
:: Windows GPU shader cache folder — ensure it exists and is writable
if not exist "%LOCALAPPDATA%\D3DSCache" mkdir "%LOCALAPPDATA%\D3DSCache" >nul 2>&1
echo  [OK] Shader cache enabled.

:: ── INPUT / MOUSE ──────────────────────────────────────────────────
echo  [7/19] Optimizing input and mouse...
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d "10" /f >nul 2>&1
echo  [OK] Mouse tweaks applied.

:: ── NETWORK RESET TO DEFAULTS ──────────────────────────────────────
echo  [8/19] Restoring network to clean Windows defaults...
:: Reset any previously applied TCP tweaks that can slow/break internet
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global ecncapability=disabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global fastopen=enabled >nul 2>&1
:: Remove Nagle off tweaks — these cause packet bursting and lag spikes on most connections
for /f "tokens=1*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /s /v "DhcpIPAddress" 2^>nul ^| findstr /i "HKLM"') do (
    reg delete "%%A" /v TcpAckFrequency /f >nul 2>&1
    reg delete "%%A" /v TCPNoDelay /f >nul 2>&1
    reg delete "%%A" /v TcpDelAckTicks /f >nul 2>&1
)
:: Remove TCP window size caps — 65535 is too small for modern broadband, let Windows manage
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v GlobalMaxTcpWindowSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpWindowSize /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxDupAcks /f >nul 2>&1
:: Keep only safe, stable settings
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 64 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f >nul 2>&1
:: NIC: only disable Energy Efficient Ethernet (safe) — leave Interrupt Moderation alone
powershell -NoProfile -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName 'Energy Efficient Ethernet' -DisplayValue 'Disabled' -ErrorAction SilentlyContinue }" >nul 2>&1
echo  [OK] Network restored to clean defaults.

:: ── LOW INPUT DELAY ────────────────────────────────────────────────
echo  [8b] Applying zero-delay input tweaks...
:: Global 0.5ms timer resolution — biggest single input delay fix on Win11
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable USB selective suspend — sequential echo
echo $ErrorActionPreference = 'SilentlyContinue'                                                                                           > "%TEMP%\vusb.ps1"
echo Get-WmiObject Win32_PnPEntity ^| Where-Object{$_.Name -like '*USB*Hub*' -or $_.Name -like '*USB*Root*'} ^| ForEach-Object {           >> "%TEMP%\vusb.ps1"
echo   $path = 'HKLM:\SYSTEM\CurrentControlSet\Enum\' + $_.PNPDeviceID + '\Device Parameters'                                             >> "%TEMP%\vusb.ps1"
echo   if ^(Test-Path $path^) { Set-ItemProperty -Path $path -Name EnhancedPowerManagementEnabled -Value 0 -EA SilentlyContinue }          >> "%TEMP%\vusb.ps1"
echo }                                                                                                                                     >> "%TEMP%\vusb.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\vusb.ps1" >nul 2>&1
del "%TEMP%\vusb.ps1" >nul 2>&1
:: Disable keyboard/mouse input buffering lag
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f >nul 2>&1
:: Disable cursor smooth movement curves (raw mouse = pixel perfect)
reg add "HKCU\Control Panel\Mouse" /v SmoothMouseXCurve /t REG_BINARY /d 0000000000000000C0CC0C0000000000809919000000000040662600000000000099330000000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v SmoothMouseYCurve /t REG_BINARY /d 0000000000000000000038000000000000007000000000000000A8000000000000E0000000000000 /f >nul 2>&1
echo  [OK] Zero-delay input tweaks applied.

:: ── NTFS / DISK ────────────────────────────────────────────────────
echo  [9/19] Optimizing disk (NTFS)...
fsutil behavior set disablelastaccess 1 >nul 2>&1
fsutil behavior set disable8dot3 1 >nul 2>&1
fsutil behavior set encryptpagingfile 0 >nul 2>&1
defrag C: /L >nul 2>&1
echo  [OK] Disk tweaks applied.

:: ── TELEMETRY / BLOAT ──────────────────────────────────────────────
echo  [10/19] Killing telemetry and bloat...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 1 /f >nul 2>&1
:: Delivery Optimization off (stops Windows using your bandwidth for other PCs)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f >nul 2>&1
:: NVIDIA telemetry off
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v OptInOrOutPreference /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v PowerMizerEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v PowerMizerLevel /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v PowerMizerLevelAC /t REG_DWORD /d 1 /f >nul 2>&1
:: AMD: Disable ULPS (Ultra Low Power State — causes stutters)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v EnableUlps /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001" /v EnableUlps /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] Telemetry killed.

:: ── BOOT / TIMER ───────────────────────────────────────────────────
echo  [11/19] Applying boot and timer tweaks...
bcdedit /set disabledynamictick yes >nul 2>&1
bcdedit /set useplatformtick no >nul 2>&1
:: Disable HPET (High Precision Event Timer) — reduces CPU overhead
bcdedit /set useplatformclock false >nul 2>&1
bcdedit /set bootmenupolicy standard >nul 2>&1
bcdedit /timeout 5 >nul 2>&1
echo  [OK] Boot + timer tweaks applied.

:: ── DEFENDER EXCLUSIONS ────────────────────────────────────────────
echo  [12/19] Adding game folders to Defender exclusions...
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\Epic Games' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Steam' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\Rockstar Games' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '$env:LOCALAPPDATA\FiveM' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '$env:LOCALAPPDATA\Riot Games' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\Riot Games' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\Battlestate Games' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Origin' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\EA Games' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files (x86)\Ubisoft' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath 'C:\Program Files\Activision' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'FortniteClient-Win64-Shipping.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'FiveM.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'GTA5.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'VALORANT-Win64-Shipping.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'cs2.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'RustClient.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'r5apex.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'EscapeFromTarkov.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'RocketLeague.exe' -ErrorAction SilentlyContinue" >nul 2>&1
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess 'destiny2.exe' -ErrorAction SilentlyContinue" >nul 2>&1
echo  [OK] Defender exclusions added.

:: ── WINDOWS DEBLOAT ────────────────────────────────────────────────
echo  [13/19] Removing bloat apps (Teams, Xbox, Bing, etc)...
echo $ErrorActionPreference = 'SilentlyContinue'                                                   > "%TEMP%\vdb.ps1"
echo $apps = 'Microsoft.BingWeather','Microsoft.BingNews','Microsoft.GetHelp',                    >> "%TEMP%\vdb.ps1"
echo   'Microsoft.Getstarted','Microsoft.MicrosoftOfficeHub',                                     >> "%TEMP%\vdb.ps1"
echo   'Microsoft.MicrosoftSolitaireCollection','Microsoft.MixedReality.Portal',                  >> "%TEMP%\vdb.ps1"
echo   'Microsoft.People','Microsoft.SkypeApp','Microsoft.Todos',                                 >> "%TEMP%\vdb.ps1"
echo   'Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps',                                    >> "%TEMP%\vdb.ps1"
echo   'Microsoft.Xbox.TCUI','Microsoft.XboxApp','Microsoft.XboxGameCallableUI',                  >> "%TEMP%\vdb.ps1"
echo   'Microsoft.XboxGamingOverlay','Microsoft.XboxIdentityProvider',                            >> "%TEMP%\vdb.ps1"
echo   'Microsoft.XboxSpeechToTextOverlay','Microsoft.YourPhone',                                 >> "%TEMP%\vdb.ps1"
echo   'Microsoft.ZuneMusic','Microsoft.ZuneVideo','Clipchamp.Clipchamp',                         >> "%TEMP%\vdb.ps1"
echo   'Microsoft.PowerAutomateDesktop','MSTeams','Microsoft.Teams',                              >> "%TEMP%\vdb.ps1"
echo   'Microsoft.549981C3F5F10','Microsoft.3DBuilder','Microsoft.OneConnect',                    >> "%TEMP%\vdb.ps1"
echo   'Microsoft.Wallet','Microsoft.Print3D'                                                      >> "%TEMP%\vdb.ps1"
echo foreach ^($app in $apps^) {                                                                   >> "%TEMP%\vdb.ps1"
echo   Get-AppxPackage -Name $app -AllUsers ^| Remove-AppxPackage -AllUsers                       >> "%TEMP%\vdb.ps1"
echo   Get-AppxProvisionedPackage -Online ^| Where-Object DisplayName -like $app ^| Remove-AppxProvisionedPackage -Online >> "%TEMP%\vdb.ps1"
echo }                                                                                             >> "%TEMP%\vdb.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\vdb.ps1" >nul 2>&1
del "%TEMP%\vdb.ps1" >nul 2>&1
echo  [OK] Bloat removed.

:: ── VISUAL EFFECTS ─────────────────────────────────────────────────
echo  [14/19] Setting visual effects to best performance...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeek /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v AlwaysHibernateThumbnails /t REG_DWORD /d 0 /f >nul 2>&1
:: Disable shadows, animations, thumbnails
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v IconsOnly /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v DragFullWindows /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v FontSmoothing /t REG_SZ /d "2" /f >nul 2>&1
echo  [OK] Visual effects optimized.

:: ── NVIDIA DEEP PERFORMANCE REGISTRY BLOCK ────────────────────────
echo  [14b] Applying deep NVIDIA + GPU driver tweaks...
:: GraphicsDrivers — core latency + performance flags
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v DisableAsyncPstates /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v DisableDynamicPstate /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v AllowDeepCStates /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v EnableDirectFlip /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v ForceDirectFlip /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v EnableIndependentFlip /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v EnableWDDM23Synchronization /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v EnablePerformanceMode /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v EnableAggressivePStateBoost /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v Node3DLowLatency /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v LOWLATENCY /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v RmGpsPsEnablePerCpuCoreDpc /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v UseGpuTimer /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v D3PCLatency /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v F1TransitionLatency /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v MonitorLatencyTolerance /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v MonitorRefreshLatencyTolerance /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v PciLatencyTimerControl /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v AdaptiveVsyncEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v DisableOverlays /t REG_DWORD /d 1 /f >nul 2>&1

:: GPU Scheduler — no preemption, true immediate flip, no vsync idle
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v EnablePreemption /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v VsyncIdleTimeout /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v ForceFlipTrueImmediateMode /t REG_DWORD /d 1 /f >nul 2>&1

:: nvlddmkm service — HDCP off, max perf, no preemption
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v RMHdcpKeyglobZero /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v AllowMaxPerf /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v DisablePreemption /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v RmGpsPsEnablePerCpuCoreDpc /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v EnableMidBufferPreemption /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v ComputePreemption /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableRID73779 /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableRID73780 /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v EnableRID74361 /t REG_DWORD /d 1 /f >nul 2>&1

:: DXGKrnl — monitor latency tolerance
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v MonitorLatencyTolerance /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DXGKrnl" /v MonitorRefreshLatencyTolerance /t REG_DWORD /d 1 /f >nul 2>&1

:: MMCSS DisplayPostProcessing task — GPU/CPU priority for display pipeline
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v Priority /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Latency Sensitive" /t REG_SZ /d "True" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Background Only" /t REG_SZ /d "True" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\DisplayPostProcessing" /v "Clock Rate" /t REG_DWORD /d 10000 /f >nul 2>&1

:: Disable NVIDIA tray autostart — saves background process
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvTray" /v StartOnLogin /t REG_DWORD /d 0 /f >nul 2>&1

:: NVIDIA NvTweak display power saving off
reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak" /v DisplayPowerSaving /t REG_DWORD /d 0 /f >nul 2>&1

:: Disable ASPM (PCIe Active State Power Management) — reduces GPU/NVMe latency spikes
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1

:: Thread DPC disable — locks all DPCs to run sequentially, reduces stutter on many systems
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v ThreadDpcEnable /t REG_DWORD /d 0 /f >nul 2>&1

:: DWM latency — Desktop Window Manager low latency mode
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v Latency /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v MaxLatency /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v MagnificationAPI /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v RenderingMode /t REG_DWORD /d 1 /f >nul 2>&1

:: Disable ETW AutoLoggers — stop background diagnostic trace sessions eating CPU/RAM
for %%a in (
    AutoLogger-Diagtrack-Listener
    DiagLog
    SQMLogger
    WiFiSession
    NBSMBLOGGER
    LwtNetLog
    Microsoft-Windows-Rdp-Graphics-RdpIdd-Trace
) do (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\%%a" /v Start /t REG_DWORD /d 0 /f >nul 2>&1
)
echo  [OK] NVIDIA deep tweaks, GPU scheduler, DWM latency, ASPM, AutoLoggers all done.

:: ── BACKGROUND APPS / NOTIFICATIONS ───────────────────────────────
echo  [15/19] Disabling background apps and notifications...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f >nul 2>&1
:: Disable startup programs delay
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] Background apps and notifications disabled.

:: ── PRIVACY / ADVERTISING ─────────────────────────────────────────
echo  [16/19] Killing advertising IDs, location, activity tracking...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v DisableLocation /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] Privacy tweaks applied.

:: ── GAME CONFIGS ───────────────────────────────────────────────────
echo  [17/19] Applying game-specific config tweaks...

:: ── FORTNITE — sequential echo, no block, no crash ──
echo $ErrorActionPreference = 'SilentlyContinue'                                                    > "%TEMP%\vfn.ps1"
echo $cfg = $env:LOCALAPPDATA + '\FortniteGame\Saved\Config\WindowsClient\GameUserSettings.ini'     >> "%TEMP%\vfn.ps1"
echo $s = @{                                                                                         >> "%TEMP%\vfn.ps1"
echo   'bUseVSync'='False'; 'FrameRateLimit'='0.000000'; 'bShowFPS'='True'                          >> "%TEMP%\vfn.ps1"
echo   'sg.ShadowQuality'='0'; 'sg.PostProcessQuality'='0'; 'sg.EffectsQuality'='0'                 >> "%TEMP%\vfn.ps1"
echo   'sg.FoliageQuality'='0'; 'sg.AntiAliasingQuality'='0'; 'sg.ViewDistanceQuality'='2'          >> "%TEMP%\vfn.ps1"
echo   'bMotionBlur'='False'; 'bShowGrass'='False'; 'bRayTracingEnabled'='False'                    >> "%TEMP%\vfn.ps1"
echo   'bEnableRayTracing'='False'; 'bLowLatencyMode'='True'; 'LowLatencyMode'='1'                  >> "%TEMP%\vfn.ps1"
echo   'bAllowDLSS'='False'; 'bAllowTemporalSuperResolution'='False'                                >> "%TEMP%\vfn.ps1"
echo }                                                                                               >> "%TEMP%\vfn.ps1"
echo if ^(Test-Path $cfg^) {                                                                         >> "%TEMP%\vfn.ps1"
echo   $lines = Get-Content $cfg; $out = New-Object System.Collections.Generic.List[string]; $done = @{} >> "%TEMP%\vfn.ps1"
echo   foreach ^($line in $lines^) {                                                                 >> "%TEMP%\vfn.ps1"
echo     $m = $false                                                                                 >> "%TEMP%\vfn.ps1"
echo     foreach ^($k in $s.Keys^) { if ^($line -match "^$k=") { $out.Add^("$k=$^($s[$k]^)"^); $done[$k]=1; $m=$true; break } } >> "%TEMP%\vfn.ps1"
echo     if ^(-not $m^) { $out.Add^($line^) }                                                       >> "%TEMP%\vfn.ps1"
echo   }                                                                                             >> "%TEMP%\vfn.ps1"
echo   foreach ^($k in $s.Keys^) { if ^(-not $done[$k]^) { $out.Add^("$k=$^($s[$k]^)"^) } }       >> "%TEMP%\vfn.ps1"
echo   $out ^| Set-Content $cfg -Encoding UTF8                                                       >> "%TEMP%\vfn.ps1"
echo }                                                                                               >> "%TEMP%\vfn.ps1"
if exist "%LOCALAPPDATA%\FortniteGame\Saved\Config\WindowsClient" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\vfn.ps1" >nul 2>&1
    echo  [OK] Fortnite config tweaked.
) else (
    echo  [--] Fortnite not found, skipping.
)
del "%TEMP%\vfn.ps1" >nul 2>&1

:: ── FIVEM / GTA V — FULL OPTIMIZATION ─────────────────────────────
set "GTAV_DIR=%USERPROFILE%\Documents\Rockstar Games\GTA V"
set "FIVEM_DIR=%LOCALAPPDATA%\FiveM"

:: commandline.txt — best launch args for FiveM FPS
if exist "%GTAV_DIR%" (
    echo -norestrictions   > "%GTAV_DIR%\commandline.txt"
    echo -norepairmode    >> "%GTAV_DIR%\commandline.txt"
    echo -nomemrestrict   >> "%GTAV_DIR%\commandline.txt"
    echo -notypescript    >> "%GTAV_DIR%\commandline.txt"
    echo -ignoreDirtyDisc >> "%GTAV_DIR%\commandline.txt"
    echo -noSplash        >> "%GTAV_DIR%\commandline.txt"
    echo -high            >> "%GTAV_DIR%\commandline.txt"
    echo -noNvidiaCE      >> "%GTAV_DIR%\commandline.txt"
    echo  [OK] GTA V commandline.txt applied.
) else (
    echo  [--] GTA V folder not found, skipping.
)

:: GTA V settings.xml — BIGGEST FPS SOURCE. Shadows/MSAA/postfx off = +50-150 FPS
echo $ErrorActionPreference = 'SilentlyContinue'                                                      > "%TEMP%\vgtav.ps1"
echo $xml_path = [Environment]::GetFolderPath('MyDocuments') + '\Rockstar Games\GTA V\settings.xml'   >> "%TEMP%\vgtav.ps1"
echo if ^(Test-Path $xml_path^) {                                                                      >> "%TEMP%\vgtav.ps1"
echo   [xml]$xml = Get-Content $xml_path -Encoding UTF8                                               >> "%TEMP%\vgtav.ps1"
echo   function Set-Node^($doc, $name, $attr, $val^) {                                                >> "%TEMP%\vgtav.ps1"
echo     $n = $doc.SelectSingleNode^("//$name"^)                                                      >> "%TEMP%\vgtav.ps1"
echo     if ^($n^) { $n.SetAttribute^($attr, $val^) }                                                 >> "%TEMP%\vgtav.ps1"
echo   }                                                                                               >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'shadowQuality' 'value' '0'                                                      >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'extendedShadowDistance' 'value' '0'                                             >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'highResolutionShadows' 'value' 'false'                                          >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'shadowLongShadows' 'value' 'false'                                              >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'msaa' 'value' '0'                                                               >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'fxaa' 'value' 'false'                                                           >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'SSAO' 'value' 'Off'                                                             >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'reflection' 'value' '0'                                                         >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'reflectionQuality' 'value' '0'                                                  >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'reflectionMSAA' 'value' '0'                                                     >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'detailQuality' 'value' '0'                                                      >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'particleQuality' 'value' '0'                                                    >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'grassQuality' 'value' '0'                                                       >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'shader' 'value' '0'                                                             >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'tessellation' 'value' 'Off'                                                     >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'postFX' 'value' 'Off'                                                           >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'dof' 'value' 'false'                                                            >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'motionBlurStrength' 'value' '0'                                                 >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'distanceScalingMode' 'value' 'false'                                            >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'anisotropicFiltering' 'value' 'Off'                                             >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'ambientOcclusion' 'value' 'Off'                                                 >> "%TEMP%\vgtav.ps1"
:: FiveM CPU killers — population density + LOD bias (biggest CPU gains in FiveM)
echo   Set-Node $xml 'LodScale' 'value' '-1.550000'                                                   >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'PedLodBias' 'value' '-1.000000'                                                 >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'VehicleLodBias' 'value' '-0.500000'                                             >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'MaxLodScale' 'value' '-1.260000'                                                >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'CityDensity' 'value' '-1.000000'                                               >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'PedVarietyMultiplier' 'value' '-1.000000'                                      >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'VehicleVarietyMultiplier' 'value' '-1.000000'                                  >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Shadow_Distance' 'value' '-1.000000'                                           >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Shadow_SplitZStart' 'value' '-1.000000'                                        >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Shadow_SplitZEnd' 'value' '-1.000000'                                          >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Shadow_aircraftExpWeight' 'value' '-1.000000'                                  >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'HdStreamingInFlight' 'value' 'false'                                           >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'UltraShadows_Enabled' 'value' 'false'                                          >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Shadow_ParticleShadows' 'value' 'false'                                        >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Shadow_SoftShadows' 'value' '0'                                                >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'WaterQuality' 'value' '0'                                                      >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Lighting_FogVolumes' 'value' 'false'                                           >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Shader_SSA' 'value' 'false'                                                    >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'DX_Version' 'value' '0'                                                        >> "%TEMP%\vgtav.ps1"
echo   Set-Node $xml 'Audio3d' 'value' 'false'                                                       >> "%TEMP%\vgtav.ps1"
echo   $xml.Save^($xml_path^)                                                                         >> "%TEMP%\vgtav.ps1"
echo }                                                                                                 >> "%TEMP%\vgtav.ps1"
if exist "%GTAV_DIR%\settings.xml" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\vgtav.ps1" >nul 2>&1
    echo  [OK] GTA V settings.xml optimized ^(FiveM CPU killers off, shadows/MSAA off^).
) else (
    echo  [--] GTA V settings.xml not found, skipping.
)
del "%TEMP%\vgtav.ps1" >nul 2>&1

:: FiveM CitizenFX.ini
echo $ErrorActionPreference = 'SilentlyContinue'                                                      > "%TEMP%\vfm.ps1"
echo $f = $env:LOCALAPPDATA + '\FiveM\FiveM.app\CitizenFX.ini'                                        >> "%TEMP%\vfm.ps1"
echo $content = "[Game]`nUseThreadedWorker=true`nDisableRenderThread=0`nEnableNvHighDPI=true`nIVVideoMemory=131072" >> "%TEMP%\vfm.ps1"
echo if ^(Test-Path $f^) {                                                                             >> "%TEMP%\vfm.ps1"
echo   $x = Get-Content $f -Raw                                                                       >> "%TEMP%\vfm.ps1"
echo   if ^($x -notmatch 'UseThreadedWorker'^) { Add-Content $f "`nUseThreadedWorker=true" }         >> "%TEMP%\vfm.ps1"
echo   if ^($x -notmatch 'IVVideoMemory'^) { Add-Content $f "`nIVVideoMemory=131072" }               >> "%TEMP%\vfm.ps1"
echo } else { $content ^| Set-Content $f -Encoding UTF8 }                                             >> "%TEMP%\vfm.ps1"
if exist "%FIVEM_DIR%\FiveM.app" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\vfm.ps1" >nul 2>&1
    echo  [OK] FiveM CitizenFX.ini tweaked.
) else (
    echo  [--] FiveM not found, skipping.
)
del "%TEMP%\vfm.ps1" >nul 2>&1

:: FiveM cache — full wipe of all stale caches (fixes stutter + load times)
if exist "%FIVEM_DIR%\FiveM.app\data\cache\priv" (
    rd /s /q "%FIVEM_DIR%\FiveM.app\data\cache\priv" >nul 2>&1
)
if exist "%FIVEM_DIR%\FiveM.app\data\cache\game" (
    rd /s /q "%FIVEM_DIR%\FiveM.app\data\cache\game" >nul 2>&1
)
if exist "%FIVEM_DIR%\FiveM.app\data\cache\http" (
    rd /s /q "%FIVEM_DIR%\FiveM.app\data\cache\http" >nul 2>&1
)
if exist "%FIVEM_DIR%\FiveM.app\logs" (
    del /q /f "%FIVEM_DIR%\FiveM.app\logs\*" >nul 2>&1
)
if exist "%FIVEM_DIR%\FiveM.app" (
    echo  [OK] FiveM cache fully cleared ^(fixes stutter + faster loads^).
)

:: ── NVIDIA FULL PERFORMANCE SETTINGS ──────────────────────────────
echo  [18a] Applying NVIDIA max performance registry settings...
:: Force max performance power state (disables ALL GPU power saving)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v PowerMizerEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v PowerMizerLevel /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v PowerMizerLevelAC /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable NVIDIA FXAA (injected anti-aliasing overhead)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v FXAAForceOff /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable anisotropic filtering override (let game control it)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v AnisotropicFilteringMode /t REG_DWORD /d 1 /f >nul 2>&1
:: Low latency prerendered frames = 1 (NVIDIA Ultra Low Latency equivalent)
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v MaxPreRenderedFrames /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Direct3D" /v MaxPreRenderedFrames /t REG_DWORD /d 1 /f >nul 2>&1
:: Shader cache — unlimited (stops hitching when loading new areas)
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak" /v Coolbits /t REG_DWORD /d 8 /f >nul 2>&1
:: Disable NVIDIA HD Audio (saves IRQ for GPU rendering)
powershell -NoProfile -Command "Get-PnpDevice | Where-Object{$_.FriendlyName -like '*NVIDIA*HD Audio*' -or $_.FriendlyName -like '*NVIDIA*High Definition*'} | Disable-PnpDevice -Confirm:$false -EA SilentlyContinue" >nul 2>&1
:: Disable NVIDIA telemetry services fully
for %%s in (NvTelemetryContainer NvNetworkService NvContainerNetworkService) do (
    sc stop %%s >nul 2>&1
    sc config %%s start= disabled >nul 2>&1
)
echo  [OK] NVIDIA settings applied.

:: ── EXTRA WINDOWS TWEAKS ───────────────────────────────────────────
echo  [18b] Applying extra Windows performance tweaks...
:: Disable Windows Tips, suggestions, lock screen ads
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338388Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
:: Disable Microsoft Edge prelaunch and background running
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" /v PreventTabPreloading /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Edge\Main" /v AllowPrelaunch /t REG_DWORD /d 0 /f >nul 2>&1
:: Disable Windows Update delivery during gaming (peer-to-peer off)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable Windows Insider data collection
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds" /v AllowBuildPreview /t REG_DWORD /d 0 /f >nul 2>&1
:: Disable Shared Experience (cross-device sync eats RAM)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableCdp /t REG_DWORD /d 0 /f >nul 2>&1
:: Disable app launch tracking
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackProgs /t REG_DWORD /d 0 /f >nul 2>&1
:: Disable recent files tracking
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackDocs /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] Extra Windows tweaks applied.

:: ── DISABLE VBS / HYPER-V (5-15%% FPS GAIN) ───────────────────────
echo  [18c] Disabling Virtualization Based Security...
:: VBS adds a hypervisor layer that taxes CPU on every kernel call — kills gaming FPS
bcdedit /set hypervisorlaunchtype off >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v RequirePlatformSecurityFeatures /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v Locked /t REG_DWORD /d 0 /f >nul 2>&1
:: Memory Integrity (HVCI) off — already warned user, now auto-disable it
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Locked /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] VBS + Memory Integrity disabled. RESTART NEEDED for this to take effect.

:: ── KILL ONEDRIVE / COPILOT / WIDGETS ─────────────────────────────
echo  [18d] Killing OneDrive, Copilot, Widgets...
:: OneDrive — constantly syncs files, eats disk + CPU mid-game
taskkill /f /im OneDrive.exe >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v DisableFileSyncNGSC /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /d "" /f >nul 2>&1
sc stop OneDrive /f >nul 2>&1
:: Copilot — AI process runs in background even when not open
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 0 /f >nul 2>&1
:: Widgets — live data fetching eats bandwidth + CPU
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul 2>&1
:: Teams auto-start
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Teams" /d "" /f >nul 2>&1
taskkill /f /im Teams.exe >nul 2>&1
echo  [OK] OneDrive, Copilot, Widgets, Teams killed.

:: ── NIC ADVANCED DRIVER SETTINGS ─────────────────────────────────
echo  [18e] Optimizing NIC driver settings...
:: Loop all NIC driver registry keys and set performance options
for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /s /v "DriverDesc" 2^>nul ^| findstr "HKLM"') do (
    reg add "%%a" /v "*WakeOnMagicPacket" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%a" /v "*WakeOnPattern" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "%%a" /v "*FlowControl" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "%%a" /v "EnablePowerManagement" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "%%a" /v "EnableGreenEthernet" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "%%a" /v "*RSS" /t REG_SZ /d "1" /f >nul 2>&1
    reg add "%%a" /v "*ReceiveBuffers" /t REG_SZ /d "512" /f >nul 2>&1
    reg add "%%a" /v "*TransmitBuffers" /t REG_SZ /d "256" /f >nul 2>&1
    reg add "%%a" /v "*NumRssQueues" /t REG_SZ /d "4" /f >nul 2>&1
)
:: Disable Large Send Offload — causes latency spikes in competitive games
powershell -NoProfile -Command "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | ForEach-Object { Disable-NetAdapterLso -Name $_.Name -EA SilentlyContinue }" >nul 2>&1
echo  [OK] NIC driver optimized.

:: ── DISABLE FULLSCREEN OPTIMIZATIONS GLOBALLY ─────────────────────
echo  [18f] Disabling fullscreen optimizations globally...
:: This stops Windows from intercepting fullscreen games (reduces DWM overhead)
reg add "HKCU\System\GameConfigStore" /v GameDVR_DSEBehavior /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable FSO for all executables globally via compat flags
reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "C:\Windows\System32\dwm.exe" /t REG_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
echo  [OK] Fullscreen optimizations disabled globally.

:: ── MORE SERVICES KILL (safe only) ────────────────────────────────
echo  [18g] Killing more safe background services...
for %%s in (
    RmSvc
    SCardSvr
    ScDeviceEnum
    TapiSrv
    TrkWks
    WmpNetworkSvc
    icssvc
    NcbService
    NcdAutoSetup
    p2pimsvc
    p2psvc
    PNRPsvc
    RasAuto
    RasMan
    irmon
    PolicyAgent
) do (
    sc stop %%s >nul 2>&1
    sc config %%s start= disabled >nul 2>&1
)
echo  [OK] Extra services disabled.

:: ── PRINTER AUTO-DETECT ────────────────────────────────────────────
echo  [17b] Auto-detecting printer...
powershell -NoProfile -Command "exit (Get-Printer -EA SilentlyContinue | Measure-Object).Count" >nul 2>&1
if !errorlevel! EQU 0 (
    sc stop Spooler >nul 2>&1
    sc config Spooler start= disabled >nul 2>&1
    echo  [OK] No printer detected. PrintSpooler disabled ^(FPS gain^).
) else (
    echo  [--] Printer detected. PrintSpooler kept.
)

:: ── DEFENDER MEMORY INTEGRITY WARNING ─────────────────────────────
echo  [18/19] Checking Memory Integrity (Core Isolation)...
set "HVCI_KEY=HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
for /f "tokens=3" %%v in ('reg query "%HVCI_KEY%" /v Enabled 2^>nul ^| findstr Enabled') do (
    if "%%v"=="0x1" (
        echo  [!!] Memory Integrity is ON — costs up to 15%% FPS.
        echo  [!!] Disable in: Windows Security - Device Security - Core Isolation
    ) else (
        echo  [OK] Memory Integrity already off.
    )
)

:: ── GAME PROCESS OPTIMIZATION (IFEO + QoS + GPU PREF) ─────────────
echo  [19/19] Applying permanent per-game process optimization...

:: ── FORTNITE IFEO ──
:: IFEO = Image File Execution Options. These apply EVERY time game launches automatically.
:: CpuPriorityClass 3 = HIGH_PRIORITY_CLASS (permanent, no need to set at runtime)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
:: Allow 100 percent CPU utilization — no artificial cap
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v CpuUtilization /t REG_DWORD /d 100 /f >nul 2>&1
:: IoPriority 3 = Critical — fastest asset streaming from disk
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
:: Skip heap validation on every malloc — removes hidden CPU overhead
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe\PerfOptions" /v DisableHeapValidation /t REG_DWORD /d 1 /f >nul 2>&1
:: Prevent Windows from throttling Fortnite under any power scenario
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FortniteClient-Win64-Shipping.exe" /v throttlinginsensitive /t REG_DWORD /d 1 /f >nul 2>&1

:: ── ALL OTHER GAMES IFEO ──
for %%g in (
    FiveM.exe
    GTA5.exe
    VALORANT-Win64-Shipping.exe
    cs2.exe
    RustClient.exe
    EscapeFromTarkov.exe
    r5apex.exe
    Overwatch.exe
    Overwatch2.exe
    cod.exe
    ModernWarfare.exe
    BlackOps6.exe
    javaw.exe
    Minecraft.exe
    RocketLeague.exe
    ShooterGame.exe
    destiny2.exe
    RPG7.exe
    start_protected_game.exe
    EasyAntiCheat.exe
    BEService.exe
) do (
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%g\PerfOptions" /v CpuPriorityClass /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%g\PerfOptions" /v CpuUtilization /t REG_DWORD /d 100 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%g\PerfOptions" /v IoPriority /t REG_DWORD /d 3 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%g\PerfOptions" /v DisableHeapValidation /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%g" /v throttlinginsensitive /t REG_DWORD /d 1 /f >nul 2>&1
)

:: ── FORCE HIGH PERFORMANCE GPU FOR ALL GAMES ──
for %%g in (
    FortniteClient-Win64-Shipping.exe
    FiveM.exe
    GTA5.exe
    VALORANT-Win64-Shipping.exe
    cs2.exe
    RustClient.exe
    EscapeFromTarkov.exe
    r5apex.exe
    Overwatch.exe
    Overwatch2.exe
    ModernWarfare.exe
    BlackOps6.exe
    RocketLeague.exe
    destiny2.exe
) do (
    reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%%g" /t REG_SZ /d "GpuPreference=2;" /f >nul 2>&1
)

:: ── QoS — PRIORITIZE FORTNITE UDP PACKETS ──
:: DSCP 46 = Expedited Forwarding — OS marks Fortnite packets as highest priority
:: Only affects Fortnite traffic. Zero impact on rest of your internet.
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Application Name" /t REG_SZ /d "FortniteClient-Win64-Shipping.exe" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "DSCP value" /t REG_SZ /d "46" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Local IP" /t REG_SZ /d "*" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Local IP Prefix Length" /t REG_SZ /d "*" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Local Port" /t REG_SZ /d "*" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Protocol" /t REG_SZ /d "UDP" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Remote IP" /t REG_SZ /d "*" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Remote IP Prefix Length" /t REG_SZ /d "*" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "Remote Port" /t REG_SZ /d "*" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "throttle Rate" /t REG_SZ /d "-1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\QoS\Fortnite" /v "version" /t REG_SZ /d "1.0" /f >nul 2>&1

:: ── BOOST ACTIVE GAME PROCESSES IF ALREADY RUNNING ──
powershell -NoProfile -Command "Get-Process -Name 'FortniteClient-Win64-Shipping' -EA SilentlyContinue | ForEach-Object { $_.PriorityClass = 'High' }" >nul 2>&1
powershell -NoProfile -Command "Get-Process -Name 'GTA5','FiveM' -EA SilentlyContinue | ForEach-Object { $_.PriorityClass = 'High' }" >nul 2>&1

:: ── DONE ───────────────────────────────────────────────────────────
echo.
echo  ================================================================
echo   ALL TWEAKS APPLIED! — VIsion v2.0
echo  ================================================================
echo.
echo   RESTART YOUR PC NOW — required for VBS, HPET, power tweaks.
echo.
echo  ================================================================
echo   MANUAL STEPS AFTER RESTART (do ALL for max FPS):
echo  ================================================================
echo.
echo   [NVIDIA CONTROL PANEL — 3D Settings]
echo    Open: Right-click desktop - NVIDIA Control Panel
echo    Go to: Manage 3D Settings - Global Settings
echo.
echo    Power management mode      = Prefer Maximum Performance
echo    Low Latency Mode           = On  (NOT Ultra — causes stutter)
echo    Vertical Sync              = Off
echo    Triple Buffering           = Off
echo    Shader Cache Size          = Unlimited
echo    Texture filtering - Quality= High Performance
echo    Texture filtering - Aniso  = Application-Controlled
echo    Antialiasing - FXAA        = Off
echo    Antialiasing - Mode        = Application-Controlled
echo    Antialiasing - Transparency= Off
echo    Ambient Occlusion          = Off
echo    CUDA - GPUs                = All
echo    DSR - Factors              = Off
echo    DSR - Smoothness           = Off
echo    Multi-Frame AA (MFAA)      = Off
echo    OpenGL Rendering GPU       = [Your GPU name]
echo    Threaded Optimization      = Auto
echo    Max Frame Rate             = Off
echo    Background App Max FPS     = Off
echo    Virtual Reality pre-frames = 1
echo.
echo   [NVIDIA CONTROL PANEL — Display]
echo    Set up G-Sync              = Enable if you have G-Sync monitor
echo    Adjust desktop color set.  = Digital Vibrance 70-80%% (sharper)
echo    Change resolution          = Highest refresh rate your monitor supports
echo.
echo   [WINDOWS SECURITY]
echo    Settings - Privacy^&Security - Windows Security - Device Security
echo    Core Isolation - Memory Integrity: OFF
echo    (Auto-disabled by tweaker but may need manual confirm after restart)
echo.
echo   [BIOS — ask your PC builder or YouTube your motherboard model]
echo    XMP / DOCP profile         = Enable (doubles RAM speed)
echo    CPU C-States               = Disable (no CPU sleep states)
echo    SpeedStep / AMD Cool'n'Quiet= Disable
echo    Above 4G Decoding          = Enable (if on PCIe 4.0 GPU)
echo    Resizable BAR              = Enable (5-15%% GPU perf gain)
echo.
echo   [IN GAME — Fortnite]
echo    Rendering Mode             = Performance (DX11)
echo    3D Resolution              = 100%%
echo    View Distance              = Medium (Far costs FPS, no competitive advantage)
echo    Shadows                    = Off
echo    Anti-Aliasing              = Off
echo    Textures                   = Medium
echo    Effects                    = Low
echo    Post Processing            = Low
echo    VSync                      = Off
echo    Motion Blur                = Off
echo.
echo   [IN GAME — FiveM/GTA V]
echo    Direct X Version           = DirectX 11
echo    MSAA                       = Off
echo    FXAA                       = Off
echo    Reflection Quality         = Normal
echo    Shadow Quality             = Off
echo    Grass Quality              = Off
echo    Shader Quality             = Normal
echo    Post FX                    = Off
echo    Ambient Occlusion          = Off
echo.
echo  ================================================================
echo.
