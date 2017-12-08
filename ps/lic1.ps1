################################################################
# AUTHOR  : Ryan heath <ryan.heath@software2.com> - @RyanAtS2
# DATE    : 07-12-2017
# EDIT    : 07-12-2017
# COMMENT : This script creates initiates the download of the
#           Zend Server license updater
# VERSION : 1.0
################################################################

# CHANGELOG
# Version 1.0: 07-12-2017
# - Initial Version - Downloads the Zend Server Licensing PHAR

Add-Type -AssemblyName System.IO.Compression.FileSystem

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] “Administrator”))
{
    # We require admin privileges so exit with a warning
    Write-Warning "This script requires administrator rights in order to run."
    Write-Warning "Please right click and 'Run as Administrator' when running Powershell!"
    Write-Host "Press any key when complete..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Exit (1)
}


function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function SendResults
{
    param([string]$result)

    # Gather Computer Details
    $computer = gc env:computername
    $domain = $env:USERDNSDOMAIN
    If (!$domain) { $domain = "Unknown" }
    # Setup a mail client
    $SMTPServer = "smtp.sendgrid.net"
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential("s2hub", "53882%QOHXhU7BUcgswi")
    $SMTPClient.EnableSsl = $false
    # Create the message
    $msg = New-Object Net.Mail.MailMessage
    $msg.From = "ryan.heath@software2.com"
    $msg.To.Add("ryan@software2.co.uk")
    $msg.Subject = "ZS Lic $result for $computer@$domain"
    $date = date
    $msg.Body = @"
    `n Logged On User:  $env:USERNAME
    `n User Domain:     $env:USERDOMAIN
    `n Computer Name:   $env:COMPUTERNAME
    `n Computer Domain: $domain
    `n Execution Time:  $date
    `n Result:          $result
    `n
    `n RESULT IS AN ESTIMATION - CONFIRM USING ATTACHED OUTPUT!!
"@
    # Add the output as an attachment
    $outputFilePath = "$tempDir\$tempFolderName\results.txt"
    $ouputFile = New-Object Net.Mail.Attachment($outputFilePath)
    $msg.Attachments.Add($ouputFile)
    # Send the email
    $SMTPClient.Send($msg)
    $ouputFile.Dispose()

}

# ERROR REPORTING ALL
Set-StrictMode -Version latest

# Script variables
$licManagerUrl = 'https://1bdb4cc9b0722bc205a3-77fabbc4511a62a47f7610ad5c7c4e62.ssl.cf3.rackcdn.com/lic/S2HubLic.phar'

$tempDir = $env:TEMP
$tempFolderName= 'S2HubLic'
$downloadLoc = "$tempDir\$tempFolderName"

# Create a new directory in the temp folder
if (Test-Path "$downloadLoc") {
    Remove-Item -Recurse -Force $downloadLoc
}

New-Item -ItemType directory -Path "$downloadLoc" > $null

# Download the Zend Server License Manager
$start_time = Get-Date
Write-Host "Downlading Zend Server License Manager..."
Invoke-WebRequest -Uri "$licManagerUrl" -OutFile "$downloadLoc\S2HubLic.phar"
Write-Host "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"

# Run the license manager
Write-Host "Executing Zend Server License Manager..."
# Unzip "$downloadLoc\deployment.zip" "$downloadLoc"
Set-Content -Value "ZS Licensing Manager Results..." -Path "$downloadLoc\results.txt"
If (Test-Path "$downloadLoc\S2HubLic.phar") {
    & php "$downloadLoc\S2HubLic.phar" *> "$downloadLoc\results.txt"
} Else {
    Add-Content -Value "Couldn't even locate the file to run!" -Path "$downloadLoc\results.txt"
}

# Determine success from the exit code from the script
if ($lastExitCode -eq 0)  {
    $result = "SUCCESS"
} Else {
    $result = "FAIL [$lastExitCode]"
}

# Send an e-mail with the results
SendResults $result

Exit(0)