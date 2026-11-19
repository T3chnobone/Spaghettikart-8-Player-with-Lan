Unicode true
!include "MUI2.nsh"
!define APPNAME "SpaghettiKart LAN8"
!define APPID   "SpaghettiKart-LAN8"
!define VERSION "0.1.0"
!ifndef SRC
  !define SRC "SpaghettiKart-LAN8"
!endif

Name "${APPNAME}"
OutFile "SpaghettiKart-LAN8-Setup-${VERSION}.exe"
RequestExecutionLevel user
InstallDir "$LOCALAPPDATA\${APPID}"
InstallDirRegKey HKCU "Software\${APPID}" "InstallDir"
SetCompressor /SOLID lzma
BrandingText "${APPNAME} ${VERSION}"
VIProductVersion "${VERSION}.0"
VIAddVersionKey "ProductName" "${APPNAME}"
VIAddVersionKey "FileDescription" "${APPNAME} setup"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "LegalCopyright" "Unofficial fan build. Contains no Nintendo game data."

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TEXT "This installs ${APPNAME}: SpaghettiKart with COUCH PARTY (up to 8 players on one PC), LAN netplay for up to 8 PCs, and Time Trial leaderboards with player names.$\r$\n$\r$\nIt contains no Nintendo game data. You need your own Mario Kart 64 ROM (US version, .z64). On the first run the game asks for it and builds mk64.o2r.$\r$\n$\r$\nPick a folder you can write to; the game keeps its settings, saves and leaderboards there."
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

Section "Game files (required)" SecGame
  SectionIn RO
  SetOutPath "$INSTDIR"
  File "${SRC}\Spaghettify.exe"
  File "${SRC}\libc++.dll"
  File "${SRC}\libunwind.dll"
  File "${SRC}\spaghetti.o2r"
  File "${SRC}\config.yml"
  File "${SRC}\READ ME FIRST.txt"
  File "${SRC}\LICENSE-libultraship.txt"
  ; keep the player's own settings on upgrade
  IfFileExists "$INSTDIR\spaghettify.cfg.json" +2 0
    File "${SRC}\spaghettify.cfg.json"
  SetOutPath "$INSTDIR\meta"
  File "${SRC}\meta\mods.toml"
  SetOutPath "$INSTDIR\docs"
  File /r "${SRC}\docs\*.*"
  SetOutPath "$INSTDIR\yamls"
  File /r "${SRC}\yamls\*.*"
  SetOutPath "$INSTDIR\textures"
  File "${SRC}\textures\README.md"
  ; keep replaced menu pictures on upgrade
  IfFileExists "$INSTDIR\textures\couch_party_button.png" +2 0
    File "${SRC}\textures\couch_party_button.png"
  IfFileExists "$INSTDIR\textures\lan_game_button.png" +2 0
    File "${SRC}\textures\lan_game_button.png"
  IfFileExists "$INSTDIR\textures\character_highlight.png" +2 0
    File "${SRC}\textures\character_highlight.png"

  SetOutPath "$INSTDIR"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\${APPID}" "InstallDir" "$INSTDIR"
  !define UNKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"
  WriteRegStr HKCU "${UNKEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKCU "${UNKEY}" "DisplayVersion" "${VERSION}"
  WriteRegStr HKCU "${UNKEY}" "Publisher" "T3chnobone"
  WriteRegStr HKCU "${UNKEY}" "DisplayIcon" "$INSTDIR\Spaghettify.exe"
  WriteRegStr HKCU "${UNKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKCU "${UNKEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKCU "${UNKEY}" "NoModify" 1
  WriteRegDWORD HKCU "${UNKEY}" "NoRepair" 1
SectionEnd

Section "Start menu shortcuts" SecStart
  CreateDirectory "$SMPROGRAMS\${APPNAME}"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\Spaghettify.exe" "" "$INSTDIR\Spaghettify.exe"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\READ ME FIRST.lnk" "$INSTDIR\READ ME FIRST.txt"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\Game folder.lnk" "$INSTDIR"
  CreateShortcut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Desktop shortcut" SecDesk
  CreateShortcut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\Spaghettify.exe" "" "$INSTDIR\Spaghettify.exe"
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecGame} "The game, its docs and the replaceable menu pictures. No Nintendo data."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecStart} "Start menu folder with the game, the readme and the uninstaller."
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesk} "A shortcut on your desktop."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "Uninstall"
  Delete "$INSTDIR\Spaghettify.exe"
  Delete "$INSTDIR\libc++.dll"
  Delete "$INSTDIR\libunwind.dll"
  Delete "$INSTDIR\spaghetti.o2r"
  Delete "$INSTDIR\config.yml"
  Delete "$INSTDIR\READ ME FIRST.txt"
  Delete "$INSTDIR\LICENSE-libultraship.txt"
  RMDir /r "$INSTDIR\meta"
  RMDir /r "$INSTDIR\docs"
  RMDir /r "$INSTDIR\yamls"
  Delete "$INSTDIR\textures\README.md"
  RMDir "$INSTDIR\textures"
  Delete "$INSTDIR\Uninstall.exe"
  MessageBox MB_YESNO|MB_DEFBUTTON2 "Also delete your settings, leaderboards, logs and the extracted game data (mk64.o2r) in$\r$\n$INSTDIR ?" IDNO keep
    RMDir /r "$INSTDIR"
  keep:
  RMDir "$INSTDIR"
  RMDir /r "$SMPROGRAMS\${APPNAME}"
  Delete "$DESKTOP\${APPNAME}.lnk"
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPID}"
  DeleteRegKey HKCU "Software\${APPID}"
SectionEnd
