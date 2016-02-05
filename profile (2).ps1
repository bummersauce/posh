#Profile - ssmall

#security - hahaha
set-executionpolicy unrestricted

#environment  - Set up how the powershell windows looks and buffers.
$pshost = get-host
$pswindow = $pshost.ui.rawui
$size = $pswindow.buffersize
$size.height = 3000
$size.width = 125
$pswindow.buffersize = $size

#aliases – setup aliases for frequently used commands or apps
new-alias np notepad.exe

#modules – import your modules at the beginning of the session
ipmo pswindowsupdate #these modules need to be installed or you’ll get an error. Add any you 
ipmo servermanager
ipmo activedirectory


#hello – setup what is run to make your session look the way you want
$pshost | select version
" "
"Logged on as:"
" "
">" + $env:computername + "\" + $env:username

if ((test-path i:) -eq 'True'){
    Write-Host "I: Drive party in full effect`n"
}
Else {
	np c:\windows\system32\windowspowershell\v1.0\idrive.txt
}
