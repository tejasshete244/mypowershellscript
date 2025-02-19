$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$env:COMPUTERNAME"

# Remove existing listeners
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse -ErrorAction SilentlyContinue

# Create HTTPS listener
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# Ensure WinRM is enabled and restarted
Set-Service -Name winrm -StartupType Automatic
Restart-Service winrm

# Remove existing HTTP listener (if needed)
Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="http"} -ErrorAction SilentlyContinue

# Allow WinRM HTTPS traffic in firewall
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

