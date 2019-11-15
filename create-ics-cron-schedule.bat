REM ## This is going to schedule ICS restart
REM # Schedule on system startup

set ICSONBAT="c:\ics\schtask-wrapper-ics-on.bat"

echo "Scheduling Enable ICS"
echo "Run this application when you change %ICSONBAT% ."
echo "remember, wrapper calls the 'most updated' ics routine"

schtasks /delete /tn rb\terminalics
schtasks /delete /tn rb\recuringics

REM schtasks /create /SC ONSTART /DELAY 1:00 /TN RB\TerminalICS /RU "SYSTEM" /RL HIGHEST /TR "c:\ics\wrapper.bat"

echo "Scheduling task %ICSONBAT% to run at startup
schtasks /create /SC MINUTE /MO 1  /TN RB\RecuringICS /RU "SYSTEM" /RL HIGHEST /TR "%ICSONBAT%"

REM # schtasks /create /SC MINUTE /MO 5  /TN RB\RecuringICS /RU "SYSTEM" /RL HIGHEST /TR "powershell -file 'c:\ics\enable-ics.ps1' >> c:\ics\minute.log 2>&1"
REM # schtasks /create /SC MINUTE /MO 1 /TN RB\A /RU "SYSTEM" /RL HIGHEST /TR "powershell date >> c:\ics\a.log"

echo "Enable-ics scheduled at system startup"