$computers = get-content E:\Posh\servers.txt
$Title = "UNC Hardening"
$Info = "Please choose whether you would like to add or remove"
 
$options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Add", "&Remove")
[int]$defaultchoice = 1
$opt =  $host.UI.PromptForChoice($Title , $Info , $Options,$defaultchoice)
switch($opt)
{
0 { foreach ($computer in $computers){ Invoke-Command -computer $computer -script { new-itemproperty -name '\\*\NETLOGON' -value "RequireMutualAuthentication=1,RequireIntegrity=1" -PropertyType string -Path HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths ; new-itemproperty -name '\\*\SYSVOL' -value "RequireMutualAuthentication=1,RequireIntegrity=1" -PropertyType string -Path HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths  } -Credential dac\ssmall_sa }} 
1 { foreach ($computer in $computers){ Invoke-Command -computer $computer -script { get-item -Path HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths | remove-itemproperty -name '\\*\NETLOGON' ; get-item -Path HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths | remove-itemproperty -name '\\*\SYSVOL'} -Credential dac\ssmall_sa }}
}


