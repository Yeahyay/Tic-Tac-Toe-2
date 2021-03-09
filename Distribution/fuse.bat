@echo off

rem Compress-Archive -Path 'C:\folder\*' -DestinationPath 'C:\output.zip'
copy /b "F:\Programming\Lua\Love2D\love-11.3-win64\love.exe"+%1 "%~n1.exe"

rem echo %1
rem echo "%~n1.exe"

pause