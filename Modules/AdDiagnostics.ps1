#region ActiveDirectoryFunctions
function Get-AccountLockouts { 
    <#
    .SYNOPSIS
    Retrieves all account lockout events in the past 24 hours.
    #>
    [CmdletBinding()]
    param( 

    )

    BEGIN {
        $PDC = Get-ADDomainController -Discover -Service PrimaryDC
        $UserAccount = @{Name = 'User Name'; Expression = { $_.Properties[0].Value } }
        $SourceHost = @{Name = 'Source Host'; Expression = { $_.Properties[1].Value } }
        $EventID = @{Name = 'Event ID'; Expression = { "4740" } }
        $EventDescription = @{Name = 'Event Description'; Expression = { "User LockOut" } }
        $AuditAccountLockoutSetToSuccess = auditpol.exe /get /subcategory:"Account Lockout"
    }

    PROCESS {
        if ($AuditAccountLockoutSetToSuccess -like "*Success*") {
            Write-Host "Audit Logging in place to record Account Lockout Events" -ForegroundColor Green
        }
        else {
            Write-Host "Audit logging does not appear to be in place for this. To turn this on go to Logon/Logoff in Avanced Audit Configuration in Group Policy and set the subcategory 'Audit Account Lockout' to 'Success'" -ForegroundColor Yellow
        }
        Get-WinEvent -ComputerName $PDC -Logname Security -FilterXPath "*[System[EventID=4740]]" |
        Select-Object $EventID, $EventDescription, TimeCreated, $UserAccount, $SourceHost | Format-Table -AutoSize
    }
}
#endregion ActiveDirectoryFunctions