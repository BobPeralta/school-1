# static IP
# set computername (requires restart?)
# set static IP

# DHCP server
# wget "dhcpexport.xml"
# install dhcpserver package
Import-DhcpServer -File "dhcpexport.xml"

# DNS server
# wget "dnsexport.xml"
$x = Import-Clixml "c:\DnsServerConfig.xml"
Set-DnsServer -InputObject $x -ComputerName "AHA-WIN2019"