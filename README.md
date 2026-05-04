# VIsion OS

VIsion OS is a gaming-focused AME Wizard playbook based on AtlasOS. It applies the AtlasOS base configuration, then runs VIsion optimizer scripts for FPS, latency, process priority, and input-delay tuning.

## Important

- This project does not distribute Windows ISOs.
- Users must install official Windows themselves, then apply the `.apbx` playbook with AME Wizard.
- This fork is based on [AtlasOS](https://github.com/Atlas-OS/Atlas).
- AtlasOS is licensed under GPLv3, so this derivative source remains open-source under GPLv3.

## VIsion Additions

- VIsion OS branding in `src/playbook/playbook.conf`
- VIsion tweak task in `src/playbook/Configuration/vision/vision-tweaks.yml`
- VIsion tweak runner in `src/playbook/Executables/VIsionTweaks/Apply-VIsionTweaks.ps1`
- Bundled VIsion scripts:
  - `Fortnite_Tweak.bat`
  - `Remove_Delay.bat`

## Build

From the repository root:

```powershell
cd src\playbook
.\build-playbook.cmd
```

The generated `.apbx` file can be uploaded to Vercel Blob and used as the website `OS_BLOB_URL`.

## License

GPLv3. See [LICENSE](LICENSE).
