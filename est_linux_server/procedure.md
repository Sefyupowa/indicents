# Enroll an ACME client

Follow these steps to install and configure `horizon-cli`, verify connectivity, and enroll a certificate.

## 1. Install `horizon-cli`

```bash
sudo admin.sh yum --enablerepo P_HOMEBREW_DIS install horizon-cli
```

## 2. Configure the production endpoint

```bash
/opt/horizon/bin/horizon-cli install --endpoint "https://protocol.clm-pp-pki.corp.intraxa"
```

Successful configuration should include output similar to:

```text
[INFO] Wrote config to /home/Lin_Ops/.horizon-cli/etc/horizon-cli.conf
[INFO] Successfully configured horizon-cli in /home/Lin_Ops/.horizon-cli
```

## 3. Verify connectivity

```bash
/opt/horizon/bin/horizon-cli ping --permissions
```

Expected output:

```text
[INFO] Ping successful, client not authenticated
```

## 4. Enroll the certificate

```bash
/opt/horizon/bin/horizon-cli automate enroll \
  --automation-policy=pp1-est-serverauth \
  --challenge="PUT_challenge_here" \
  --target generic \
  --destination-folder=XXXXX \
  --cert server.pem \
  --key server.key \
  --chain-file chain.pem \
  --no-interactive
```

On success, the output should confirm that the certificate was issued and installed, for example:

```text
# You are about to enroll a new certificate in order to replace a certificate bound to an application running on your machine
2026/11/25 18:35:26 [INFO]  1 tls services targeted
Searching for certificates in generic configuration 100% [========================================] (1/1)
2026/11/25 18:35:26 [INFO]  Generating new certificate for generic
2026/11/25 18:35:26 [INFO]  Found 1 certificates in 1 services
2026/11/25 18:35:26 [INFO]  Enrolling certificate CN=New Certificate, DNS=frlow01a205302.ppprivmgmt.intraxa (generic-945d5f5c-d361-4219-a49d-7b2dd8c0ecd4)
2026/11/25 18:35:26 [INFO]  Enrolling with EST
2026/11/25 18:35:26 [INFO]  Enrolling with authMode: challenge
2026/11/25 18:35:26 [INFO]  Certificate backup created
2026/11/25 18:35:44 [INFO]  New certificate has been enrolled (serial: 660003d9d920c392ab0a016dc800010003d9d9)
2026/11/25 18:35:44 [INFO]  CA chain has been retrieved
2026/11/25 18:35:44 [WARN]  Service generic required initialization, disabling --no-install option
2026/11/25 18:35:44 [INFO]  Installed certificate in '/tmp/test_ket2/server.pem'
2026/11/25 18:35:44 [INFO]  Installed secret in '/tmp/test_ket2/server.key'
2026/11/25 18:35:44 [INFO]  Installed chain in '/tmp/test_ket2/chain.pem'
2026/11/25 18:35:44 [INFO]  Reloading 0 service(s)
[lin_ops@frlow01a205302 ~]$

```

## Renew the certificate

```bash
/opt/horizon/bin/horizon-cli automate routine
```

This command checks whether the certificate is due for renewal and renews it if needed. Otherwise, it makes no changes.

Schedule this command to run daily so it can check whether the certificate needs renewal.
