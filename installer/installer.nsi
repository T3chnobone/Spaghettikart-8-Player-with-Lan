; SpaghettiKart LAN8 setup.
;
; The setup holds no game files. When it runs it downloads the newest build
; from the repo's `latest-build` branch (see get-latest.ps1), so publishing an
; update only means pushing a new zip there; this setup never needs rebuilding.
;
; Build: makensis installer/installer.nsi   (from the repo root)

Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"

!define APPNAME "SpaghettiKart LAN8"
!define APPID   "SpaghettiKart-LAN8"
!define REPO    "T3chnobone/Spaghettikart-8-Player-with-Lan"
!define SETUPVER "1.0.0"
!define UNKEY   "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"

Name "${APPNAME}"
OutFile "SpaghettiKart-LAN8-Setup.exe"
RequestExecutionLevel user
InstallDir "$LOCALAPPDATA\${APPID}"
InstallDirRegKey HKCU "Software\${APPID}" "InstallDir"
SetCompressor /SOLID lzma
BrandingText "${APPNAME} setup"
VIProductVersion "${SETUPVER}.0"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "FileDescription" "${APPNAME} setup (downloads the newest build)"
VIAddVersionKey "FileVersion" "${SETUPVER}"
VIAddVersionKey "LegalCopyright" "Unofficial fan build. Contains no Nintendo game data."

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TEXT "This installs or updates ${APPNAME}: SpaghettiKart with COUCH PARTY (up to 8 players on one PC), LAN netplay for up to 8 PCs, and Time Trial leaderboards with player names.$\r$\n$\r$\nThe setup downloads the newest build from GitHub (about 10 MB), so you need an internet connection. Running it again later updates the game and keeps your settings, leaderboards and mods.$\r$\n$\r$\nIt contains no Nintendo game data. You need your own Mario Kart 64 ROM (US version, .z64)."
!define MUI_FINISHPAGE_RUN "$INSTDIR\Spaghettify.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Start ${APPNAME} now"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\READ ME FIRST.txt"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Show READ ME FIRST"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Section "Game (newest build from GitHub)" SecGame
  SectionIn RO
  SetDetailsView show
  InitPluginsDir
  SetOutPath "$PLUGINSDIR"
  File "get-latest.ps1"

  DetailPrint "Getting the newest build from github.com/${REPO} ..."
  nsExec::ExecToLog '"$SYSDIR\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "$PLUGINSDIR\get-latest.ps1" -InstallDir "$INSTDIR" -Repo "${REPO}" -WorkDir "$PLUGINSDIR"'
  Pop $0
  ${If} $0 == "4"
    MessageBox MB_ICONEXCLAMATION "SpaghettiKart is running. Close the game, then run the setup again." /SD IDOK
    Abort "The game is running."
  ${ElseIf} $0 != "0"
    MessageBox MB_ICONSTOP "Couldn't download or install the game (code $0).$\r$\nCheck your internet connection and try again. The details are in the setup window." /SD IDOK
    Abort "Download or install failed."
  ${EndIf}

  SetOutPath "$INSTDIR"
  ; Keep a copy of this setup so the player can update later.
  ${If} "$EXEPATH" != "$INSTDIR\Check for updates.exe"
    CopyFiles /SILENT "$EXEPATH" "$INSTDIR\Check for updates.exe"
  ${EndIf}
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ClearErrors
  FileOpen $1 "$INSTDIR\version.txt" r
  ${IfNot} ${Errors}
    FileRead $1 $2
    FileClose $1
  ${EndIf}
  WriteRegStr HKCU "Software\${APPID}" "InstallDir" "$INSTDIR"
  WriteRegStr HKCU "${UNKEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKCU "${UNKEY}" "DisplayVersion" "$2"
  WriteRegStr HKCU "${UNKEY}" "Publisher" "T3chnobone"
  WriteRegStr HKCU "${UNKEY}" "DisplayIcon" "$INSTDIR\Spaghettify.exe"
  WriteRegStr HKCU "${UNKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNKEY}" "URLInfoAbout" "https://github.com/${REPO}"
  WriteRegStr HKCU "${UNKEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKCU "${UNKEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNKEY}" "NoRepair" 1
SectionEnd

Section "Start menu shortcuts" SecStart
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\Spaghettify.exe" "" "$INSTDIR\Spaghettify.exe"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\Check for updates.lnk" "$INSTDIR\Check for updates.exe"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\READ ME FIRST.lnk" "$INSTDIR\READ ME FIRST.txt"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\Game folder.lnk" "$INSTDIR"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Desktop shortcut" SecDesk
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\Spaghettify.exe" "" "$INSTDIR\Spaghettify.exe"
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecGame} "Downloads the newest game build from GitHub. No Nintendo data."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecStart} "Start menu folder with the game, Check for updates, the readme and the uninstaller."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesk} "A shortcut on your desktop."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "Uninstall"
  ; Remove the files the last install/update put there (listed by get-latest.ps1).
  ClearErrors
  FileOpen $0 "$INSTDIR\installed-files.txt" r
  ${IfNot} ${Errors}
    loop:
      ClearErrors
      FileRead $0 $1
      IfErrors done
      ; strip CR/LF
      StrCpy $2 $1 1 -1
      StrCmp $2 "$\n" 0 +2
        StrCpy $1 $1 -1
      StrCpy $2 $1 1 -1
      StrCmp $2 "$\r" 0 +2
        StrCpy $1 $1 -1
      StrCmp $1 "" loop
      ; keep the player's own settings and menu pictures
      StrCmp $1 "spaghettify.cfg.json" loop
      StrCpy $2 $1 9
      StrCmp $2 "textures\" 0 +2
        StrCmp $1 "textures\README.md" 0 loop
      Delete "$INSTDIR\$1"
      Goto loop
    done:
    FileClose $0
  ${EndIf}
  RMDir /r "$INSTDIR\yamls"
  RMDir /r "$INSTDIR\docs"
  RMDir /r "$INSTDIR\meta"
  RMDir "$INSTDIR\textures"
  Delete "$INSTDIR\installed-files.txt"
  Delete "$INSTDIR\version.txt"
  Delete "$INSTDIR\Check for updates.exe"
  Delete "$INSTDIR\Uninstall.exe"
  MessageBox MB_YESNO|MB_DEFBUTTON2 "Also delete your settings, leaderboards, mods, logs and the extracted game data (mk64.o2r) in$\r$\n$INSTDIR ?" /SD IDNO IDNO keep
    RMDir /r "$INSTDIR"
  keep:
  RMDir "$INSTDIR"
  RMDir /r "$SMPROGRAMS\${APPNAME}"
  Delete "$DESKTOP\${APPNAME}.lnk"
  DeleteRegKey HKCU "${UNKEY}"
  DeleteRegKey HKCU "Software\${APPID}"
SectionEnd
