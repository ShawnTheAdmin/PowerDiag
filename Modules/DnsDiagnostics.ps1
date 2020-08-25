#regsion DnsFunctions
function Test-DnsRootHints { 
    <#
    .SYNOPSIS
    Test all configured root hints for connectivity. 
    .DESCRIPTION
    Retries all root hints on a DNS server and then checks each for connectivity
    .EXAMPLE
    test-roothints
    #>
    [CmdletBinding()]
    param (

    )
    $roothints = Get-DnsServerRootHint
    $errors = 0

    Write-Output "Testing all root hints for connectivity: `n"

    foreach ($hint in $roothints) { 

        $nameserver = $hint.NameServer.RecordData.NameServer

        if ($hint.IPAddress.RecordType -eq "A") { 
            #IPv4
            $address = $hint.IPAddress.RecordData.IPV4Address.IPAddressToString
            if (test-connection $address -count 1 -quiet) { 
                write-host "$nameserver with address $address resolves." -ForegroundColor Green
            }
            else { 
                write-host "$nameserver with address $address does not resolve." -ForegroundColor Red
                $errors += 1
            }
        } 

        else {
            # IPv6
            $address = $hint.IPAddress.RecordData.IPV6Address.IPAddressToString
            Write-Host -ForegroundColor 'Red' -Object "$nameserver resolves to $address. IPv6 root hints shouldn't be used. See link at the bottom."
            $errors += 1
            #     if (Test-Connection $address -Count 1 -Quiet) { 
            #         write-host "$nameserver with address $address resolves." -ForegroundColor Green
            #     }
            #     else { 
            #         write-host "$nameserver with address $address does not resolve." -ForegroundColor Red
            #         $errors += 1
            #     }
            # }
        }
    
        if ($errors -gt 0) { 
            Write-Host "`nThere are $errors root hints not resolving. See https://www.iana.org/domains/root/files for corrections." -ForegroundColor Yellow
        }
    }
}

function Test-DnsForwarders { 
    <#
    .SYNOPSIS
    Checks for DNS forwarders configured on the server.
    .DESCRIPTION
    Checks for DNS forwarders and makes sure they can be resolved. Then prompts user to remove them due to best practices.
    .PARAMETER remove
    Skips confirmation for forwarder removal and removes all forwarders from the system.
    #>
    [CmdletBinding()]
    param(
        [switch]$remove
    )
    $forwarders = (Get-DnsServerForwarder).IPAddress.IPAddressToString

    if ($forwarders) { 
        Write-Output "DNS Forwarders found. Testing connectivity for each.`n"
        foreach ($forwarder in $forwarders) { 
            if (Test-Connection $forwarder -Count 2 -Quiet) { 
                Write-Host "Forwarder with IP address $forwarder resolves." -ForegroundColor Green
            }
            else { 
                Write-Host "Forwarder with IP address $forwarder does not resolve." -ForegroundColor Red
            }
        }
        if ($PSBoundParameters.ContainsKey($remove)) { 
            foreach ($forwarder in $forwarders) { 
                Remove-DnsServerForwarder -IPAddress $forwarder -Force
            }
        }
        else {
            $challenge = read-host "`nBest Practice is to not use forwarders. Remove all forwarders? (y/N)"

            if ([string]::IsNullOrWhiteSpace($challenge)) { 
                $challenge = "n"
            }

            if ($challenge -eq "y") { 
                foreach ($forwarder in $forwarders) { 
                    Remove-DnsServerForwarder -IPAddress $forwarder -Force
                    Write-Host "`nRemoving forwarder with address $forwarder.`n" -ForegroundColor Yellow
                }
            }
            else { 
                break
            }
        }

    }
    else { 
        Write-Output "No Forwarders found!"
    }
}
#endregion DnsFunctions

function Start-DnsDiagnostic {
    <#
        .SYNOPSIS
        Wrapper for all of the DNS test. Called in the main run-diagnostics function.
        #>
        
    # Run root hint test
    write-host -ForegroundColor 'yellow' -Object "Running DNS Root Hints test."
    Test-DnsRootHints

    # Run forwarder test
    write-host -ForegroundColor 'yellow' -Object "Running DNS Forwarder test."
    Test-DnsRootHints
}