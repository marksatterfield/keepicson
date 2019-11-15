## Restart ICS when specified MAC address not present in ARP cache (DHCP not working)

# 

# Schedule on system startup:

# schtasks /create /SC ONSTART /DELAY 0005:00 /TN RB\TerminalICS /RU SYSTEM /RL HIGHEST /TR "powershell -file c:\temp\Enable-ICS.ps1 >> c:\temp\enable-ics.log"


function global:clicksound
{
[console]::beep(500,300)


}






function global:Enable-ICS

{
# START Enable-ICS

Param (

    [String]

    [ValidateSet('status','enable','disable')]

    $state="status"

)



    $m = New-Object -ComObject HNetCfg.HNetShare

    if ($m.EnumEveryConnection -ne $null) {

         $m.EnumEveryConnection | foreach { $m.NetConnectionProps.Invoke($_) }
        #removed # in front...
    

        # Find interfaces by its network category

        $pubConnName = (Get-NetConnectionProfile | where {$_.NetworkCategory -eq 'Public'}).InterfaceAlias

        $privConnName = (Get-NetConnectionProfile | where {$_.NetworkCategory -in 'Private', 'DomainAuthenticated'}).InterfaceAlias

    

        $pubConn = $m.EnumEveryConnection | where {$m.NetConnectionProps.Invoke($_).Name -eq $pubConnName}

        $privConn = $m.EnumEveryConnection | where {$m.NetConnectionProps.Invoke($_).Name -eq $privConnName}


        echo " ... Calling Invoke with pubconn "  $pubConn
        $pubConnConf = $m.INetSharingConfigurationForINetConnection.Invoke($pubConn)

        echo " ... Calling Invoke with privconn "  $privConn
        $privConnConf = $m.INetSharingConfigurationForINetConnection.Invoke($privConn)



        switch($state) {

            'enable' {

                $pubConnConf.EnableSharing(1)

                $privConnConf.EnableSharing(0)

                echo "Write-Host 'ICS was enabled on $pubConnName as $($m.NetConnectionProps.Invoke($pubConn))"

                echo "Write-Host 'ICS was enabled on $privConnName as $($m.NetConnectionProps.Invoke($privConn))"

            }

            'disable' {

                $pubConnConf.DisableSharing()

                $privConnConf.DisableSharing()

                echo "Write-Host 'ICS was disabled on all interfaces"

                echo "Write-Host '$pubConnName : $($m.NetConnectionProps.Invoke($pubConn))"

                echo "Write-Host '$privConnName : $($m.NetConnectionProps.Invoke($privConn))"

            }

            'status' {

                $m.NetConnectionProps.Invoke($pubConn)

                $pubConnConf

                $m.NetConnectionProps.Invoke($privConn)

                $privConnConf

            }

            default {

                echo "Write-Warning 'Valid operations are: enable | disable | status"

            }

        }

    } else {

        echo "Write-Error 'No ICS connection found. Are you admin?"

    }
# END Enable-ICS
}






# START of main routine

echo "#  START: enable-ics.ps1"


# Find MAC of the terminal device

$try = 0
$testip="192.168.137.1"
$testmac="48-f8-b3-c6-47-f6"

# 48-f8-b3-c6-47-f6 is Cisco Linksys

echo "Searching for router IP " $testip " at MAC " $testmac

$routerinfo=(arp -a -N $testip | where {$_ -like "*$testmac*"})

# Router is found or not found...


if ($routerinfo -eq $null) {
    echo "PROBLEM!  Router not found"
    echo "    Returned: $routerinfo"

    echo "Status ICS..."
    global:Enable-ICS -State status
    echo "Disbling ICS...."
    global:Enable-ICS -State disable
    echo "Enabling ICS...."
    global:Enable-ICS -State enable

} else {
    echo "GOOD!  Router found!  This means ICS is enabled!"

}




while ((arp -a -N $testip | where {$_ -like "*$testmac*"}) -eq $null -and $try++ -lt 2) {

    
    
    echo "Write-Warning 'Router is not connected, trying to restart ICS..."

    echo " ... Disabling ICS"
    global:Enable-ICS -state disable

    echo " ... Sleeping 5"
    Start-Sleep -Seconds 5

    echo " ... Enabling ICS"
    global:Enable-ICS -state enable

    echo " ... Sleeping 5"
    Start-Sleep -Seconds 5

}

if ($try -eq 2) {

    echo "Write-Error 'Router was not found on network after 3 attempts"

} else {

    global:clicksound

    echo "Write-Information 'Router is connected"
	
	echo "ECHO: Router is connected"

    $ip = (arp -a -N $testip | where {$_ -like "*$testmac*"}).Trim().Split(' ')[0]

    if (Test-Connection $ip -quiet) {

        echo "Write-Information ' and responds to ping"

    } else {

        echo "Write-Warning ' but not responding to ping"

    }


    echo "#  END: enable-ics.ps1"

}