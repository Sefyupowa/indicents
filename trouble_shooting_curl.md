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
curlPath="/path/to/curl/bin"  # use the path where you download curl, you will find curl in bin folder.
export PATH="$curlPath:$PATH"  

###################
# this three commands to put only once at the beginning when you open the terminal
###################

URL="https://celia-pp.corp.intraxa"
P12_FILE="/path/to/certificate.p12"
P12_PASSWORD="your-password"



curl -v --cert-type P12 --cert "${P12_FILE}:${P12_PASSWORD}" "${URL}" -k
```

