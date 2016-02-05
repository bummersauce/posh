################################################################################################
# Get-LogonMethod.ps1
# 
# AUTHOR: Fabian Müller
# DATE: 18.06.2012
# VERSION: 0.1
#
# THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
# FITNESS FOR A PARTICULAR PURPOSE.
#
# This sample is not supported under any Microsoft standard support program or service. 
# The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
# implied warranties including, without limitation, any implied warranties of merchantability
# or of fitness for a particular purpose. The entire risk arising out of the use or performance
# of the sample and documentation remains with you. In no event shall Microsoft, its authors,
# or anyone else involved in the creation, production, or delivery of the script be liable for 
# any damages whatsoever (including, without limitation, damages for loss of business profits, 
# business interruption, loss of business information, or other pecuniary loss) arising out of 
# the use of or inability to use the sample or documentation, even if Microsoft has been advised 
# of the possibility of such damages.
################################################################################################

# Define variables
$RegUserTile="HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\UserTile"
$RegCredentialProviders="HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers"

# Translate the currently logged on username into an SID
function ConvertUserNameTo-SID($UserName)
{
	$SID = New-Object System.Security.Principal.NtAccount($UserName)
	$SID = $SID.Translate([System.Security.Principal.SecurityIdentifier])	
	$SID.Value.ToString()
}

$UserSID=ConvertUserNameTo-SID -UserName $env:USERDOMAIN\$env:USERNAME


# Reading the UserTile registry value to get the information about the currently used Credential Providers for the logged on users
$UserTile=Get-ItemProperty -Path $RegUserTile

# Find the Credential Provider for the currently logged on user by using the user's SID
$CurrentProvider=$UserTile.$UserSID.ToString()

# Providing the Credential Provider
$CredentialProvider=Get-ItemProperty -Path $RegCredentialProviders\$CurrentProvider
Get-ItemProperty $CredentialProvider.PsPath | Select @{Name="Current Credential Provider for "+$env:USERDOMAIN+"\"+$env:USERNAME; Expression = "(default)"}