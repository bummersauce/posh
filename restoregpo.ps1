$gpos = Get-ChildItem C:\TEMP\GPOBackups -name
foreach ($gpo in $gpos) 
    {
     [xml] $xdoc = get-content "C:\TEMP\GPOBackups\$gpo\gpreport.xml"
     $name = $xdoc.GPO.Name
     $gpo1 = $gpo.trimstart("{")
     $gponame = $gpo1.trimend("}")
     import-gpo -backupid $gponame -targetname $name -path "C:\TEMP\GPOBackups" -CreateIfNeeded
    }
