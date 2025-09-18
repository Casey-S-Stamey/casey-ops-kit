<# 
Name: Show_Stats_Exchange.ps1
Purpose: During an issue where the Azure Exchange Recoverable Items folder fills up we ran the scripts to clear it out but needed an easy way to monitor the status. 
 I created this to monitor the recoverable items folder. It will refresh every 30 seconds until you end the script.

When to use: When working to clear the recoverable items folder and want to monitor the progress
Usage:
  .\Show_Stats_Exchange.ps1

Notes: Requires Exchange Online module and proper RBAC.
#>
param(
    [string]$OutputPath = ".\mailbox-access.csv"
)





# Define the command to run
$command = {
    Get-MailboxFolderStatistics -Identity "user@domain.com" -FolderScope RecoverableItems | Format-Table Name,FolderAndSubfolderSize,ItemsInFolderAndSubfolders -Auto
}

# Loop to refresh every 30 seconds
while ($true) {
    $currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "Current Time: $currentTime"
    Invoke-Command -ScriptBlock $command
    Start-Sleep -Seconds 30
}