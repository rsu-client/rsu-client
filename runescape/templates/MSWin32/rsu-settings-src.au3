; We do not want any tray icon
#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\share\runescape.ico
#AutoIt3Wrapper_Outfile=rsu-settings.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=A native launcher for the rsu-settings perl script
#AutoIt3Wrapper_Res_Fileversion=2.3.0.0
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; Execute the RuneScape Unix Client
Run(@ScriptDir & '\win32\perl\bin\perl.exe "' & @ScriptDir & '\rsu-settings"', @ScriptDir, @SW_HIDE)