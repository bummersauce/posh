ipmo activedirectory

$allusers = get-aduser -filter {(PassWordNeverExpires -eq "True") -and (Enabled -eq "True")}
 
$45days = (get-date).AddDays(-45)

function Get-ADUserLastLogon([string]$userName)
{
  $dcs = Get-ADDomainController -Filter {Name -like "*"}
  $time = 0
  foreach($dc in $dcs)
  { 
    $hostname = $dc.HostName
    $user = Get-ADUser $userName | Get-ADObject -Properties lastLogon 
    if($user.LastLogon -gt $time) 
    {
      $time = $user.LastLogon
    }
  }
  $dt = [DateTime]::FromFileTime($time)
  #Write-Host $username "last logged on at:" $dt
  if ($dt -lt $42days)
    {
    write-host "$alluser 'last logged on at:' $dt should be disabled"
    Disable-ADAccount -Identity $alluser -WhatIf
    }
}

foreach ($alluser in $allusers)
    {
    Get-ADUserLastLogon $alluser
    }