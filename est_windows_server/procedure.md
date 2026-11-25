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
  --challenge=PUT_OTP_HERE `
  --automation-policy=pp1-est-serverauth `
  --contact-email=PUT_The_Email_HERE `
  --target windows `
  --win-user-store `
  --team=PUT_The_SILVA_ID `
  --no-interactive
```

On success, the output should confirm that the certificate was issued and installed, for example:

```text
# You are about to enroll a new certificate in order to replace a certificate bound to an application running on your machine
2026/11/25 16:42:57 [INFO]  1 tls services targeted
Searching for certificates in windows configuration 100% [========================================] (1/1)
2026/11/25 16:42:57 [INFO]  Found config folder: Cert:LocalMachine\My
2026/11/25 16:42:57 [INFO]  Generating new certificate for windows
2026/11/25 16:42:57 [INFO]  Found 1 certificates in 1 services
2026/11/25 16:42:58 [INFO]  Enrolling certificate CN=New Certificate, DNS=frclw01a0788.PPPRIVMGMT.intraxa (windows)
2026/11/25 16:42:58 [INFO]  Enrolling with EST
2026/11/25 16:42:58 [INFO]  Enrolling with authMode: challenge
2026/11/25 16:42:58 [INFO]  Certificate backup created
2026/11/25 16:42:59 [INFO]  New certificate has been enrolled (serial: 660003d9d8f0df0e828f3fdac000010003d9d8)
2026/11/25 16:42:59 [INFO]  CA chain has been retrieved
2026/11/25 16:42:59 [INFO]  Installed certificate in 'Cert:LocalMachine\My\ab3ee84f17005c7e3498ad49b004046d450d231d'
2026/11/25 16:42:59 [INFO]  Reloading 0 service(s)
PS C:\Users\ZZAGOD035512WINSUP01>
```

## Check the certificate
Take the has found in the output

```text
2026/11/25 16:32:01 [INFO]  Installed certificate in 'Cert:LocalMachine\My\ab3ee84f17005c7e3498ad49b004046d450d231d'
```

and check the certificate.

```powershell
certutil.exe -v -store My ab3ee84f17005c7e3498ad49b004046d450d231d
```

## Renew the certificate

```powershell
horizon-cli automate routine
```

This command checks whether the certificate is due for renewal and renews it if needed. Otherwise, it makes no changes.

Schedule this command to run daily so it can check whether the certificate needs renewal.
