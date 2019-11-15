set logfile="c:\ics\run.log"
set TURNICSON="c:\ics\turn-ics-on.bat"



echo "#################################" >> %logfile%
echo "  In schtask-wrapper-ics-on" >> %logfile%
echo "  This is the primary file that is submitted to the Scheduler." >> %logfile%
echo "  It is the main file that is called to execute all other bats" >> %logfile%
echo "  If this file is changed, the ics cron job has to change" >> %logfile%


echo "Calling %TURNICSON% >> %logfile%

%TURNICSON% >> %logfile% 2>>&1