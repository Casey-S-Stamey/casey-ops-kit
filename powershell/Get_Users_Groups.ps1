<# 
Name: Get_Users_Groups.ps1
Purpose: Get a list of the groups that a user is in. 
When to use: When you need to see a list of groups that a user is currently in. 
Usage:
  .\Get_Users_Groups.ps1 -OutputPath -N/A

Notes: Requires Exchange Online module and proper RBAC.
#>




# Connect first
Connect-ExchangeOnline

# Replace with your user
$upn = "user@domain.com"

# Get the user's DistinguishedName
$dn = (Get-User -Identity $upn).DistinguishedName

# Now filter groups where the user is a direct member
Get-Recipient -RecipientTypeDetails GroupMailbox,MailUniversalDistributionGroup,MailUniversalSecurityGroup `
  -Filter "Members -eq '$dn'" |
  Select-Object Name, RecipientTypeDetails, PrimarySmtpAddress
