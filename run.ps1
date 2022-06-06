#Windows Updater
#By Arkam Mazrui (arkam.mazrui@gmail.com | arkam.mazrui@nserc-crsng.gc.ca) 
#This script runs _run.ps1 without any GUI or console popping up so we can install updates sneaky-beaky like

cd $PSScriptRoot;
PowerShell.exe -WindowStyle hidden {./_run.ps1 $args[0]} #passes arg[0] from run registry key to _run.ps1 line 42