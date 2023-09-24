# Mirrorbits Parent (All-in-one Mirrorbits shaped for the Jenkins project)

This chart allows to deploys up to three services:

* [mirrorbits](https://github.com/etix/mirrorbits) through the subchart <https://github.com/jenkins-infra/helm-charts/tree/main/charts/mirrorbits-lite>
* [httpd (Apache2)](https://httpd.apache.org/) through the subchart <https://github.com/jenkins-infra/helm-charts/tree/main/charts/httpd>
* [rsyncd](https://linux.die.net/man/1/rsync) through the subchart <https://github.com/jenkins-infra/helm-charts/tree/main/charts/rsyncd>

The goal is to deploy an "HTTP redirector" service centered on [mirrorbits](https://github.com/etix/mirrorbits) and/or a Jenkins download mirror.

## Requirements

This chart has the same requirements as any of the 3 subcharts.

## Settings (Values)

Look at the [`values.yaml` source file](./values.yaml) to get the possible configuration values.

### Ingress

If you need to provide an ingress to route request to a mix of the sub services, then you can specify the ingress configuration through this parent chart (instead of the subcharts).

Example to define a nginx ingress on the domain `downloads.company.org` with TLS enabled (managed by Let's Encrypt),
where all URLs ending with a `zip` or `gz` string are redirected to the mirrorbits backend,
and the other requests to the httpd backend:

```yaml
ingress:
  enabled: true
  annotations:
    "cert-manager.io/cluster-issuer": "letsencrypt-prod"
    "nginx.ingress.kubernetes.io/ssl-redirect": "true"
    "nginx.ingress.kubernetes.io/use-regex": "true"
  hosts:
    - host: downloads.company.org
      paths:
        - path: /
          backendService: httpd
        - path: /.*[.](zip|gz)$
          backendService: mirrorbits
  tls:
    - secretName: ingress-certificates
      hosts:
        - downloads.company.org

mirrorbits-lite:
  enabled: true

httpd:
  enabled: true
```

### Storage

This chart is usually deployed with the same persistent storage for all sub-services.
As such you can manage a common persistent volume (and associated claims) once and for all instead of delegating to the sub-charts.

Since the chart was initially designed to run on AKS with an Azurefile volume, part of the PV/PVC configuration can be managed (CSI setup, Azurefile secret for the access key) through the `storage.persistentVolume.azureFile` value.

Example with an Azure file PV and associated PVC mounted in read only:

```yaml
mirrorbits-lite:
  enabled: true
  repository:
    name: <name of the PVC>
    reuseExistingPersistentVolumeClaim: true

httpd:
  enabled: true
  repository:
    name: <name of the PVC>
    reuseExistingPersistentVolumeClaim: true

storage:
  enabled: true
  storageClassName: azurefile-csi-premium
  storageSize: 100Gi
  accessModes:
    - ReadOnlyMany
  persistentVolume:
    azureFile:
      ## Encrypt these values using helm-secrets/sops or whatever
      storageAccountName: storage-account-name
      storageAccountKey: StorageAccountSuperSecretKey
      ## End of encrypted values
      resourceGroup: storage-rg
      shareName: storage-share-name
      readOnly: true
    additionalSpec:
      persistentVolumeReclaimPolicy: Retain
      mountOptions:
        - dir_mode=0555
        - file_mode=0444
        - uid=1000
        - gid=1000
        - mfsymlinks
        - nobrl
        - serverino
        - cache=strict
```
