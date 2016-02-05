Stop-Process -processname OUTLOOK -ErrorAction SilentlyContinue

$Outlook = New-Object -ComObject Outlook.Application
#$OutlookFolder = $Outlook.Session.Folders.Item(2).Folders.Item("Inbox").Folders.Item("$folder").items
#$OutlookDeletedItems = $Outlook.Session.Folders.Item(2).Folders.Item("Deleted Items")

$folders = @("UEmail","Confluence","YouTrack","CDP","NSS","GSS")

foreach ($folder in $folders){

    $OutlookFolder = $Outlook.Session.Folders.Item(2).Folders.Item("Inbox").Folders.Item("$folder").Items
do {
        foreach ($email in $OutlookFolder){
            $email | ft SenderName , subject
            $email.Delete()
            Start-Sleep -Milliseconds 300
            }
    }
while ($OutlookFolder = $null) 
}

Stop-Process -processname OUTLOOK -ErrorAction SilentlyContinue

#$folder = "YouTrack"
#$outlook = New-Object -ComObject Outlook.Application
#$OutlookFolder = $Outlook.Session.Folders.Item(2).Folders.Item("Inbox").Folders.Item("$folder").items
#$OutlookDeletedItems = $Outlook.Session.Folders.Item(2).Folders.Item("Deleted Items")
#$OutlookFolder | ft SenderName , subject