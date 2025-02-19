Start-Transcript -Path C:\winrm_setup.log -Append

# Create a self-signed certificate
Write-Output "Creating self-signed certificate..."
$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$env:COMPUTERNAME"

# Remove existing listeners
Write-Output "Removing existing WinRM listeners..."
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse -ErrorAction SilentlyContinue

# Create HTTPS listener
Write-Output "Creating new WinRM HTTPS listener..."
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# Restart WinRM service
Write-Output "Restarting WinRM service..."
Set-Service -Name winrm -StartupType Automatic
Restart-Service winrm

# Remove HTTP listener if it exists
Write-Output "Removing HTTP listener..."
Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="http"} -ErrorAction SilentlyContinue

# Add firewall rule for WinRM
Write-Output "Adding firewall rule for WinRM..."
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

Write-Output "WinRM setup completed!"
Stop-Transcript
