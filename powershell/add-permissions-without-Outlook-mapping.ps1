<# 
Name: add-permissions-without-Outlook.ps1
Purpose: Give someone access to a mailbox without automapping to Outlook.This can be used to monitor on the webportal and not have it take up space on desktop Outlook. 
When to use: someone needs web access to a mailbox but does not want it in Outlook
Usage:
  .\add-permissions-without-Outlook.ps1 -OutputPath -N/A

Notes: Requires Exchange Online module and proper RBAC.
#>



Add-MailboxPermission usermailbox@domain.com -User usertogetpermissions@domain.com -AccessRights FullAccess -InheritanceType All -AutoMapping $False