# Troubleshooting (Simple)

## PowerShell

```powershell
$Url = "https://your-hostname"
$P12File = "/path/to/certificate.p12"
$P12Password = "your-password"

curl.exe -v --cert-type P12 --cert "${P12File}:${P12Password}" "$Url" -k
```

## Git Bash

```bash
export MSYS_NO_PATHCONV=1
curlPath="/path/to/curl/bin"   # Optional: set this path if you need a specific curl binary.
export PATH="$curlPath:$PATH"  # Comment this line if curl in PATH is already correct.

URL="https://celia-pp.corp.intraxa"
P12_FILE="/path/to/certificate.p12"
P12_PASSWORD="your-password"



curl -v --cert-type P12 --cert "${P12_FILE}:${P12_PASSWORD}" "${URL}" -k
```

