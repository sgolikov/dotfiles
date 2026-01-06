if (Get-Command git.exe -ErrorAction SilentlyContinue) {
    exit 0
}

winget install Git.Git --silent --accept-package-agreements