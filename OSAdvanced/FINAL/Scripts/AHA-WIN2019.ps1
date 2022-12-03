# set computername (requires restart)
$HOSTNAME=hostname
$HOSTNAMETARGET="AHA-WIN2019"
if ($HOSTNAME -ne $HOSTNAMETARGET)
{
	Rename-Computer -Name AHA-LNX-DMZ
	Restart-Computer
	exit
}

# set static IP
New-NetIPAddress -IPAddress 10.11.8.10 -InterfaceAlias "Ethernet" -DefaultGateway 10.11.8.10 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1

# DHCP server
Invoke-WebRequest "https://raw.githubusercontent.com/Smile4Blitz/school/main/OSAdvanced/FINAL/WinSer/dhcpexport.xml" -OutFile "%temp%\dhcpexport.xml"
Install-WindowsFeature DHCP
Import-DhcpServer -File "%temp%\dhcpexport.xml"

# DNS server
Invoke-WebRequest "https://raw.githubusercontent.com/Smile4Blitz/school/main/OSAdvanced/FINAL/WinSer/dnsexport.xml" -OutFile "%temp%\dnsexport.xml"
Install-WindowsFeature DNS
$x = Import-Clixml "%temp%\dnsexport.xml"
Set-DnsServer -InputObject $x -ComputerName "AHA-WIN2019"