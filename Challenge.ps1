$servers = Get-Content "E:\PoSh\allservers.txt"

foreach ($server in $servers)
    {
    invoke-command -ComputerName $server {    
    New-PSDrive -Name S -root \\uep.sys\netlogon -PSProvider FileSystem    
           
    Copy-Item 'S:\sdconf.rec' 'C:\Program Files\Common Files\RSA Shared\Auth Data'
    }
    #{Set-ItemProperty -Path "HKLM:\SOFTWARE\RSA\RSA Desktop Preferences\Local Authentication Settings" -Name ChallengeMode -Value 00000000}
    }
