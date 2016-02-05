$tvpage = Invoke-RestMethod "http://www.bestbuy.com/site/samsung-55-class-54-6-diag--led-curved-2160p-smart-4k-ultra-hd-tv-black/3953166.p?id=1219609307254&skuId=3953166" 
set-content -Path C:\Users\ssmall\Desktop\tv.txt -Value $tvpage

$price = "999.99"

$pricecheck =  select-string -Path 'C:\Users\ssmall\Desktop\tv.txt' -Pattern $price
$pricecheck
if ( $pricecheck -eq $null )
    {
    $EmailFrom = "stephensmalls@gmail.com"
    $EmailTo = "stephensmalls@gmail.com" 
    $Subject = "Price drop" 
    $Body = "this is a notification of the price dropping `n $pricecheck" 
    $SMTPServer = "smtp.gmail.com" 
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
    $SMTPClient.EnableSsl = $true 
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("stephensmalls", "January@Butch!"); 
    $SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)
    
    }