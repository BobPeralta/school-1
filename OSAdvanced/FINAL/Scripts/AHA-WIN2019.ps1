# static IP
# set computername (requires restart)
$HOSTNAME=hostname
$HOSTNAMETARGET="AHA-WIN2019"
if ($HOSTNAME -ne $HOSTNAMETARGET)
{
	Rename-Computer -Name AHA-LNX-DMZ
	Restart-Computer
	exit
}
else {continue}

# set static IP
New-NetIPAddress -IPAddress 10.11.8.10 -InterfaceAlias "Ethernet" -DefaultGateway 10.11.8.10 -AddressFamily IPv4 -PrefixLength 24
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 127.0.0.1

# DHCP server
# wget "dhcpexport.xml"
# install dhcpserver package
Import-DhcpServer -File "dhcpexport.xml"

# DNS server
# wget "dnsexport.xml"
$x = Import-Clixml "c:\DnsServerConfig.xml"
Set-DnsServer -InputObject $x -ComputerName "AHA-WIN2019"