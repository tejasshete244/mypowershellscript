Start-Transcript -Path C:\winrm_setup.log -Append

Write-Output "Creating self-signed certificate..."
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$env:COMPUTERNAME"

# Ensure WinRM service is enabled and started
Write-Output "Ensuring WinRM service is running..."
Set-Service -Name winrm -StartupType Automatic
Start-Service -Name winrm

# Wait for WinRM to be fully available
$counter = 0
while (-not (Get-Service winrm).Status -eq "Running" -and $counter -lt 10) {
    Write-Output "Waiting for WinRM to start... ($counter/10)"
    Start-Sleep -Seconds 2
    $counter++
}

# Check if WinRM listeners exist before trying to remove them
Write-Output "Checking for existing WinRM listeners..."
$existingListeners = Get-ChildItem -Path WSMan:\Localhost\Listener -ErrorAction SilentlyContinue

if ($existingListeners) {
    Write-Output "Removing existing WinRM listeners..."
    Remove-Item -Path WSMan:\Localhost\Listener\listener* -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Output "No existing WinRM listeners found. Skipping removal."
}

# Create HTTPS listener only if WinRM is running
if ((Get-Service winrm).Status -eq "Running") {
    Write-Output "Creating new WinRM HTTPS listener..."
    New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force
} else {
    Write-Output "ERROR: WinRM is not running. Cannot create a listener."
    Stop-Transcript
    exit 1
}

# Restart WinRM service to apply changes
Write-Output "Restarting WinRM service..."
Restart-Service winrm

# Remove HTTP listener if it exists
Write-Output "Removing HTTP listener..."
try {
    Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="http"} -ErrorAction Stop
    Write-Output "HTTP listener removed."
} catch {
    Write-Output "No HTTP listener found or error occurred: $_"
}

# Add firewall rule for WinRM
Write-Output "Adding firewall rule for WinRM..."
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

Write-Output "WinRM setup completed!"
Stop-Transcript
