Echo "Starting"
$HostName = hostname
if ($HostName -ne "AHA-WIN2019")
{
    Echo "We first have to set your hostname correctly."
    Rename-Computer -NewName AHA-WIN2019 -Confirm
    Echo "Restart required, PC will restart in 5 seconds, then run the script again."
    Echo "CHANGE YOUR ADAPTER"
    Start-Sleep -Seconds 5
    Restart-Computer
}

# Set static IP
Echo "Setting static IP"

Remove-NetIPAddress -InterfaceAlias "Ethernet0" -Confirm:$false -ErrorAction SilentlyContinue 
Remove-NetRoute -InterfaceAlias "Ethernet0" -Confirm:$false  -ErrorAction SilentlyContinue

New-NetIPAddress -IPAddress 10.11.8.10 -InterfaceAlias "Ethernet0" -DefaultGateway 10.11.8.8 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 1.1.1.1

# Letting the Windows server load the network settings properly (throws error on hostname lookup later)
Echo "Loading network settings"
Start-Sleep -Seconds 5

# DHCP server
Echo "Setting up the DHCP server"
Invoke-WebRequest "https://raw.githubusercontent.com/Smile4Blitz/school/main/OSAdvanced/FINAL/WinSer/dhcpexport.xml" -OutFile "$env:temp\dhcpexport.xml"
Install-WindowsFeature DHCP -IncludeManagementTools
Import-DhcpServer -Confirm:$false -File "$env:temp\dhcpexport.xml" -BackupPath "C:\dhcpbackup"

# DNS server
Echo "`nSetting up the DNS server"
Install-WindowsFeature DNS -IncludeManagementTools

Add-DnsServerPrimaryZone -Name aha.local -DynamicUpdate NonsecureAndSecure -Confirm -ZoneFile "aha.local.dns"
Add-DnsServerPrimaryZone -NetworkId 10.11.8.0/24 -DynamicUpdate NonsecureAndSecure -ZoneFile "8.11.10.in-addr.arpa.dns"
Add-DnsServerPrimaryZone -NetworkId 10.12.8.0/24 -DynamicUpdate NonsecureAndSecure -ZoneFile "8.12.10.in-addr.arpa.dns"
Add-DnsServerPrimaryZone -NetworkId 10.99.8.0/24 -DynamicUpdate NonsecureAndSecure -ZoneFile "8.99.10.in-addr.arpa.dns"

# Forwarders
Add-DnsServerForwarder -IPAddress 1.1.1.1
Add-DnsServerForwarder -IPAddress 8.8.8.8

# Installing Firefox
$regKey = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion"
$Core = (Get-ItemProperty $regKey).InstallationType -eq "Server Core"

if ($Core -eq $False) {
    
    if ((Test-Path -Path "C:\Program Files\Mozilla Firefox\Firefox.exe") -eq $false)
    {
        Echo "`nInstalling Firefox"
        Invoke-WebRequest "https://download-installer.cdn.mozilla.net/pub/firefox/releases/107.0.1/win64/en-US/Firefox%20Setup%20107.0.1.msi" -OutFile "$env:temp\firefox.msi"
        msiexec.exe /I "$env:temp\firefox.msi" /quiet
    }
}

# Cleanup
Echo "`nCleaning up"
Remove-Item "$env:temp\dhcpexport.xml"
if ((Test-Path -Path "C:\Program Files\Mozilla Firefox\Firefox.exe") -eq $true)
{
    Remove-Item "$env:temp\firefox.msi"
}

Echo "Done, PC will restart in 5 seconds."
Start-Sleep -Seconds 5
Restart-Computer
