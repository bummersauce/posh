$servers = Get-Content E:\PoSh\sql.txt 
foreach ($server in $servers)
     {
     Set-GPPermissions -Name "User Rights Assignments - FRESNO" -targetname $server -TargetType Computer -PermissionLevel gpoapply
     }