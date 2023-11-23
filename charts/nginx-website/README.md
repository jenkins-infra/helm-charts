# nginx-website

This chart can be used to deploy a website served by nginx.

## Running this yourself

This guide assumes you're running minikube, adjust accordingly if you're using something else to run it.

First you need to retrieve the content of your website to be able to mount it as volume:

```bash
minikube mount site:/host
```

```yaml
helm install -f values.yaml -f values.local.yaml --name nginx-website .
```

```yaml
helm upgrade  -f values.yaml -f values.local.yaml  nginx-website .
```

You need to define some configuration locally in a separate values file

Here's an example `values.local.yaml` file:
```yaml
ingress:
  enabled: true
  hosts:
    - host: nginx-website-local.jenkins.io
      paths:
        - path: /
          pathType: Prefix
          service:
            name: nginx-website-local
            port: http

htmlVolume:
  hostPath:
    path: /host
```

You'll need to add `nginx-website-local.jenkins.io` to your hosts file, you can get the IP with `kubectl get ingress`

## Running on Azure

Here's some example configuration for running this on Azure:

```yaml
azureStorageAccountName: myaccount
azureStorageAccountKey: key
htmlVolume:
  azureFile: 
    secretName: reports
    shareName: reports
    readOnly: true
# ... you will also need ingress configuration, add as required
```
