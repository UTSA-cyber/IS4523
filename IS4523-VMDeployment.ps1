# Title:        Deployment Script for IS-4523 (Digital Forensics II)
# Author:       Jacob Stauffer, CISSP
# Description:  Deployment script with all required software for DFII
# Last Update:  2020-01-20
#
# Usage:        . { Invoke-WebRequest -useb THISRAWSCRIPT } | Invoke-Expression
#

param (
    [string]$name = "IS4523",
    [string]$legalnoticetext = "This virtual machine is strictly for education and training purposes. No personal or commercial use is authorized.",
    [string]$zimmermantools = "https://f001.backblazeb2.com/file/EricZimmermanTools/Get-ZimmermanTools.zip"
)

function Install-Software() {
    try {
        # Installing Firefox browser
        choco install Firefox -y

        # Installing JumpListsView
        choco install jumplistsview -y

        # Installing ShadowExplorer
        choco install shadowexplorer -y

        # Installing ShadowCopyView
        choco install shadowcopyview -y

        # Installing Zimmerman Tools
        mkdir "C:\$name\Tools\ZimmermanTools"
        Invoke-WebRequest $zimmermantools -OutFile C:\Windows\Temp\ztools.zip
        Expand-Archive C:\Windows\Temp\ztools.zip -DestinationPath "C:\$name\Tools\"
        Set-Location C:\$name\Tools
        .\Get-ZimmermanTools.ps1 -Dest "C:\$name\Tools\ZimmermanTools"
        rm Get-ZimmermanTools.ps1

        # Clean up
        Remove-Item "$env:PUBLIC\Desktop\ShadowCopyView.lnk"
        Remove-Item "$env:USERPROFILE\Desktop\ShadowCopyView.lnk"
        Remove-Item "$env:USERPROFILE\Desktop\ShadowExplorer.lnk"
        Remove-Item "$env:USERPROFILE\Desktop\Microsoft Edge.lnk"
    } catch {
        Write-Host "[-] Cannot install software" -ForegroundColor Red
    }
}

function Set-Banner() {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Value "UTSA $name"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Value $legalnoticetext
}

# Set environment to run this script
Set-ExecutionPolicy Unrestricted
Disable-UAC

# Check to make sure script is run as administrator
Write-Host "[+] Checking if script is running as administrator.." -ForegroundColor Green
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
if (-Not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[-] Please run this script as administrator`n" -ForegroundColor Red
    Read-Host  "Press any key to continue"
    exit
}

Write-Host "[+] Installing $name software" -ForegroundColor Green
$rc = Install-Software
if ( -Not $rc ) {
    Write-Host "[-] Failed to install software" -ForegroundColor Red
}

Set-Banner