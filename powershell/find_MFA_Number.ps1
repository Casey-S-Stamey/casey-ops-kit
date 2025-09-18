<# 
Name: Find MFA Numbers.ps1
Purpose: Find what phone number is being used for MFA
When to use: Offboarding, access reviews, or incident checks
Usage:
  .\find_MFA_Numbers.ps1 -OutputPath .\MFAStatus.csv

Notes: Requires Exchange Online module and proper RBAC.
#>



Connect-MsolService

$MFAPhone=$_.StrongAuthenticationUserDetails.PhoneNumber


Get-MsolUser -All |
    Select-Object DisplayName, @{
        Name = "MFA Status"
        Expression = { $_.StrongAuthenticationRequirements.State }
    }, @{
        Name = "MFAPhone"
        Expression = { $_.StrongAuthenticationUserDetails.PhoneNumber }
    } |
    Export-Csv -NoTypeInformation -Path "C:\USB-Garbaggio\MFAStatus.csv"