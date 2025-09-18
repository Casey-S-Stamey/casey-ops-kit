<# 
Name: SharedCalendarAudit.ps1
Purpose: Export a list of the shared calendars that a user has access to. 
When to use: Offboarding, access reviews, or incident checks
Usage:
  .\Get-MailboxAccessAudit.ps1 -OutputPath .\mailbox-access.csv

Notes: Requires Exchange Online module and proper RBAC.
#>
param(
    [string]$OutputPath = ".\mailbox-access.csv"
)





# Connect to Exchange Online
$UserCredential = Get-Credential
Connect-ExchangeOnline -UserPrincipalName $UserCredential.UserName -Password $UserCredential.GetNetworkCredential().Password

# Define the user email address
$userEmail = "acompton@fowlerins.com"

# Get the list of mailboxes the user has access to
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Initialize an array to store shared calendars
$sharedCalendars = @()

# Loop through each mailbox to check calendar permissions
foreach ($mailbox in $mailboxes) {
    $calendarPermissions = Get-MailboxFolderPermission -Identity "$($mailbox.PrimarySmtpAddress):\Calendar" -ErrorAction SilentlyContinue
    if ($calendarPermissions) {
        foreach ($permission in $calendarPermissions) {
            if ($permission.User -like $userEmail) {
                $sharedCalendars += $mailbox.PrimarySmtpAddress
            }
        }
    }
}

# Output the list of shared calendars
Write-Output "Shared calendars the user is a member of:"
$sharedCalendars

