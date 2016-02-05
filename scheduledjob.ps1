




Register-ScheduledJob -Name 'restart email' -ScheduledJobOption (New-ScheduledJobOption -RunElevated) -FilePath 'D:\PoSh\restartemail.ps1'

Get-ScheduledJob | Add-JobTrigger -Trigger (New-JobTrigger -AtStartup)

Get-ScheduledJob -Name 'restart email' | select *