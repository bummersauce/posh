#----------------------------------------------------------------------------------------
#Userprovisioning.ps1 Ver1.2
#Change log: 9-30-2014
#add support for TIM ID's (7digit appIDs)
#
#Stephen Small
#ssmall@morphotrust.com
#615-372-8088
#----------------------------------------------------------------------------------------


#imports the AD module to run commands against AD--------------------------------------------------------------------------------------------
import-module ActiveDirectory

#Clears the error cache-----------------------------------------------------------------------------------------------
$error.clear()
$cancel = $false
#clears the variables-----------------------------------------------------------------------------------------------
if ($count -ne $null){remove-Variable count}
if ($groups -ne $null){remove-Variable groups}
if ($firstname -ne $null){remove-Variable firstname}
if ($lastname -ne $null){remove-Variable lastname}
if ($UPN -ne $null){remove-Variable UPN}
if ($challenge -ne $null){remove-Variable challenge}
if ($resopnse -ne $null){remove-Variable response}
if ($templates -ne $null){remove-Variable templates}
if ($UPNfull -ne $null){remove-Variable UPNfull}
if ($inital -ne $null){remove-Variable initial}
if ($Name -ne $null){remove-Variable Name}
if ($password -ne $null){remove-Variable password}
if ($copiedtemplate -ne $null){remove-Variable copiedtemplate}

#Starts to program the new user function-----------------------------------------------------------------------------------------------
function newuser
{
    
    #checks to see if the template variable is populated, then goes to AD to grab them.
    if ($templates -eq $null)
    {
        $templates = Get-ADUser -Filter {Description -eq "Template"} -SearchBase "OU=Users,OU=TrustedWorkstations,DC=ues,DC=sys" `
         -server rodimus.ues.sys | sort
    } 
    
#Form to choose a Template-----------------------------------------------------------------------------------------------
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "Available Templates"
    $objForm.Size = New-Object System.Drawing.Size(500,400) 
    $objForm.StartPosition = "CenterScreen"

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(215,330)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$chosentemplate=$objListBox.SelectedItem;$objForm.Close()})
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(300,330)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$cancel=$true;$objForm.Close()})
    $objForm.Controls.Add($CancelButton)

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,20) 
    $objLabel.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel.Text = "Please select a User Template:"
    $objForm.Controls.Add($objLabel) 

    $objListBox = New-Object System.Windows.Forms.ListBox 
    $objListBox.Location = New-Object System.Drawing.Size(10,40) 
    $objListBox.Size = New-Object System.Drawing.Size(260,40) 
    $objListBox.Height = 200
    $objListBox.Width = 400

    $templatenames = $templates | Select-object samaccountname

    foreach ($templatename in $templatenames)
        {
        [void] $objListBox.Items.Add($templatename.samaccountname)
        }

    $objForm.Controls.Add($objListBox) 

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()
    
    if ($cancel) {return}
    
    #Template choice error handling----------------------------------------------------------------------------

        if($chosentemplate -eq $null)  
        {
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

			$objForm = New-Object System.Windows.Forms.Form 
			$objForm.Text = "User Provisioning"
			$objForm.Size = New-Object System.Drawing.Size(400,200) 
			$objForm.StartPosition = "CenterScreen"

		    $OKButton = New-Object System.Windows.Forms.Button
			$OKButton.Location = New-Object System.Drawing.Size(75,120)
			$OKButton.Size = New-Object System.Drawing.Size(75,23)
			$OKButton.Text = "OK"
			$OKButton.Add_Click({$cancel=$true;$objForm.Close()})
			$objForm.Controls.Add($OKButton)

			$objLabel = New-Object System.Windows.Forms.Label
			$objLabel.Location = New-Object System.Drawing.Size(10,20) 
			$objLabel.Size = New-Object System.Drawing.Size(480,200) 
			$objLabel.Text = "A template must be chosen, Please start again"
			$objForm.Controls.Add($objLabel) 

			$objForm.Topmost = $True

			$objForm.Add_Shown({$objForm.Activate()})
			[void] $objForm.ShowDialog()
            
            if ($cancel) {return}
                     
        }

#User Attributes-----------------------------------------------------------------------------------------------
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    
    $objFormFN = New-Object System.Windows.Forms.Form 
    $objFormFN.Text = "User Information"
    $objFormFN.Size = New-Object System.Drawing.Size(500,500) 
    $objFormFN.StartPosition = "CenterScreen"

    $objFormFN.KeyPreview = $True
    $objFormFN.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
        {$firstname=$objTextBoxFN1.Text;$lastname=$objTextBoxFN2.Text;$UPN=$objTextBoxFN3.Text;$challenge=$objTextBoxFN4.Text;$response=$objTextBoxFN5.Text;$objFormFN.Close()}})
    $objFormFN.Add_Shown({$objFormFN.Activate(); $objTextBoxFN1.focus()})
        
    $OKButtonFN = New-Object System.Windows.Forms.Button
    $OKButtonFN.Location = New-Object System.Drawing.Size(300,400)
    $OKButtonFN.Size = New-Object System.Drawing.Size(75,23)
    $OKButtonFN.Text = "OK"
    $OKButtonFN.Add_Click({$firstname=$objTextBoxFN1.Text;$lastname=$objTextBoxFN2.Text;$UPN=$objTextBoxFN3.Text;$challenge=$objTextBoxFN4.Text;$response=$objTextBoxFN5.Text;$objFormFN.Close()})
    $objFormFN.Controls.Add($OKButtonFN)

    $CancelButtonFN = New-Object System.Windows.Forms.Button
    $CancelButtonFN.Location = New-Object System.Drawing.Size(375,400)
    $CancelButtonFN.Size = New-Object System.Drawing.Size(75,23)
    $CancelButtonFN.Text = "Cancel"
    $CancelButtonFN.Add_Click({$cancel=$true;$objFormFN.Close()})
    $objFormFN.Controls.Add($CancelButtonFN)

    #question 1 firstname
    $objLabelFN1 = New-Object System.Windows.Forms.Label
    $objLabelFN1.Location = New-Object System.Drawing.Size(10,20) 
    $objLabelFN1.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelFN1.Text = "Please enter the New Users First Name:"
    $objFormFN.Controls.Add($objLabelFN1) 

    $objTextBoxFN1 = New-Object System.Windows.Forms.TextBox 
    $objTextBoxFN1.Location = New-Object System.Drawing.Size(10,40) 
    $objTextBoxFN1.Size = New-Object System.Drawing.Size(260,20) 
    $objFormFN.Controls.Add($objTextBoxFN1)

    #question 2 lastname
    $objLabelFN2 = New-Object System.Windows.Forms.Label
    $objLabelFN2.Location = New-Object System.Drawing.Size(10,70) 
    $objLabelFN2.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelFN2.Text = "Please enter the New Users Last Name:"
    $objFormFN.Controls.Add($objLabelFN2)  

    $objTextBoxFN2 = New-Object System.Windows.Forms.TextBox 
    $objTextBoxFN2.Location = New-Object System.Drawing.Size(10,90) 
    $objTextBoxFN2.Size = New-Object System.Drawing.Size(260,20) 
    $objFormFN.Controls.Add($objTextBoxFN2)

    #question 3 UPN
    $objLabelFN3 = New-Object System.Windows.Forms.Label
    $objLabelFN3.Location = New-Object System.Drawing.Size(10,120) 
    $objLabelFN3.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelFN3.Text = "Please enter the New Users UPN\AppID:"
    $objFormFN.Controls.Add($objLabelFN3)  

    $objTextBoxFN3 = New-Object System.Windows.Forms.TextBox 
    $objTextBoxFN3.Location = New-Object System.Drawing.Size(10,140) 
    $objTextBoxFN3.Size = New-Object System.Drawing.Size(260,20) 
    $objFormFN.Controls.Add($objTextBoxFN3)

    #question 4 Challenge
    $objLabelFN4 = New-Object System.Windows.Forms.Label
    $objLabelFN4.Location = New-Object System.Drawing.Size(10,170) 
    $objLabelFN4.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelFN4.Text = "Please enter the New Users Challenge Question:"
    $objFormFN.Controls.Add($objLabelFN4)  

    $objTextBoxFN4 = New-Object System.Windows.Forms.TextBox 
    $objTextBoxFN4.Location = New-Object System.Drawing.Size(10,190) 
    $objTextBoxFN4.Size = New-Object System.Drawing.Size(260,20) 
    $objFormFN.Controls.Add($objTextBoxFN4)    

    #question 5 Response
    $objLabelFN5 = New-Object System.Windows.Forms.Label
    $objLabelFN5.Location = New-Object System.Drawing.Size(10,220) 
    $objLabelFN5.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelFN5.Text = "Please enter the New Users Response:"
    $objFormFN.Controls.Add($objLabelFN5)  

    $objTextBoxFN5 = New-Object System.Windows.Forms.TextBox 
    $objTextBoxFN5.Location = New-Object System.Drawing.Size(10,240) 
    $objTextBoxFN5.Size = New-Object System.Drawing.Size(260,20) 
    $objFormFN.Controls.Add($objTextBoxFN5)  

    $objFormFN.Topmost = $True

    $objFormFN.Add_Shown({$objFormFN.Activate()})
    [void] $objFormFN.ShowDialog()
    
    if ($cancel) {return}

#UPN Confirmation----------------------------------------------------------------------------------------

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    
    $objFormUN = New-Object System.Windows.Forms.Form 
    $objFormUN.Text = "User Information"
    $objFormUN.Size = New-Object System.Drawing.Size(500,500) 
    $objFormUN.StartPosition = "CenterScreen"

    $objFormUN.KeyPreview = $True
    $objFormUN.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
        {$UPNConfirm=$objTextBoxUN1.Text;$objFormUN.Close()}})
    $objFormUN.Add_Shown({$objFormUN.Activate(); $objTextBoxUN1.focus()})
        
    $OKButtonUN = New-Object System.Windows.Forms.Button
    $OKButtonUN.Location = New-Object System.Drawing.Size(300,400)
    $OKButtonUN.Size = New-Object System.Drawing.Size(75,23)
    $OKButtonUN.Text = "OK"
    $OKButtonUN.Add_Click({$UPNConfirm=$objTextBoxUN1.Text;$objFormUN.Close()})
    $objFormUN.Controls.Add($OKButtonUN)

    $CancelButtonUN = New-Object System.Windows.Forms.Button
    $CancelButtonUN.Location = New-Object System.Drawing.Size(375,400)
    $CancelButtonUN.Size = New-Object System.Drawing.Size(75,23)
    $CancelButtonUN.Text = "Cancel"
    $CancelButtonUN.Add_Click({$cancel=$true;$objFormUN.Close()})
    $objFormUN.Controls.Add($CancelButtonUN)

    #RECONFIRM UPN
    $objLabelUN1 = New-Object System.Windows.Forms.Label
    $objLabelUN1.Location = New-Object System.Drawing.Size(10,20) 
    $objLabelUN1.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelUN1.Text = "Please RE-ENTER the New Users UPN/APPID:"
    $objFormUN.Controls.Add($objLabelUN1) 

    $objTextBoxUN1 = New-Object System.Windows.Forms.TextBox 
    $objTextBoxUN1.Location = New-Object System.Drawing.Size(10,40) 
    $objTextBoxUN1.Size = New-Object System.Drawing.Size(260,20) 
    $objFormUN.Controls.Add($objTextBoxUN1)

    $objFormUN.Topmost = $True

    $objFormUN.Add_Shown({$objFormUN.Activate()})
    [void] $objFormUN.ShowDialog()
    
    if ($cancel) {return}



#Variables-----------------------------------------------------------------------------------------------

        $description = $chosentemplate
        
        $UPNupper = $UPN.ToUpper()
        
        $count = $UPNupper.length

#count Error Handling---------------------------------------------------------------------------------------                
        if(($count -lt 7) -or ($count -gt 8))
        {
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

			$objForm = New-Object System.Windows.Forms.Form 
			$objForm.Text = "User Provisioning"
			$objForm.Size = New-Object System.Drawing.Size(450,200) 
			$objForm.StartPosition = "CenterScreen"

			$OKButton = New-Object System.Windows.Forms.Button
			$OKButton.Location = New-Object System.Drawing.Size(75,120)
			$OKButton.Size = New-Object System.Drawing.Size(75,23)
			$OKButton.Text = "OK"
			$OKButton.Add_Click({$cancel=$true;$objForm.Close()})
			$objForm.Controls.Add($OKButton)

			$objLabel = New-Object System.Windows.Forms.Label
			$objLabel.Location = New-Object System.Drawing.Size(10,20) 
			$objLabel.Size = New-Object System.Drawing.Size(480,200) 
			$objLabel.Text = "There was an incorrect character length entered for the UPN, please try again"
			$objForm.Controls.Add($objLabel) 

			$objForm.Topmost = $True

			$objForm.Add_Shown({$objForm.Activate()})
			[void] $objForm.ShowDialog()
            
            if ($cancel) {return}
                     
        }
       
                
                
#UPN Name match error handling----------------------------------------------------

        if($UPNConfirm -ne $UPN) 
        {
            [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

			$objForm = New-Object System.Windows.Forms.Form 
			$objForm.Text = "User Provisioning"
			$objForm.Size = New-Object System.Drawing.Size(400,200) 
			$objForm.StartPosition = "CenterScreen"

			$OKButton = New-Object System.Windows.Forms.Button
			$OKButton.Location = New-Object System.Drawing.Size(75,120)
			$OKButton.Size = New-Object System.Drawing.Size(75,23)
			$OKButton.Text = "OK"
			$OKButton.Add_Click({$cancel=$true;$objForm.Close()})
			$objForm.Controls.Add($OKButton)

			$objLabel = New-Object System.Windows.Forms.Label
			$objLabel.Location = New-Object System.Drawing.Size(10,20) 
			$objLabel.Size = New-Object System.Drawing.Size(480,200) 
			$objLabel.Text = "The UPN's that were entered did not match, Please start again"
			$objForm.Controls.Add($objLabel) 

			$objForm.Topmost = $True

			$objForm.Add_Shown({$objForm.Activate()})
			[void] $objForm.ShowDialog()
            
            if ($cancel) {return}
                     
        }                
                      
        $UPNfull = $UPNupper + '@twicprogram.tsa.dhs.gov'

        $initial = (($FirstName.Substring(0,1)) + ($LastName))

        $Name = $firstname+” “+$lastname

        $password = ConvertTo-SecureString -AsPlainText -Force -String "Welcome2013!"

        $copiedtemplate = Get-ADUser -identity $chosentemplate -server rodimus.ues.sys
        
        $groups = Get-ADUser -identity $chosentemplate -Properties MemberOf -server rodimus.ues.sys
              
#error handling for existing username------------------------------------------------------------------------------------------
    
    if(!$copiedtemplate) {return}
    
    $userexists = (dsquery user -samid $initial)
    
    $i = 1
    
    if ($userexists)
    {
        if($initial -ne $null){remove-variable initial}
        
        $i++
        $initial = (($FirstName.Substring(0,$i)) + $LastName)
        $userlookup = (dsquery user -samid $initial)
    }
    Else{}

#again---------------------------------------------------------------------
    
    $userexists = (dsquery user -samid $initial)

    if ($userexists)
    {
        if($initial -ne $null){remove-variable initial}
        
        $i++
        $initial = (($FirstName.Substring(0,$i)) + $LastName)
        $userlookup = (dsquery user -samid $initial)
    }
    Else{}
    
#again----------------------------------------------------------------------

    $userexists = (dsquery user -samid $initial)
       
    if ($userexists)
    {
        if($initial -ne $null){remove-variable initial}
        
        $i++
        $initial = (($FirstName.Substring(0,$i)) + $LastName)
        $userlookup = (dsquery user -samid $initial)
    }
   
#confim-----------------------------------------------------------------------------------------------
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
    
    $objFormCN = New-Object System.Windows.Forms.Form 
    $objFormCN.Text = "User Information"
    $objFormCN.Size = New-Object System.Drawing.Size(500,500) 
    $objFormCN.StartPosition = "CenterScreen"

    $OKButtonCN = New-Object System.Windows.Forms.Button
    $OKButtonCN.Location = New-Object System.Drawing.Size(300,400)
    $OKButtonCN.Size = New-Object System.Drawing.Size(75,23)
    $OKButtonCN.Text = "OK"
    $OKButtonCN.Add_Click({$objFormCN.Close()})
    $objFormCN.Controls.Add($OKButtonCN)

    $CancelButtonCN = New-Object System.Windows.Forms.Button
    $CancelButtonCN.Location = New-Object System.Drawing.Size(375,400)
    $CancelButtonCN.Size = New-Object System.Drawing.Size(75,23)
    $CancelButtonCN.Text = "Cancel"
    $CancelButtonCN.Add_Click({$cancel=$true;$objFormCN.Close()})
    $objFormCN.Controls.Add($CancelButtonCN)

    #Confirm 1 firstname
    $objLabelCN1 = New-Object System.Windows.Forms.Label
    $objLabelCN1.Location = New-Object System.Drawing.Size(10,20) 
    $objLabelCN1.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN1.Text = "New Users First Name:"
    $objFormCN.Controls.Add($objLabelCN1) 

    $objLabelCN2 = New-Object System.Windows.Forms.Label
    $objLabelCN2.Location = New-Object System.Drawing.Size(10,40) 
    $objLabelCN2.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN2.Text = "$firstname"
    $objFormCN.Controls.Add($objLabelCN2)
	
	#Confirm 2 Lastname
	$objLabelCN3 = New-Object System.Windows.Forms.Label
    $objLabelCN3.Location = New-Object System.Drawing.Size(10,70) 
    $objLabelCN3.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN3.Text = "New Users Last Name:"
    $objFormCN.Controls.Add($objLabelCN3) 

    $objLabelCN4 = New-Object System.Windows.Forms.Label
    $objLabelCN4.Location = New-Object System.Drawing.Size(10,90) 
    $objLabelCN4.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN4.Text = "$Lastname"
    $objFormCN.Controls.Add($objLabelCN4)
	
	#Confirm 3 APPID/UPN
	$objLabelCN5 = New-Object System.Windows.Forms.Label
    $objLabelCN5.Location = New-Object System.Drawing.Size(10,120) 
    $objLabelCN5.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN5.Text = "New Users APPID/UPN:"
    $objFormCN.Controls.Add($objLabelCN5) 

    $objLabelCN6 = New-Object System.Windows.Forms.Label
    $objLabelCN6.Location = New-Object System.Drawing.Size(10,140) 
    $objLabelCN6.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN6.Text = "$UPN"
    $objFormCN.Controls.Add($objLabelCN6)
	
	#Confirm 4 Challenge
	$objLabelCN7 = New-Object System.Windows.Forms.Label
    $objLabelCN7.Location = New-Object System.Drawing.Size(10,170) 
    $objLabelCN7.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN7.Text = "New Users Challenge Question:"
    $objFormCN.Controls.Add($objLabelCN7) 

    $objLabelCN8 = New-Object System.Windows.Forms.Label
    $objLabelCN8.Location = New-Object System.Drawing.Size(10,190) 
    $objLabelCN8.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN8.Text = "$challenge"
    $objFormCN.Controls.Add($objLabelCN8)
	
	#Confirm 5 Response
	$objLabelCN9 = New-Object System.Windows.Forms.Label
    $objLabelCN9.Location = New-Object System.Drawing.Size(10,220) 
    $objLabelCN9.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN9.Text = "New Users Response:"
    $objFormCN.Controls.Add($objLabelCN9) 

    $objLabelCN10 = New-Object System.Windows.Forms.Label
    $objLabelCN10.Location = New-Object System.Drawing.Size(10,240) 
    $objLabelCN10.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN10.Text = "$response"
    $objFormCN.Controls.Add($objLabelCN10)
	
	#Confirm 6 Template
	$objLabelCN11 = New-Object System.Windows.Forms.Label
    $objLabelCN11.Location = New-Object System.Drawing.Size(10,270) 
    $objLabelCN11.Size = New-Object System.Drawing.Size(280,20) 
    $objLabelCN11.Text = "Copied from this Template:"
    $objFormCN.Controls.Add($objLabelCN11) 

    $objLabelCN12 = New-Object System.Windows.Forms.Label
    $objLabelCN12.Location = New-Object System.Drawing.Size(10,290) 
    $objLabelCN12.Size = New-Object System.Drawing.Size(280,40) 
    $objLabelCN12.Text = "$chosentemplate"
    $objFormCN.Controls.Add($objLabelCN12)
   
    $objFormCN.Topmost = $True

    $objFormCN.Add_Shown({$objFormCN.Activate()})
    [void] $objFormCN.ShowDialog()
    
    if ($cancel) {return}
    


#Creates User-----------------------------------------------------------------------------------------------
   
   
        New-ADUser -Name $name -givenname $firstname -surname $lastname -SAMAccountName $initial -AccountPassword $password `
            -DisplayName $Name -description $description -UserPrincipalName $UPNfull -path "OU=Users,OU=TrustedWorkstations,DC=UES,DC=SYS" `
            -officephone $challenge -OtherAttributes @{otherTelephone=@($response)} -server rodimus.ues.sys
        
        write-host "Creating User"
            
            #--- query until exists
            do
            {
            sleep 1
            write-host "." -nonewline
            }
            while (!(dsquery user -samid $initial))
            
#adds group memberships-------------------------------------------------------------------------------------------------                           
        write-host "Adding Groups"
        Foreach ($group in $groups.memberof)
        {
            Add-ADGroupMember $group $initial
        }
                    
            #query until matches------------------------------------
            do
            {
            $usergroups = Get-ADObject -filter {samaccountname -eq $initial} -properties memberof
            $templategroups = Get-ADObject -filter {samaccountname -eq $chosentemplate} -properties memberof
            $compared = Compare-Object -ReferenceObject $usergroups -DifferenceObject $templategroups
            write-host "." -nonewline
            }
            until ($compared -ne $null)
            

#enable smartcard logon required for TA User's---------------------------------------------------        
        if ($chosentemplate -match "UE_TA_User")
        {
            set-aduser -identity $initial -SmartcardLogonRequired $true -ChangePasswordAtLogon $false -server rodimus.ues.sys
            write-host "Enabling Smart Card Requirement"
        }
            do
            {
            sleep 1
            write-host "." -nonewline
            $smartcard = get-aduser $initial -properties smartcardlogonrequired
            Sleep 5
            }
            while ($smartcard.smartcardlogonrequired = $false)

#enable smartcard logon required for TA Admin's---------------------------------------------------        
        if ($chosentemplate -match "UE_TA_Admin_User")
        {
            set-aduser -identity $initial -SmartcardLogonRequired $true -ChangePasswordAtLogon $false -server rodimus.ues.sys
            write-host "Enabling Smart Card Requirement"
        }
            do
            {
            sleep 1
            write-host "." -nonewline
            $smartcard = get-aduser $initial -properties smartcardlogonrequired
            Sleep 5
            }
            while ($smartcard.smartcardlogonrequired = $false)

#enables the account--------------------------------------------------------      
        Enable-ADAccount -identity $initial
        write-host "Enabling User"
        
           do
            {
            if ($disabled -ne $null){remove-Variable disabled}
            write-host $disabled
            Enable-ADAccount -identity $initial
            sleep 1
            $disabled = Search-ADAccount -AccountDisabled -SearchBase "OU=Users,OU=TrustedWorkstations,DC=ues,DC=sys" | Where-Object {$_.name -eq $initial}
            write-host "." -nonewline
            }
            while ($disabled -ne $null)
    
    #Confirmation of User creation-----------------------------------------------------------------------------
                 
		if(!$error)
		{
            $newuser = (dsquery user -samid $initial)
                
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

			$objForm = New-Object System.Windows.Forms.Form 
			$objForm.Text = "User Provisioning"
			$objForm.Size = New-Object System.Drawing.Size(500,500) 
			$objForm.StartPosition = "CenterScreen"

			$objForm.KeyPreview = $True
			$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
				{$objForm.Close()}})
			$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
				{$objForm.Close()}})

			$OKButton = New-Object System.Windows.Forms.Button
			$OKButton.Location = New-Object System.Drawing.Size(375,400)
			$OKButton.Size = New-Object System.Drawing.Size(75,23)
			$OKButton.Text = "OK"
			$OKButton.Add_Click({$objForm.Close()})
			$objForm.Controls.Add($OKButton)

			$objLabel1 = New-Object System.Windows.Forms.Label
			$objLabel1.Location = New-Object System.Drawing.Size(10,20) 
			$objLabel1.Size = New-Object System.Drawing.Size(280,20) 
			$objLabel1.Text = "The User has been provisioned successfully"
			$objForm.Controls.Add($objLabel1)
            
            $objLabel2 = New-Object System.Windows.Forms.Label
			$objLabel2.Location = New-Object System.Drawing.Size(10,40) 
			$objLabel2.Size = New-Object System.Drawing.Size(380,40) 
			$objLabel2.Text = "$newuser"
			$objForm.Controls.Add($objLabel2) 

			$objForm.Topmost = $True

			$objForm.Add_Shown({$objForm.Activate()})
			[void] $objForm.ShowDialog()
		}
		Else
		{
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
			[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

			$objForm = New-Object System.Windows.Forms.Form 
			$objForm.Text = "User Provisioning"
			$objForm.Size = New-Object System.Drawing.Size(800,400) 
			$objForm.StartPosition = "CenterScreen"

			$objForm.KeyPreview = $True
			$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
				{$objForm.Close()}})
			$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
				{$objForm.Close()}})

			$OKButton = New-Object System.Windows.Forms.Button
			$OKButton.Location = New-Object System.Drawing.Size(275,320)
			$OKButton.Size = New-Object System.Drawing.Size(75,23)
			$OKButton.Text = "OK"
			$OKButton.Add_Click({;$objForm.Close()})
			$objForm.Controls.Add($OKButton)

			$objLabel = New-Object System.Windows.Forms.Label
			$objLabel.Location = New-Object System.Drawing.Size(10,20) 
			$objLabel.Size = New-Object System.Drawing.Size(480,200) 
			$objLabel.Text = "$error"
			$objForm.Controls.Add($objLabel) 

			$objForm.Topmost = $True

			$objForm.Add_Shown({$objForm.Activate()})
			[void] $objForm.ShowDialog()
        }  
}  

newuser