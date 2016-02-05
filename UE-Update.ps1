#Creates log file and path
$path = "c:\windows\logs\UE-Updater.log"

#confirms exists
if(!(Test-Path -Path $path))
    {
    #if not, creates
    new-item -Path $path –itemtype file
    }

#if it exists, copies up to the next 4.
else
    {
    copy-item c:\windows\logs\UE-Updater-old-3.log c:\windows\logs\UE-Updater-old-4.log
    copy-item c:\windows\logs\UE-Updater-old-2.log c:\windows\logs\UE-Updater-old-3.log
    copy-item c:\windows\logs\UE-Updater-old-1.log c:\windows\logs\UE-Updater-old-2.log
    copy-item c:\windows\logs\UE-Updater.log c:\windows\logs\UE-Updater-old-1.log  
    }
#deletes the newest log file aftwer its been copied  
remove-item c:\windows\logs\UE-Updater.log

#appends the date to the log file.
$date = get-date
out-file -encoding ascii -filepath $path -inputobject $date -append

#commands the machine to report in with the WSUS server
wuauclt.exe /reportnow
out-file -encoding ascii -filepath $path -inputobject 'Reporting to WSUS Server...' -append
start-sleep 20

#---------------------------------------------------------------------------------------------------------------

#creates the COM Object that starts a WSUS session
$session = New-Object -ComObject 'Microsoft.Update.Session'
$searcher = $session.CreateUpdateSearcher()

#function to update the machine
function updates
    {

#finds all applicable updates for the machine
    out-file -encoding ascii -filepath $path -inputobject 'Detecting updates ready to be installed...' -append

#retrives a list of updates available to the machine
    $result = $searcher.Search("IsInstalled=0 and Type='Software' and ISHidden=0") 

#If the update count is 0 the script ends
    if ($result.Updates.Count -eq 0)
        {
        out-file -encoding ascii -filepath $path -inputobject "No updates needed" -append
        Break
        }
        
#or states there are no updates, and ends the script
        else
            {
            $result.Updates | Select-Object -Property Title | where-object {$_.Title -match 'Universal'}
            }
#lists updates and creates a collection for the Windows update client
    out-file -encoding ascii -filepath $path -inputobject 'Creating a collection of updates to download:' -append
    $downloads = New-Object -ComObject 'Microsoft.Update.UpdateColl'

#adds the updates to the download list
    foreach ($update in $result.updates | where-object {$_.Title -match 'Universal'})
        {
        out-file -encoding ascii -filepath $path -inputobject "Adding: $($Update.Title)" -append
        $downloads.Add($update) | Out-Null
        }

#if there were no updates to download skips the download process and ends the script 
    if ($downloads.Count -eq 0)
        {
        out-file -encoding ascii -filepath $path -inputobject 'No updates to download.' -append
        break
        }    

#starts the session to download the updates.
    out-file -encoding ascii -filepath $path -inputobject 'Downloading updates...' -append 
    $downloader = $session.CreateUpdateDownLoader()
    $downloader.Updates = $downloads
    $downloader.Download()

#lists the updates that have been downloaded and are ready for install
    $installs = New-Object -ComObject 'Microsoft.Update.UpdateColl'
    out-file -encoding ascii -filepath $path -inputobject 'Successfully downloaded updates:' -append

#lists updates in the log file    
    foreach ($update in $result.updates | where-object {$_.Title -match 'Universal'})
        {
        if ($update.IsDownloaded)
            {
            out-file -encoding ascii -filepath $path -inputobject "> $($Update.Title)" -append

#and adds the update to the install list
            $installs.Add($update) 
            }
        }

#starts the install process
    out-file -encoding ascii -filepath $path -inputobject 'Installing updates...' -append
    $installer = $session.CreateUpdateInstaller()
    $installer.Updates = $installs    
    $installresult = $installer.Install()
    $installresult

#logs results
    out-file -encoding ascii -filepath $path -inputobject "Installation Result: $($InstallResult.ResultCode)" -append
        
    for($i=0; $i -lt $UpdatesToInstall.Count; $i++)
        {
        out-file -encoding ascii -filepath $path -inputobject "> $($Update.Title) : $($InstallResult.GetUpdateResult($i).ResultCode)" -append
        }

if ($InstallResult.ResultCode = 4){$updates.Count = 0}      
}
#end of function

#calls function and repeats function as long as the update count is not null 
do{updates}
while
($Updates.Count -ne 0)

#commands the machine to report in with the WSUS server one last time            
wuauclt.exe /reportnow