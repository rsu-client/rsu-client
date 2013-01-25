#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\share\runescape.ico
#AutoIt3Wrapper_Outfile=Download-Windows-Files.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Description=A downloader to add the files required for the unix client to run on Windows
#AutoIt3Wrapper_Res_Fileversion=2.3.0.0
#AutoIt3Wrapper_Res_LegalCopyright=HikariKnight (hkprojects.weebly.com)
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <WindowsConstants.au3>

#Region ### START Koda GUI section ###
$Form1 = GUICreate("Downloading Required files for Windows Support", 633, 42, -1, -1, BitOR($WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), 0)
$Progress = GUICtrlCreateProgress(0, 0, 631, 17)
$Button = GUICtrlCreateButton("Downloading win32.7z", 0, 16, 632, 25, $WS_GROUP)
GUICtrlSetState(-1, $GUI_DISABLE)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


; Gets the size of the file
$downsize = InetGetSize("http://dl.dropbox.com/u/11631899/opensource/Perl/runescape_unix_client/win32.7z")

; Location and name of file when downloaded
$filename = @ScriptDir & '\win32.7z'

; Downloads the file containing the windows files
$dl = inetget("http://dl.dropbox.com/u/11631899/opensource/Perl/runescape_unix_client/win32.7z", $filename, 1, 1)

; While downloading, update progressbar
While FileGetSize($filename) <> $downsize
	; Update the progressbar
	GUICtrlSetData($Progress, InetGetInfo($dl, 0) * 100 / $downsize)
	;sleep(30)
WEnd

; Close the download
InetClose($dl)
; Set Process to 100%
GUICtrlSetData($Progress, 100)

; Use 7-zip to extract the files windows need to run the client and wait for the process to finish
ShellExecuteWait(@ScriptDir & "\win32\7-zip\7z.exe", "x -y win32.7z", @ScriptDir)

; Wait 10 milliseconds
sleep(10)

; Delete the archive
FileDelete(@ScriptDir & "\win32.7z")

; Wait 10 milliseconds
sleep(10)

; Run the client
Run(@ScriptDir & "\RuneScape.exe")