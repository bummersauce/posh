#applies the date right now to the variable
$now = Get-Date
#uses this variable to ofset the number 30
$days = 30
#applies todays date to this variable
$today = ( get-date ).ToString('yyyyMMdd')

#programatically creates a variable that specifies a date 30 days ago
$LastWrite = $Now.AddDays(-$days)

#lists all the files in E:\Storage\uesws\deletables\
$files = get-childitem E:\Storage\uesws\deletables\* -recurse

#prints the date and time to the log file before each run
$today | out-file d:\ues\Foliocleanup-$today.log -append

#lists the files to the log file to have a record of what was deleted. 
$files | out-file d:\ues\Foliocleanup-$today.log -append

#deletes the files 
cd E:\Storage\uesws\deletables
remove-item $files

#finds all the logs files in the directory that are more than 30 days old
$logs = get-childitem d:\ues\* -exclude "folio*.ps1" | Where {$_.LastWriteTime -le “$LastWrite”}

#deletes the old log files
remove-item $logs