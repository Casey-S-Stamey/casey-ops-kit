<# 
Name: GetGroupsAndUsersFromDomain.ps1
Purpose: List all users from a specified domain. 
When to use: When using a tenant with multiple domains I at times have had to find all the users in a certain domain. This script has made it easier to pull that information quick and have a CSV file. 
Usage:
  .\GetGroupsAndUsersFromDomain.ps1 -OutputPath ".\groups-by-domain-members-$($Domain).csv"

Notes: Requires Exchange Online module and proper RBAC.
#>




# -------- Settings --------
$Domain = "domain.com"   # <= change me

# -------- Connect (safe to run if already connected) --------
try { Get-EXORecipient -ResultSize 1 -ErrorAction Stop | Out-Null }
catch { Connect-ExchangeOnline }

# -------- Find groups with the target domain --------
$dlGroups = Get-DistributionGroup -ResultSize Unlimited | Where-Object {
    $_.PrimarySmtpAddress -like "*@$Domain" -or
    ($_.EmailAddresses -match "SMTP:.*@$Domain$")
}

$uGroups = Get-UnifiedGroup -ResultSize Unlimited | Where-Object {
    $_.PrimarySmtpAddress -like "*@$Domain" -or
    ($_.EmailAddresses -match "SMTP:.*@$Domain$")
}

$allGroups = @($dlGroups + $uGroups)

# -------- Gather members for each group --------
$rows = foreach ($g in $allGroups) {
    $isM365 = ($g.RecipientTypeDetails -eq 'GroupMailbox')

    # Get members
    if ($isM365) {
        $members = Get-UnifiedGroupLinks -Identity $g.Identity -LinkType Members -ResultSize Unlimited
        $gType   = 'Microsoft 365 Group'
    } else {
        $members = Get-DistributionGroupMember -Identity $g.Identity -ResultSize Unlimited -ErrorAction SilentlyContinue
        $gType   = $g.RecipientTypeDetails
    }

    if (-not $members) {
        [pscustomobject]@{
            GroupName   = $g.DisplayName
            GroupType   = $gType
            GroupEmail  = $g.PrimarySmtpAddress
            MemberName  = '<none>'
            MemberEmail = $null
            MemberType  = $null
        }
        continue
    }

    foreach ($m in $members) {
        # Try to produce a clean email for the member
        $memberEmail = $null
        if ($m.PSObject.Properties.Match('PrimarySmtpAddress').Count -gt 0) {
            $memberEmail = $m.PrimarySmtpAddress
        }
        if (-not $memberEmail -and $m.PSObject.Properties.Match('ExternalEmailAddress').Count -gt 0) {
            $memberEmail = ($m.ExternalEmailAddress -replace '^SMTP:','')
        }

        [pscustomobject]@{
            GroupName   = $g.DisplayName
            GroupType   = $gType
            GroupEmail  = $g.PrimarySmtpAddress
            MemberName  = $m.DisplayName
            MemberEmail = $memberEmail
            MemberType  = $m.RecipientTypeDetails
        }
    }
}

# -------- Output --------
$rows | Sort-Object GroupName, MemberName | Format-Table -AutoSize

# Also drop a CSV next to where you run it
$csvPath = ".\groups-by-domain-members-$($Domain).csv"
$rows | Export-Csv -NoTypeInformation -Path $csvPath
Write-Host "`nSaved CSV to: $csvPath" -ForegroundColor Green
