#Windows Updater
#By Arkam Mazrui (arkam.mazrui@gmail.com | arkam.mazrui@nserc-crsng.gc.ca) 
#This script retrieves a list of current updates and installs it to the machine
#Note:
#You need to replace the 'send-log-to-server' function with your own &
#change the logpath on line 25 to your own

function test-connection-to-internet {
    $maxRetry = 50;
    $connStatus = $False;
    $attemptNum = 1;
    $sleepTime = 5;
    do {
        Write-Host "Attempting to connect ($attemptNum / $maxRetry)...";
        $connStatus = (Test-NetConnection).PingSucceeded;
        if (!($connStatus)) {sleep $sleepTime;}
    } while ($connStatus -eq $False);
    return $connStatus;
}


#Replace this function with the function that points to your log server + uses your auth token
function send-log-to-server {
    Param([String]$full_log_path)
    $server = '#####'; #fill in
    $log_str = Get-Content $full_log_path -Delimiter '!!!!!!!!';
    $req_data = @{auth="####";data=(@{pc_name=$(hostname);log_str=$log_str} | ConvertTo-Json)} | ConvertTo-Json #fill in auth
    if ($log_str -and (test-connection-to-internet)) {
        Invoke-WebRequest -Uri $server -Method 'POST' -ContentType 'application/json' -Body $req_data;
    }
}


cd $PSScriptRoot;

$logpath = "./log.log"; #change log path to what you want
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run";
$regName = "UpdateComplete";

Start-Transcript $logpath -Append;

if ($args[0] -eq 'reboot') {
    Write-Host "Completed reboot. Attempting to discover if update completed...";
    $updates = Get-WindowsUpdate;
    if ($updates.Count -eq 0) {
        Write-Host "No more updates left to install.";
    } else {
        Write-Host "Updates remaining: ";
        $updates | Select Title | Out-Host;
    }

    Stop-Transcript;
    send-log-to-server;

    Remove-ItemProperty -Path $regPath -Name $regName;
    exit;
}

if (!(Get-Module PSWindowsUpdate)) {
    Write-Host "PSWindowsUpdate not found, installing..."
    Install-Module PSWindowsUpdate -Force;
}

$updates = Get-WindowsUpdate;

if ($updates.Count) {
    Write-Host "Updates found: ";
    $updates | Select Title | Out-Host;

    Write-Host "Will now attempt to update PC."
    $arg = "powershell.exe $PSScriptRoot\run.ps1 reboot";
    New-ItemProperty -Path $regPath -Name $regName -Value $arg;
    Stop-Transcript;

    Get-WindowsUpdate -AcceptAll -Install -AutoReboot;

}

