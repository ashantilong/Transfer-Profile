$OldMachineHostName = $null
$NewMachineHostName = $null
$CheckUserName = $null  
$TempDirectory = $null
$NewMachineCondition = $null
$FolderToCopy = @(
  'Desktop'<#
  'Downloads'
  'Favorites'
  'Documents'
  'Pictures'
  'Videos'
  'Setup'#>
)
Do { 
    $OldMachineHostName = Read-Host ' Enter your previous machine hostname '
        
    Try {
        Test-Connection -ComputerName $OldMachineHostName <#-Count 2 -Quiet #>-ErrorAction Stop
    
    } Catch {
        $TempOldHostName = $OldMachineHostName
        $OldMachineHostName = Write-Warning -Message "$TempOldHostName is not online. Please enter another computer name"
        continue
    } 
}
until($OldMachineHostName -ne $null)
  



Do {
  $UserDirectories = Get-ChildItem -Path "\\$OldMachineHostName\c$\Users"

  $UserDirectories

  $User = Read-Host -Prompt 'Enter the user profile to copy from the above directories'
  
  <#    
  if ( -not ( Test-Path -Path "\\$OldMachineHostName\c$\Users\$User" -PathType Container ) ) {
    Write-Warning "[$User could not be found on $OldMachineHostName]. Please enter another user profile."
    (-d $User) {
      Write-Output "list of files in the directory"
      Get-ChildItem –l $User | egrep ‘^d’
    }
    else {
      Write-Output "enter proper directory name"
      continue
    }
  } #>   
  $CheckUserName = Read-Host -Prompt "The entered user profile was:`t$User`r`nIs this correct? (y/n)"
} until (( $CheckUserName -eq "y" ) -or ( $CheckUserName -eq "yes" ))
      

Do { 
    $NewMachineHostName = Read-Host ' Enter your new machine hostname '
        
    Try {
        Test-Connection -ComputerName $NewMachineHostName -Count 2 -Quiet -ErrorAction Stop
    
    } Catch {
        $TempNewHostName = $NewMachineHostName
        $NewMachineHostName = Write-Warning -Message "$TempNewHostName is not online. Please enter another computer name"
        continue
    } 
}
until($NewMachineHostName -ne $null)
    

<#while (( $null -ne $NewMachineHostName) -and (($null -ne $NewMachineCondition) -or ('false' -ne $NewMachineCondition))) {
  $NewMachineHostName = Read-Host-Prompt ' Enter your new machine hostname '
         
  if ( -not ( Test-Connection -HostName $NewMachineHostName -Count 2 -Quiet ) ) {
    Write-Warning "$NewMachineHostName is not online. Please enter another computer name."
    continue
  }

  $NewMachineCondition = Read-Host -Prompt "The entered user profile was:`t$User`r`nIs this correct? (true/false)"
} 
#>

<#Move-Item -Path "\\$OldMachineHostName\c$\Setup" -Destination "\\$OldMachineHostName\c$\Users\$User"#> 
$Source = "\\$OldMachineHostName\c$\Users\$User"
$UserDirectory = "\\$NewMachineHostName\c$\Users"
New-Item -Path  $UserDirectory -name "tmp"  -ItemType "directory"
$Destination = $UserDirectory + "\tmp"
$RCLogFile = $Destination + "\rclogfile.log"

foreach ($Folder in $FolderToCopy) {
  $NewSource = $Source + "\" + $Folder
  $NewDestination = $Destination + "\" + $Folder
  if (!( Test-Path -Path $NewSource -PathType Container )) {
    Write-Host "Could not find path '$NewSource.'"
    continue
  }
  
  Robocopy.exe $NewSource $NewDestination /E /IS /NP /NFL /LOG+:$RCLogFile
      
}