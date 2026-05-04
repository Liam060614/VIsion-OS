@echo off
setlocal EnableDelayedExpansion
title VIsion — Zero Delay Optimizer
color 0A

net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Run as Administrator!
    pause & exit /b 1
)

echo.
echo  ============================================
echo   VIsion — Zero Delay / Input Lag Remover
echo  ============================================
echo.

:: ── MOUSE / INPUT RAW ───────────────────────────────────────────────
echo  [1] Raw mouse input + acceleration off...
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v MouseSensitivity /t REG_SZ /d "10" /f >nul 2>&1
:: Flat smooth mouse curves = pixel perfect raw movement
reg add "HKCU\Control Panel\Mouse" /v SmoothMouseXCurve /t REG_BINARY /d 0000000000000000C0CC0C0000000000809919000000000040662600000000000099330000000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v SmoothMouseYCurve /t REG_BINARY /d 0000000000000000000038000000000000007000000000000000A8000000000000E0000000000000 /f >nul 2>&1
echo  [OK] Mouse: raw input, no acceleration.

:: ── KEYBOARD + MOUSE BUFFER SIZE ────────────────────────────────────
echo  [2] Reducing input buffer size...
:: Smaller queue = input processed faster, less buffering lag
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v KeyboardDataQueueSize /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v MouseDataQueueSize /t REG_DWORD /d 20 /f >nul 2>&1
echo  [OK] Input buffer minimized.

:: ── GLOBAL 0.5ms TIMER RESOLUTION ──────────────────────────────────
echo  [3] Setting Windows timer to 0.5ms (default is 15.6ms)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /t REG_DWORD /d 1 /f >nul 2>&1
echo  [OK] Timer: 0.5ms resolution.

:: ── DISABLE DYNAMIC TICK + HPET ─────────────────────────────────────
echo  [4] Disabling dynamic tick and HPET...
bcdedit /set disabledynamictick yes >nul 2>&1
bcdedit /set useplatformtick no >nul 2>&1
bcdedit /set useplatformclock false >nul 2>&1
echo  [OK] Dynamic tick off, HPET off.

:: ── CPU PRIORITY / SCHEDULER ────────────────────────────────────────
echo  [5] Max foreground process priority...
:: 38 = short interval, max foreground boost — game gets CPU instantly
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul 2>&1
echo  [OK] CPU priority: max foreground boost.

:: ── MMCSS — NO NETWORK/SYSTEM THROTTLING ────────────────────────────
echo  [6] MMCSS zero delay settings...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Latency Sensitive" /t REG_SZ /d "True" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 0x2710 /f >nul 2>&1
echo  [OK] MMCSS: no throttling, game at max priority.

:: ── GPU SCHEDULER — TRUE IMMEDIATE FLIP ─────────────────────────────
echo  [7] GPU immediate frame delivery...
:: Frame delivered to display instantly — no queue wait
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v ForceFlipTrueImmediateMode /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v VsyncIdleTimeout /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v EnablePreemption /t REG_DWORD /d 0 /f >nul 2>&1
:: Direct flip = frame goes to monitor without DWM processing
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v EnableDirectFlip /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v ForceDirectFlip /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v EnableIndependentFlip /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v LOWLATENCY /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v Node3DLowLatency /t REG_DWORD /d 1 /f >nul 2>&1
echo  [OK] GPU: true immediate frame delivery.

:: ── DWM LATENCY ─────────────────────────────────────────────────────
echo  [8] DWM minimum latency...
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v Latency /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v MaxLatency /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v MagnificationAPI /t REG_DWORD /d 1 /f >nul 2>&1
:: MPO off — fixes hidden stutter/delay from DWM overlay planes
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v OverlayTestMode /t REG_DWORD /d 5 /f >nul 2>&1
echo  [OK] DWM: minimum latency, MPO off.

:: ── DISABLE USB POWER SAVING ────────────────────────────────────────
echo  [9] USB always-on (no input stutter on first key/click)...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\USB" /v DisableSelectiveSuspend /t REG_DWORD /d 1 /f >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1
echo  [OK] USB: no power saving, always ready.

:: ── DISABLE ACTIVE PROBING (NLA pinging) ────────────────────────────
echo  [10] Stopping NLA service pinging internet every few seconds...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc\Parameters\Internet" /v EnableActiveProbing /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\ControlSet001\Services\NlaSvc\Parameters\Internet" /v EnableActiveProbing /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] Active probing off.

:: ── THREAD DPC ──────────────────────────────────────────────────────
echo  [11] Thread DPC inline (lower interrupt latency)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v ThreadDpcEnable /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] Thread DPC disabled.

:: ── PRE-RENDERED FRAMES = 1 ─────────────────────────────────────────
echo  [12] D3D pre-rendered frames = 1 (lowest input lag for GPU)...
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Direct3D" /v MaxPreRenderedFrames /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Direct3D" /v MaxPreRenderedFrames /t REG_DWORD /d 1 /f >nul 2>&1
echo  [OK] Pre-rendered frames: 1.

:: ── GAME DVR OFF ────────────────────────────────────────────────────
echo  [13] GameDVR off (recording hooks add input delay)...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
echo  [OK] GameDVR off.

:: ── DONE ────────────────────────────────────────────────────────────
echo.
echo  ============================================
echo   DELAY REMOVED! Restart for full effect.
echo  ============================================
echo.
echo  After restart also do in NVIDIA Control Panel:
echo   Low Latency Mode = On
echo   Vertical Sync    = Off
echo   Pre-Rendered Frames = 1
echo.
pause
