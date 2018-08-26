[int] $Count                  = 1
[String] $TeamMembers         = "TeamMember"
[string] $TeamName            = "Production"
[string] $Ipaddress           = '10.0.0.10'
[string] $DefaultGateway      = '10.0.0.1'
[string] $PrimaryDNS          = "10.0.0.100”
[string] $SecondaryDNS        = "10.0.0.1”
$Interfaces                   = @()

#Rename all the Network Adapters
Write-Output "Initialising Setup.."
Try{
     Get-NetAdapter | % {   
        $InterfaceName = $TeamMembers +$Count
        Rename-NetAdapter -Name $_.Name -NewName  $InterfaceName -ErrorAction stop 
        $count++
        $Interfaces +=  $InterfaceName
     }

     Get-NetAdapter

      # Create New Team and Add Members to the Team
      $NewLBFO =  New-NetLbfoTeam -Name $TeamName -TeamMembers $Interfaces[0], $Interfaces[1] -TeamingMode SwitchIndependent -TeamNicName $TeamName  -Confirm:$false -ErrorAction Stop

      #Change the Primary NIC to Standby Mode
      $SetLBFO =  Set-NetLbfoTeamMember -Name $Interfaces[0] -AdministrativeMode Standby  -Confirm:$false -ErrorAction Stop
      
      #Configure Ip address and DNS Settings
      $IPaddressConfig = New-NetIPAddress -InterfaceAlias $TeamName -IPAddress $Ipaddress -PrefixLength 24 -DefaultGateway $DefaultGateway
      $DNSSetting      = Set-DNSClientServerAddress -InterfaceAlias $TeamName –ServerAddresses $PrimaryDNS,$SecondaryDNS

      Get-NetIPAddress -InterfaceAlias $TeamName | Format-Table -AutoSize
      
     
 } 
Catch [Microsoft.Management.Infrastructure.CimException]{
      Write-Output "`nAn attempt was made to create an Team $TeamName failed as the object name already existed"
}
Catch{}
Write-Output "Script Executed Successfully"
