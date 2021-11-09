# Jenkins Infrastructure ACME settings

This chart is configured to use the dns challenge.

It allows multiple dns01 configurations to be passed,
with `acme.dns01` accepting any valid settings
as defined in <https://cert-manager.io/docs/configuration/acme/dns01/>.

Example configuration:

```yaml
acme:
  id: "letsencrypt-prod" # Used by ingress resources to identify the issuer
  email: "test@example.com"
  server: "https://acme-v02.api.letsencrypt.org/directory" # Used to query letsencrypt servers
  clientSecrets:
  - name: acme_secret_jenkins_io
    value: 'password'
  - name: acme_secret_jenkinsci_org
    value: 'password2'
  dns01:
  - azuredns:
      clientID: XXX
      clientSecretSecretRef:
        name: acme_secret_jenkinsio
        key: CLIENT_SECRET
      subscriptionID: YYY
      tenantID: ZZZ
      resourceGroupName: jenkinsio
      hostedZoneName: jenkins.io
      selector:
        dnsZones:
          - jenkins.io
  - azuredns:
      clientID: XXX
      clientSecretSecretRef:
        name: acme_secret_jenkinsci_org
        key: CLIENT_SECRET
      subscriptionID: YYY
      tenantID: ZZZ
      resourceGroupName: jenkinsci_org
      hostedZoneName: jenkinsci.org
      selector:
        dnsZones:
          - jenkins-ci.org
```

## Links

* <https://docs.cert-manager.io/en/latest/tasks/acme/configuring-dns01/azuredns.html>
* <https://cert-manager.io/docs/configuration/acme/>
