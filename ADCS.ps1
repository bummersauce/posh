$ErrorActionPreference = 'stop'
Add-WindowsFeature ADCS-Cert-Authority -IncludeManagementTools
Add-WindowsFeature Web-WebServer -IncludeManagementTools
Add-WindowsFeature Web-Mgmt-Service -IncludeManagementTool

Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1

Set-Service -Name WMSvc -StartupType Automatic -Status Running

Get-DnsServerZone deploy.local | Add-DnsServerResourceRecordA -Name 'pki' -IPv4Address 192.168.150.10 -CreatePtr

New-item -ItemType directory -Path C:\pki
Set-Content -LiteralPath C:\pki\cps.txt 'Example CPS statement'
new-smbshare �name PKI �FullAccess SYSTEM,�deploy\Domain Admins� �changeaccess �deploy\Cert Publishers� -path C:\pki -Description 'Certificate Share'

New-WebVirtualDirectory -Site "Default Web Site" -Name pki -PhysicalPath C:\pki

Set-WebConfigurationProperty -Filter /system.WebServer/security/authentication/AnonymousAuthentication -PSPath 'IIS:\Sites\Default Web Site\pki' -Name enabled -Value 'True'
Set-WebConfigurationProperty -Filter system.webServer/security/requestFiltering -PSPath 'IIS:\Sites\Default Web Site\pki' -Name allowDoubleEscaping -Value 'True'

icacls C:\pki\ /grant:r '"IIS APPPOOL\DefaultAppPool":(OI)(CI)(RX)'
icacls C:\pki\ /grant:r '"deploy\Cert Publishers":(OI)(CI)(M)'

iisreset

#test
Invoke-WebRequest http://pki.deploy.local/pki/cps.txt | select -ExpandProperty RawContent

set-content -LiteralPath c:\Windows\CAPolicy.inf '
[Version]
Signature="$Windows NT$"

[PolicyStatementExtension]
Policies=InternalPolicy

[InternalPolicy]
OID= 1.2.3.4.1455.67.89.5
Notice="Legal Policy Statement"
URL=http://pki.example.com/pki/cps.txt

[Certsrv_Server]
RenewalKeyLength=4096
RenewalValidityPeriod=Years
RenewalValidityPeriodUnits=5
LoadDefaultTemplates=True
'

$adminpass = Get-Content "I:\pass\Deploy-Administrator.txt" | ConvertTo-SecureString
$adminuser = 'deploy\administrator'
$Credential = New-Object �TypeName System.Management.Automation.PSCredential �ArgumentList $adminuser, $adminpass

Install-AdcsCertificationAuthority �CAType EnterpriseRootCA �CACommonName �Deploy-CA� �KeyLength 4096 �HashAlgorithmName SHA256 -Credential $Credential -Force

cp C:\Windows\System32\CertSrv\CertEnroll\*.cr* C:\pki\

$crllist = Get-CACrlDistributionPoint; foreach ($crl in $crllist) {Remove-CACrlDistributionPoint $crl.uri -Force};

Add-CACRLDistributionPoint -Uri C:\Windows\System32\CertSrv\CertEnroll\%3%8%9.crl -PublishToServer -PublishDeltaToServer -Force

Add-CACRLDistributionPoint -Uri http://pki.deploy.local/pki/%3%8%9.crl -AddToCertificateCDP -Force

Add-CACRLDistributionPoint -Uri file://\\dsc.deploy.local\pki\%3%8%9.crl -PublishToServer -PublishDeltaToServer -Force

$aialist = Get-CAAuthorityInformationAccess; foreach ($aia in $aialist) {Remove-CAAuthorityInformationAccess $aia.uri -Force};

Add-CAAuthorityInformationAccess -AddToCertificateAia http://pki.deploy.local/pki/%1_%3%4.crt �Force

Add-CAAuthorityInformationAccess �AddToCertificateAia �ldap:///CN=%7,CN=AIA,CN=Public Key Services,CN=Services,%6%11� -Force

Restart-Service CertSvc


certutil -setreg CA\CRLPeriodUnits 2
certutil -setreg CA\CRLPeriod "Weeks"
certutil -setreg CA\CRLDeltaPeriodUnits 1
certutil -setreg CA\CRLDeltaPeriod "Days"
certutil -setreg CA\CRLOverlapPeriodUnits 12
certutil -setreg CA\CRLOverlapPeriod "Hours"
certutil -setreg CA\ValidityPeriodUnits 5
certutil -setreg CA\ValidityPeriod "Years"
Restart-Service CertSvc -Verbose
sleep 10
certutil -CRL

Get-CAAuthorityInformationAccess | fl

Get-CACRLDistributionPoint | fl
