$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "$env:COMPUTERNAME"

Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

Stop-Service winrm

Start-Service winrm

Remove-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="http"}
New-WSManInstance winrm/config/Listener -SelectorSet @{Address="*";Transport="http"}
