ipmo activedirectory

Trap {"Error: $_" >> "C:\45DaysDisabled\errorlog.txt";}

$30Days = (get-date).adddays(-30)

$45Days = (get-date).adddays(-45)

$logDate = get-date -f yyyy-MM-dd

$logfile = "C:\45DaysDisabled\User_Report_$logDate.txt"

set-content -Value "todays date $logdate" $logfile

add-content -Value "-------------------------" $logfile

$allusers = get-aduser -filter {(PassWordNeverExpires -eq "False") -and (Enabled -eq "True")}

$allcomputers = Get-ADComputer -filter {(Enabled -eq "True")}




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
  if ($dt -lt $45days)
    {
    write-host "$alluser 'last logged on at:' $dt should be disabled" | out-file $logfile -append -encoding utf8
    Disable-ADAccount -Identity $alluser -whatif | out-file $logfile -append -encoding utf8
    }
}

function Get-ADComputerLastLogon([string]$ComputerName)
{
  $dcs = Get-ADDomainController -Filter {Name -like "*"}
  $time = 0
  foreach($dc in $dcs)
  { 
    $hostname = $dc.HostName
    $Computer = Get-ADComputer $ComputerName | Get-ADObject -Properties lastLogon 
    if($Computer.LastLogon -gt $time) 
    {
      $time = $Computer.LastLogon
    }
  }
  $dt = [DateTime]::FromFileTime($time)
  #Write-Host $username "last logged on at:" $dt
  if ($dt -lt $45days)
    {
    write-host "$allcomputer 'last logged on at:' $dt should be disabled" | out-file $logfile -append -encoding utf8
    Disable-ADAccount -Identity $allcomputer -WhatIf | out-file $logfile -append -encoding utf8
    }
}

foreach ($allcomputer in $allcomputers)
    {
    Get-ADComputerLastLogon $allcomputer
    }

foreach ($alluser in $allusers)
    {
    Get-ADUserLastLogon $alluser
    }