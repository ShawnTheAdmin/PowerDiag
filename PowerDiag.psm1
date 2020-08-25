. (Join-Path $PSScriptRoot .\Modules\AdDiagnostics.ps1)
. (Join-Path $PSScriptRoot .\Modules\DnsDiagnostics.ps1)

function start-countdown { 
    <#
    .SYNOPSIS
    Simple function that initiates a countdown from the specified value (length)
    .PARAMETER length
    Specify upper limit that the countdown should start from. Default 5.
    #>
    [CmdletBinding()]
    param(
        $length = 5
    )
    for ($i = $length; $i -gt 0; $i--) { 
        Write-Output $i
    }
}


function Start-Diagnostic {
    <#
    .SYNOPSIS
    Main wrapper for this overall module. Presents the user with a menu of different test that can be ran. 
    #>
    [CmdletBinding()]
    param(

    )

    # List of available options. The menu is populated dynamically via the foreach loop below this. Add odditional options here.
    $availableOpt = 'Active Directory', 'DNS', 'DHCP', 'Net Admin', 'Generate Password'

    # Foreach loop that dynamically builds menu that users is presented with. Do NOT change $idx, should always start at 1. 
    $IDX = 1
    foreach ($i in $availableOpt) {
        write-host "$idx.) $i"
        $idx++
    }

    $selection = read-host "Enter number of test to run"

    # Runs the test selected by the user. If more test are added to $availableOpt, switch statements must be added here.
    switch ($selection) {
        1 { write-host -ForegroundColor 'yellow' -Object "Running Active Directory test.."; start-countdown }
        2 { write-host -ForegroundColor 'yellow' -Object "Running DNS test.."; start-countdown; Start-DnsDiagnostic }
        3 { write-host -ForegroundColor 'yellow' -Object "Running DHCP test.."; start-countdown }
        4 { write-host -ForegroundColor 'yellow' -Object "Generating Net Admin Reports.."; start-countdown }
    }
}
