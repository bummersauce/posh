$servername = read-host "servername?"

$certs = "c:\certs"
if (!(test-path -path $certs)){New-Item -ItemType directory -Path c:\certs}

$request =  "c:\certs\$servername.ini"
if ((test-path -path $request))
{remove-item $request}

New-Item -ItemType file -Path "c:\certs\$servername.ini"
add-content "c:\certs\$servername.ini" '[NewRequest]'
add-content "c:\certs\$servername.ini" "Subject=`"CN=$servername.gss.sys`""
add-content "c:\certs\$servername.ini" 'Exportable=TRUE
ExportableEncrypted=TRUE
KeyLength=2048
KeySpec=1
KeyUsage=0xf0
MachineKeySet=TRUE
[RequestAttributes]
CertificateTemplate="RDP"
[EnhancedKeyUsageExtension]
OID=1.3.6.1.4.1.311.54.1.2'


certreq -New -f "c:\certs\$servername.ini" "c:\certs\$servername.req"

certreq -submit -config "Beast.gss.sys\UES" "c:\certs\$servername.req" "c:\certs\$servername.cer" 

$id = read-host "ID?" 

certreq -retrieve -config "Beast.gss.sys\UES" $id "c:\certs\$servername.cer"

certreq -accept "c:\certs\$servername.cer"


read-host "press any key to restart services?"

net stop "remote desktop services" ; net start "remote desktop services"