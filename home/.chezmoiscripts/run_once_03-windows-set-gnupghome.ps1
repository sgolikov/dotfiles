$target = "$env:USERPROFILE\.gnupg"

[Environment]::SetEnvironmentVariable("GNUPGHOME", $target, "User")
[Environment]::SetEnvironmentVariable("GNUPGHOME", $target, "Process")

Write-Host "GNUPGHOME set to $target (User + Process). Restart terminals/IDE to fully take effect."
