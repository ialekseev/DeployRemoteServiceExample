trap { exit 1 }

#######################
$userName = "domain\name" #User with access to remote computer
$password = "password" 
$pathToFolderToDeploy = "..\.." #Absolute or relative path to folder with files to deploy
$remoteServer = "nldn1111" #Remote server name
$remoteServiceName = "SuperService" #"Service name", not "Display Service name"
$remoteServicePath = "\\nldn1111\Dev\AppServer" #Path to remote server shared folder
$remoteServiceBackupPath = "\\nldn1111\Dev\Backup" #Path to remote server shared folder
#######################

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $userName,$securePassword

$service = (Get-WmiObject -Computer $remoteServer Win32_Service -Filter "Name='$remoteServiceName'" -credential $creds)

if ($Service)
{   
   Write-Output "OK.Found service"
   
   #Mounting remote folder
   Write-Output "Initialization..."
   net use $remoteServicePath /delete 
   net use $remoteServicePath /user:$userName $password

   #Backuping current service files
   Write-Output "Backuping..."
   robocopy.exe /mir $remoteServicePath $remoteServiceBackupPath

   #Stopping service   
   Write-Output "Stopping remote service..."
   $service.stopservice()

   #Copying files   
   Write-Output "Copying files..."
   robocopy.exe /mir $pathToFolderToDeploy $remoteServicePath
   
   #Starting service
   Write-Output "Starting remote service..."
   $service.startservice()

   #Removing remote folder mount
   Write-Output "Disposing..."
   net use $remoteServicePath /delete 
}