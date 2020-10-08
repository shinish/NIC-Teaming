#Author: Shinish Sasidharan
#url   : Powershellhacks.com
#email : Shinish@live.com

[CmdletBinding()]
param (
      
      [int] 
      $Count = 1,

      [String] 
      $TeamMembers = "TeamMember",

      [string] 
      $TeamName = "Production",

      [string] 
      $Ipaddress = '192.168.64.100',

      [string] 
      $DefaultGateway = '192.168.64.1',

      [string] 
      $PrimaryDNS = '192.168.64.100',

      [string] 
      $SecondaryDNS = '192.168.64.1'
)



$Interfaces = @()

#Rename all the Network Adapters
Write-Output 'Initialising Setup..'
Try {
      Get-NetAdapter | ForEach-Object {   
            $InterfaceName = $TeamMembers + $Count
            Rename-NetAdapter -Name $_.Name -NewName  $InterfaceName -ErrorAction stop 
            $count++
            $Interfaces += $InterfaceName
      }

      Get-NetAdapter

      # Create New Team and Add Members to the Team
      New-NetLbfoTeam -Name $TeamName -TeamMembers $Interfaces[0], $Interfaces[1] -TeamingMode SwitchIndependent -TeamNicName $TeamName  -Confirm:$false -ErrorAction Stop | Out-Null


      #Change the Primary NIC to Standby Mode
      Set-NetLbfoTeamMember -Name $Interfaces[0] -AdministrativeMode Standby  -Confirm:$false -ErrorAction Stop | Out-Null
      
      #Configure Ip address and DNS Settings
      New-NetIPAddress -InterfaceAlias $TeamName -IPAddress $Ipaddress  -PrefixLength 24  -DefaultGateway $DefaultGateway | out-null
      Set-DNSClientServerAddress -InterfaceAlias $TeamName -ServerAddresses $PrimaryDNS, $SecondaryDNS | out-null

      Get-NetIPAddress -InterfaceAlias $TeamName | Format-Table -AutoSize
      
     
}
Catch [Microsoft.Management.Infrastructure.CimException] {
      Write-Output '`nAn attempt was made to create an Team $TeamName failed as the object name already existed'
}
Catch {
      $Error.exception.message
}
Write-Output 'Script Executed Successfully'
