# plugin-site-issues

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

plugin-site-issues

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| artifactory.key | string | `""` | key to upload to artifactory |
| fullnameOverride | string | `""` |  |
| github.token | string | `""` | token to update github checks and look up commits |
| image.repository | string | `"jenkinsciinfra/plugin-site-issues"` |  |
| image.tag | string | `"latest"` |  |
| imagePullSecrets | list | `[]` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"chart-example.local"` |  |
| ingress.tls | list | `[]` |  |
| jenkins.auth | string | `""` | username:accesskey to  talk to jenkins apis to pull build metadata |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| preshared_key | string | `""` | The token needed to be provided for autherization |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext | object | `{}` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| tolerations | list | `[]` |  |
