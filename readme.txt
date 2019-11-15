
wrapper.bat -
Schedule Task wrapper.  Main file called.  
It calls ics.bat


ics.bat - 

Pings destination google
Then calls powershell enable-ics.ps1


enable-ics.ps1

Restart ics when specified MAC address is not present in ARP cache 
