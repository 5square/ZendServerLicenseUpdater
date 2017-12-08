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
# SIG # Begin signature block
# MIIeeQYJKoZIhvcNAQcCoIIeajCCHmYCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNkL/0MtBp4H0AH/ToVEkZkVN
# 6dagghl7MIIFeDCCBGCgAwIBAgIQDEbbvOoSOoHBXAZAmpvZCDANBgkqhkiG9w0B
# AQsFADBsMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSswKQYDVQQDEyJEaWdpQ2VydCBFViBDb2Rl
# IFNpZ25pbmcgQ0EgKFNIQTIpMB4XDTE3MDgyMjAwMDAwMFoXDTE4MDgyMjEyMDAw
# MFowgZYxEzARBgsrBgEEAYI3PAIBAxMCR0IxHTAbBgNVBA8MFFByaXZhdGUgT3Jn
# YW5pemF0aW9uMREwDwYDVQQFEwgwNzAxODc2MTELMAkGA1UEBhMCR0IxDjAMBgNV
# BAcTBUxlZWRzMRcwFQYDVQQKEw5Tb2Z0d2FyZTIsIEx0ZDEXMBUGA1UEAxMOU29m
# dHdhcmUyLCBMdGQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDDceAo
# npvpZ6GDBBahBS02ZdJ9P2Xnm2fLGJKai/tdpUnIiHR6uNO459npmiHQroGogeXB
# GmExIR/nPCrwKAApwEr5DfC9MUiKNtPBxrkk/kreMVjwNlB9qCkkn13DXALmkXd8
# JHi9P8Nc5NIFoPWrBsJd/LiYJDmKe1DZpDR/LvVIuZKGsjnkAXQkIXnJO6Gxy63Z
# gfnCEkJpsqgtuLRuE2PPguOj/0hrqahX4OKP4TK5mCyxlmV317b3kaDuCkvWLgW/
# s3Wit/j82hWSI2/+3kO5KO1c4oH614IEuZwT0EQ7X6ND6bstiGt/Nk3yov5n3ENb
# Vr7Hs2G5gt9eNoerAgMBAAGjggHpMIIB5TAfBgNVHSMEGDAWgBSP6H7wbTJqAAUj
# x3CXajqQ/2vq1DAdBgNVHQ4EFgQUW97B3SaWER78glxmsbIloEDwLM4wJgYDVR0R
# BB8wHaAbBggrBgEFBQcIA6APMA0MC0dCLTA3MDE4NzYxMA4GA1UdDwEB/wQEAwIH
# gDATBgNVHSUEDDAKBggrBgEFBQcDAzB7BgNVHR8EdDByMDegNaAzhjFodHRwOi8v
# Y3JsMy5kaWdpY2VydC5jb20vRVZDb2RlU2lnbmluZ1NIQTItZzEuY3JsMDegNaAz
# hjFodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRVZDb2RlU2lnbmluZ1NIQTItZzEu
# Y3JsMEsGA1UdIAREMEIwNwYJYIZIAYb9bAMCMCowKAYIKwYBBQUHAgEWHGh0dHBz
# Oi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwBwYFZ4EMAQMwfgYIKwYBBQUHAQEEcjBw
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wSAYIKwYBBQUH
# MAKGPGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEVWQ29kZVNp
# Z25pbmdDQS1TSEEyLmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3DQEBCwUAA4IB
# AQBbxH9iCVuWmcVz1Tu5jEz4cyUzSNdaiI0HsEy5KhfUh8EIXO3pZxzBQkDptqla
# 2AFcVMH2eK8nCPzyGD7yds7taNTII1cRb1s3WAL9Iv6HnjWAmy2I7ZIXiBN1vie8
# uEcUgXIBLSmSJZ6OqcLj92r6JOHgkqLG2FPKgglXnEObXn5/siafLoG3dgjD141x
# 9NLMA1UjR1rZ9yI7S6tAOmZjBxxtH3p2XDCnxdtWqES4sraH9qtW8di6zIWcOWnV
# mFyeH3vS5TluuUwL85q8vQDNefNUlNOEHZZT6mjCZ20VpTVgDbICKMVrvuNAy79l
# iWQEilq4iVhOXK+2LQm3zirgMIIGajCCBVKgAwIBAgIQAwGaAjr/WLFr1tXq5hfw
# ZjANBgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdp
# Q2VydCBBc3N1cmVkIElEIENBLTEwHhcNMTQxMDIyMDAwMDAwWhcNMjQxMDIyMDAw
# MDAwWjBHMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJTAjBgNVBAMT
# HERpZ2lDZXJ0IFRpbWVzdGFtcCBSZXNwb25kZXIwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQCjZF38fLPggjXg4PbGKuZJdTvMbuBTqZ8fZFnmfGt/a4yd
# VfiS457VWmNbAklQ2YPOb2bu3cuF6V+l+dSHdIhEOxnJ5fWRn8YUOawk6qhLLJGJ
# zF4o9GS2ULf1ErNzlgpno75hn67z/RJ4dQ6mWxT9RSOOhkRVfRiGBYxVh3lIRvfK
# Do2n3k5f4qi2LVkCYYhhchhoubh87ubnNC8xd4EwH7s2AY3vJ+P3mvBMMWSN4+v6
# GYeofs/sjAw2W3rBerh4x8kGLkYQyI3oBGDbvHN0+k7Y/qpA8bLOcEaD6dpAoVk6
# 2RUJV5lWMJPzyWHM0AjMa+xiQpGsAsDvpPCJEY93AgMBAAGjggM1MIIDMTAOBgNV
# HQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcD
# CDCCAb8GA1UdIASCAbYwggGyMIIBoQYJYIZIAYb9bAcBMIIBkjAoBggrBgEFBQcC
# ARYcaHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCCAWQGCCsGAQUFBwICMIIB
# Vh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkA
# ZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAA
# dABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAA
# LwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIA
# dAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQA
# IABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIA
# cABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUA
# bgBjAGUALjALBglghkgBhv1sAxUwHwYDVR0jBBgwFoAUFQASKxOYspkH7R7for5X
# DStnAs0wHQYDVR0OBBYEFGFaTSS2STKdSip5GoNL9B6Jwcp9MH0GA1UdHwR2MHQw
# OKA2oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RENBLTEuY3JsMDigNqA0hjJodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURDQS0xLmNybDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGG
# GGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2Nh
# Y2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcnQwDQYJ
# KoZIhvcNAQEFBQADggEBAJ0lfhszTbImgVybhs4jIA+Ah+WI//+x1GosMe06Fxlx
# F82pG7xaFjkAneNshORaQPveBgGMN/qbsZ0kfv4gpFetW7easGAm6mlXIV00Lx9x
# sIOUGQVrNZAQoHuXx/Y/5+IRQaa9YtnwJz04HShvOlIJ8OxwYtNiS7Dgc6aSwNOO
# Mdgv420XEwbu5AO2FKvzj0OncZ0h3RTKFV2SQdr5D4HRmXQNJsQOfxu19aDxxncG
# KBXp2JPlVRbwuwqrHNtcSCdmyKOLChzlldquxC5ZoGHd2vNtomHpigtt7BIYvfdV
# VEADkitrwlHCCkivsNRu4PQUCjob4489yq9qjXvc2EQwgga8MIIFpKADAgECAhAD
# 8bThXzqC8RSWeLPX2EdcMA0GCSqGSIb3DQEBCwUAMGwxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# KzApBgNVBAMTIkRpZ2lDZXJ0IEhpZ2ggQXNzdXJhbmNlIEVWIFJvb3QgQ0EwHhcN
# MTIwNDE4MTIwMDAwWhcNMjcwNDE4MTIwMDAwWjBsMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSsw
# KQYDVQQDEyJEaWdpQ2VydCBFViBDb2RlIFNpZ25pbmcgQ0EgKFNIQTIpMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp1P6D7K1E/Fkz4SA/K6ANdG218ej
# LKwaLKzxhKw6NRI6kpG6V+TEyfMvqEg8t9Zu3JciulF5Ya9DLw23m7RJMa5EWD6k
# oZanh08jfsNsZSSQVT6hyiN8xULpxHpiRZt93mN0y55jJfiEmpqtRU+ufR/IE8t1
# m8nh4Yr4CwyY9Mo+0EWqeh6lWJM2NL4rLisxWGa0MhCfnfBSoe/oPtN28kBa3Ppq
# PRtLrXawjFzuNrqD6jCoTN7xCypYQYiuAImrA9EWgiAiduteVDgSYuHScCTb7R9w
# 0mQJgC3itp3OH/K7IfNs29izGXuKUJ/v7DYKXJq3StMIoDl5/d2/PToJJQIDAQAB
# o4IDWDCCA1QwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwfwYIKwYBBQUHAQEEczBxMCQGCCsGAQUFBzABhhho
# dHRwOi8vb2NzcC5kaWdpY2VydC5jb20wSQYIKwYBBQUHMAKGPWh0dHA6Ly9jYWNl
# cnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEhpZ2hBc3N1cmFuY2VFVlJvb3RDQS5j
# cnQwgY8GA1UdHwSBhzCBhDBAoD6gPIY6aHR0cDovL2NybDMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0SGlnaEFzc3VyYW5jZUVWUm9vdENBLmNybDBAoD6gPIY6aHR0cDov
# L2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0SGlnaEFzc3VyYW5jZUVWUm9vdENB
# LmNybDCCAcQGA1UdIASCAbswggG3MIIBswYJYIZIAYb9bAMCMIIBpDA6BggrBgEF
# BQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5
# Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAg
# AHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0
# AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABE
# AGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABS
# AGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3
# AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBk
# ACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBu
# ACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjAdBgNVHQ4EFgQUj+h+8G0yagAF
# I8dwl2o6kP9r6tQwHwYDVR0jBBgwFoAUsT7DaQP4v0cB1JgmGggC72NkK8MwDQYJ
# KoZIhvcNAQELBQADggEBABkzSgyBMzfbrTbJ5Mk6u7UbLnqi4vRDQheev06hTeGx
# 2+mB3Z8B8uSI1en+Cf0hwexdgNLw1sFDwv53K9v515EzzmzVshk75i7WyZNPiECO
# zeH1fvEPxllWcujrakG9HNVG1XxJymY4FcG/4JFwd4fcyY0xyQwpojPtjeKHzYmN
# Pxv/1eAal4t82m37qMayOmZrewGzzdimNOwSAauVWKXEU1eoYObnAhKguSNkok27
# fIElZCG+z+5CGEOXu6U3Bq9N/yalTWFL7EZBuGXOuHmeCJYLgYyKO4/HmYyjKm6Y
# bV5hxpa3irlhLZO46w4EQ9f1/qbwYtSZaqXBwfBklIAwggbNMIIFtaADAgECAhAG
# /fkDlgOt6gAK6z8nu7obMA0GCSqGSIb3DQEBBQUAMGUxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# JDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0wNjExMTAw
# MDAwMDBaFw0yMTExMTAwMDAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMT
# GERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMTCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAOiCLZn5ysJClaWAc0Bw0p5WVFypxNJBBo/JM/xNRZFcgZ/tLJz4
# FlnfnrUkFcKYubR3SdyJxArar8tea+2tsHEx6886QAxGTZPsi3o2CAOrDDT+GEmC
# /sfHMUiAfB6iD5IOUMnGh+s2P9gww/+m9/uizW9zI/6sVgWQ8DIhFonGcIj5BZd9
# o8dD3QLoOz3tsUGj7T++25VIxO4es/K8DCuZ0MZdEkKB4YNugnM/JksUkK5ZZgrE
# jb7SzgaurYRvSISbT0C58Uzyr5j79s5AXVz2qPEvr+yJIvJrGGWxwXOt1/HYzx4K
# dFxCuGh+t9V3CidWfA9ipD8yFGCV/QcEogkCAwEAAaOCA3owggN2MA4GA1UdDwEB
# /wQEAwIBhjA7BgNVHSUENDAyBggrBgEFBQcDAQYIKwYBBQUHAwIGCCsGAQUFBwMD
# BggrBgEFBQcDBAYIKwYBBQUHAwgwggHSBgNVHSAEggHJMIIBxTCCAbQGCmCGSAGG
# /WwAAQQwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9z
# c2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4A
# eQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQA
# ZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUA
# IABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAA
# YQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcA
# cgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIA
# aQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQA
# ZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsG
# CWCGSAGG/WwDFTASBgNVHRMBAf8ECDAGAQH/AgEAMHkGCCsGAQUFBwEBBG0wazAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAC
# hjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURS
# b290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2Vy
# dC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8v
# Y3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMB0G
# A1UdDgQWBBQVABIrE5iymQftHt+ivlcNK2cCzTAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEARlA+ybcoJKc4HbZbKa9S
# z1LpMUerVlx71Q0LQbPv7HUfdDjyslxhopyVw1Dkgrkj0bo6hnKtOHisdV0XFzRy
# R4WUVtHruzaEd8wkpfMEGVWp5+Pnq2LN+4stkMLA0rWUvV5PsQXSDj0aqRRbpoYx
# YqioM+SbOafE9c4deHaUJXPkKqvPnHZL7V/CSxbkS3BMAIke/MV5vEwSV/5f4R68
# Al2o/vsHOE8Nxl2RuQ9nRc3Wg+3nkg2NsWmMT/tZ4CMP0qquAHzunEIOz5HXJ7cW
# 7g/DvXwKoO4sCFWFIrjrGBpN/CohrUkxg0eVd3HcsRtLSxwQnHcUwZ1PL1qVCCkQ
# JjGCBGgwggRkAgEBMIGAMGwxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xKzApBgNVBAMTIkRpZ2lD
# ZXJ0IEVWIENvZGUgU2lnbmluZyBDQSAoU0hBMikCEAxG27zqEjqBwVwGQJqb2Qgw
# CQYFKw4DAhoFAKCBqjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUCVHACeB48U1D
# n/Nhztr7yGcChQAwSgYKKwYBBAGCNwIBDDE8MDqgGoAYAEEAcABwAHMAQQBuAHkA
# dwBoAGUAcgBloRyAGmh0dHBzOi8vd3d3LnNvZnR3YXJlMi5jb20gMA0GCSqGSIb3
# DQEBAQUABIIBAFpWgHXucPBrmnNYIMzeljM5sIrk8vh0wOvn+YlxdFMZRZvBjMv6
# 6AZBjeY8VYXvaEVlL3xTMneKNu+RIM0WtCNDGo0Tcw9Z2h5Q3+e8LBC87Mq6NTwa
# 7aeQHwQc+Qobl7OyRhOoawoJpNQJkUkmHWmssSShpERdMzAeu+ISnBvElYYkhxiS
# fNfgobvVcR73TAUHODR1LBjYQN93F8hKHggsAGOqWHywazSs6MzKU+3kNPD7y7za
# pDfhoBr/rq0WCOZfKb1TRBTq4TeGrxu3NWBMdTUXZ4/1qBtuFswYOB6SVux/vgEJ
# zi928/xwDCsRee9BITSe1LRBQoC532+n+xqhggIPMIICCwYJKoZIhvcNAQkGMYIB
# /DCCAfgCAQEwdjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5j
# MRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBB
# c3N1cmVkIElEIENBLTECEAMBmgI6/1ixa9bV6uYX8GYwCQYFKw4DAhoFAKBdMBgG
# CSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE3MTIwODE0
# NDczM1owIwYJKoZIhvcNAQkEMRYEFEG/r+dvslVNfYltUXY1qL9e6Be+MA0GCSqG
# SIb3DQEBAQUABIIBAC579RfXDofqBRhSxy7H0Ji514/6Rtlk/NaMf/EjRg2ELcJu
# 5CZhAih7Ymo6k1HOQrQWbhip9VCoS0PqMxqG30T0L5PxVs5EchKej/WV4mVSowLZ
# ifAgQ/a2hKFCkCL4PhbQ4gAqzdE0Dv2Db4XCLAnuzM3DT+XNp+QJDTe+oVUsyUzj
# Z+Pi56pZysSKBnrI/CwfXpG34oJirnQ730sQxtCUPaNt55SRde00cv7qdpErMDaC
# 5xqBYumLHF84vXOiM1JvuSUx2SN4sobaKxBramDFXW0xrWodr+KEUjURlmDqelJi
# Mb6y25vOkm4udsp7et4bmSRIn4hfTab6sZNkXVY=
# SIG # End signature block
