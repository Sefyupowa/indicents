# Troubleshooting (Simple)

## PowerShell

```powershell
$HostName = "your-hostname"
$Port = 443
$CertFile = "/path/to/certificate.crt"
$KeyFile = "/path/to/private/key.key"

$crlf = [Environment]::NewLine
$req = "GET / HTTP/1.1$crlf" +
       "Host: $HostName$crlf" +
       "Connection: close$crlf$crlf"

$opensslArgs = @(
  "s_client",
  "-brief",
  "-connect", "$HostName`:$Port",
  "-servername", "$HostName",
  "-cert", "$CertFile",
  "-key", "$KeyFile"
)

$req | & openssl @opensslArgs
```

## Git Bash

```bash
HOST="your-hostname"
PORT="443"
CERT_FILE="/path/to/certificate.crt"
KEY_FILE="/path/to/private/key.key"

printf "GET / HTTP/1.1\r\nHost: ${HOST}\r\nConnection: close\r\n\r\n" | \
openssl s_client \
  -brief \
  -connect "${HOST}:${PORT}" \
  -servername "${HOST}" \
  -cert "${CERT_FILE}" \
  -key "${KEY_FILE}"
```
