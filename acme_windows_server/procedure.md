# Enroll an ACME client

Follow these steps to install and configure `horizon-cli`, verify connectivity, and enroll a certificate.

## 1. Install `horizon-cli`

```powershell
choco install horizon-cli -y
```

## 2. Configure the production endpoint

```powershell
horizon-cli install --endpoint "https://protocol.clm-pp-pki.corp.intraxa"
```

Successful configuration should include output similar to:

```text
[INFO] Wrote config to /home/Lin_Ops/.horizon-cli/etc/horizon-cli.conf
[INFO] Successfully configured horizon-cli in /home/Lin_Ops/.horizon-cli
```

## 3. Verify connectivity

```powershell
horizon-cli ping --permissions
```

Expected output:

```text
[INFO] Ping successful, client not authenticated
```

## 4. Enroll the certificate

```bash
horizon-cli automate enroll `
  --automation-policy=pp1-acme-serverauth `
  --owner=PUT_The_Email_HERE `
  --acme-account="$($env:COMPUTERNAME)@axa.com" `
  --contact-email=PUT_The_Email_HERE `
  --target windows `
  --win-user-store `
  --team=PUT_The_SILVA_ID `
  --dnsnames "$([System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName)" `
  --no-interactive
```

On success, the output should confirm that the certificate was issued and installed, for example:

```text
# You are about to enroll a new certificate in order to replace a certificate bound to an application running on your machine
2026/11/25 16:31:39 [INFO]  1 tls services targeted
Searching for certificates in windows configuration 100% [========================================] (1/1)
2026/11/25 16:31:39 [INFO]  Found config folder: Cert:LocalMachine\My
2026/11/25 16:31:39 [INFO]  Generating new certificate for windows
2026/11/25 16:31:39 [INFO]  Found 1 certificates in 1 services
2026/11/25 16:31:40 [INFO]  Enrolling certificate CN=New Certificate, DNS=frclw01a0788.PPPRIVMGMT.intraxa (windows)
2026/11/25 16:31:40 [INFO]  Enrolling with ACME
2026/11/25 16:31:40 [INFO]  Certificate backup created
2026/11/25 16:31:40 [WARN]  could not load user: account FRCLW01A0788@axa.com was not found on this machine. Creating new user.
2026/11/25 16:31:40 [INFO]  acme: Registering account for FRCLW01A0788@axa.com
2026/11/25 16:31:40 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] acme: Obtaining SAN certificate
2026/11/25 16:31:40 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] AuthURL: https://protocol.clm-pp-pki.corp.intraxa/acme/authz/pp1-acme-serverauth~bWV0YWRhdGEuYXV0b21hdGlvbl9wb2xpY3k6cHAxLWFjbWUtc2VydmVyYXV0aCxtYWlsOmJhZHIub3VhcmFmYW5hQGF4YS5jb20sb3duZXI6YmFkci5vdWFyYWZhbmFAYXhhLmNvbSx0ZWFtOnNpbHZhXzg0NzU2ODIwZGJlNTg3ODAyZjU1NWM4OGRjOTYxOTFi/6b06ff5c0d439c3cd3e7a5d9
2026/11/25 16:31:40 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] acme: use http-01 solver
2026/11/25 16:31:40 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] acme: Trying to solve HTTP-01
2026/11/25 16:31:41 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] Served key authentication
2026/11/25 16:31:44 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] The server validated our request
2026/11/25 16:31:44 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] acme: Validations succeeded; requesting certificates
2026/11/25 16:32:01 [INFO]  [frclw01a0788.PPPRIVMGMT.intraxa] Server responded with a certificate.
2026/11/25 16:32:01 [INFO]  Installed certificate in 'Cert:LocalMachine\My\f2c49121f59c14d791cfd1f7789397378b6105bc'
2026/11/25 16:32:01 [INFO]  Reloading 0 service(s)
PS C:\Users\ZZAGOD035512WINSUP01>
```

## Check the certificate
Take the has found in the output

```text
2026/11/25 16:32:01 [INFO]  Installed certificate in 'Cert:LocalMachine\My\f2c49121f59c14d791cfd1f7789397378b6105bc'
```

and check the certificate.

```powershell
certutil.exe -v -store My f2c49121f59c14d791cfd1f7789397378b6105bc
```

## Renew the certificate

```powershell
horizon-cli automate routine
```

This command checks whether the certificate is due for renewal and renews it if needed. Otherwise, it makes no changes.

Schedule this command to run daily so it can check whether the certificate needs renewal.
