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
  --automation-policy=pp1-acme-serverauth \
  --owner=PUT_The_Email_HERE \
  --acme-account="$(hostname)@axa.com" \
  --contact-email=PUT_The_Email_HERE \
  --target generic \
  --team=PUT_The_SILVA_ID \
  --dnsnames "$(hostname -f)" \
  --destination-folder=XXXXX \
  --cert server.pem \
  --key server.key \
  --chain-file chain.pem \
  --no-interactive
```

On success, the output should confirm that the certificate was issued and installed, for example:

```text
[INFO] Enrolling with ACME
[INFO] Certificate backup created
[INFO] Server responded with a certificate.
[INFO] Installed certificate in '/tmp/server.pem'
[INFO] Installed secret in '/tmp/server.key'
[INFO] Installed chain in '/tmp/chain.pem'
```

## Renew the certificate

```bash
/opt/horizon/bin/horizon-cli automate routine
```

This command checks whether the certificate is due for renewal and renews it if needed. Otherwise, it makes no changes.

Schedule this command to run daily so it can check whether the certificate needs renewal.
