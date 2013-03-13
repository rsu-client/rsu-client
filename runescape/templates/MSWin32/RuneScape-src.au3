#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\share\img\runescape.ico
#AutoIt3Wrapper_Outfile=RuneScape.exe
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
#include <_Zip.au3>

; Url of the always up to date exe file
$url = "https://github.com/HikariKnight/rsu-launcher/archive/rsu-query-MSWin32.zip"


; If the rsu-query.exe exists
If FileExists(@ScriptDir & "\rsu\rsu-query.exe") Then
	; If the existing rsu-query.exe is a different size than the remote one
	If FileGetSize(@ScriptDir & "\rsu\rsu-query.exe") <> InetGetSize($url,1) Then
		; Tell the user we need to update the API too
		$update = MsgBox(4, "Update available!", "A newer version of rsu-query.exe is available!" & @CRLF & "Do you want me to launch the updater then download the new rsu-query.exe?" & @CRLF & 'NOTE: Click "Update rsu-api" inside the updater.' & @CRLF & "Clicking No will launch the client normally")

		; If yes then
		If $update = 6 Then
			; Run the updater
			RunWait(@ScriptDir & "\rsu\rsu-query.exe client.launch.updater --showcmd=false")

			; Update rsu-query.exe
			do_update("Updat")
		EndIf
	EndIf

; Else
Else
	; Download the binary
	do_update("Download")
EndIf

; Run the client
Run(@ScriptDir & "\rsu\rsu-query.exe --showcmd=false",@ScriptDir,@SW_HIDE);

func do_update($text)
	#Region ### START Koda GUI section ###
	$Form1 = GUICreate($text & "ing rsu-query.exe", 633, 42, -1, -1, BitOR($WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), 0)
	$Progress = GUICtrlCreateProgress(0, 0, 631, 17)
	$Button = GUICtrlCreateButton($text & "ing rsu-query.exe", 0, 16, 632, 25, $WS_GROUP)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	; Gets the size of the file
	$downsize = InetGetSize($url)

	; Location and name of file when downloaded
	$filename = @ScriptDir & '\rsu-query.zip'

	; Downloads the file containing the windows files
	$dl = inetget($url, $filename, 1, 1)

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

	; Wait 10 milliseconds
	sleep(10)

	_Zip_Unzip($filename, "rsu-launcher-rsu-query-MSWin32\rsu-query.exe", @ScriptDir & '\rsu', 17)
EndFunc