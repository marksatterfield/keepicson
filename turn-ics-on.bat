echo off

set pingdest="google.com"
set icsps="c:\ics\enable-ics.ps1"
set WIFI="jas"
set NETSHWLAN=netsh wlan connect name=%WIFI%

echo "#### START turn-ics-on.bat --------------------------------------------" 
echo " "
date /t 
time /t 
echo " "  

echo " Confirming connection to %NETSHWLAN%"
netsh wlan connect name=%WIFI%

echo "   Pinging " %pingdest%    
ping -n 1 %pingdest%     
echo " "   

echo "calling " %icsps% 
powershell -file %icsps%

ping -n 1 %pingdest%    
echo " "
echo "#### END ics.bat --------------------------------------------" 
