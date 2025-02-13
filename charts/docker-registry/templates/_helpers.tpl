{{/*
Expand the name of the chart.
*/}}
{{- define "docker-registry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "docker-registry.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "docker-registry.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "docker-registry.labels" -}}
helm.sh/chart: {{ include "docker-registry.chart" . }}
{{ include "docker-registry.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "docker-registry.selectorLabels" -}}
app.kubernetes.io/name: {{ include "docker-registry.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*

*/}}
{{- define "docker-registry.dataVolumeName" -}}
{{- end }}

{{/*

*/}}
{{- define "docker-registry.dataVolumeMountPath" -}}
/var/lib/registry
{{- end }}

{{/*
Registry configuration through environment variables
*/}}
{{- define "docker-registry.envs" -}}
- name: REGISTRY_HTTP_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ template "docker-registry.fullname" . }}-secret
      key: haSharedSecret
- name: REGISTRY_HTTP_ADDR
  value: "0.0.0.0:{{ .Values.port }}"

{{- if .Values.tlsSecretName }}
- name: REGISTRY_HTTP_TLS_CERTIFICATE
  value: /etc/ssl/docker/tls.crt
- name: REGISTRY_HTTP_TLS_KEY
  value: /etc/ssl/docker/tls.key
{{- end -}}

# Proxy mode (eg. registry mirror) requires a filesystem (as file or object storage do not provide expected consistency required by proxy mode)
- name: REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY
  value: "{{ include "docker-registry.dataVolumeMountPath" . }}"

{{- if .Values.proxy.enabled }}
- name: REGISTRY_PROXY_REMOTEURL
  value: {{ required ".Values.proxy.remoteurl is required" .Values.proxy.remoteurl }}
- name: REGISTRY_PROXY_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ template "docker-registry.fullname" . }}-secret
      key: proxyUsername
- name: REGISTRY_PROXY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "docker-registry.fullname" . }}-secret
      key: proxyPassword
{{- end -}}

{{- if .Values.persistence.deleteEnabled }}
- name: REGISTRY_STORAGE_DELETE_ENABLED
  value: "true"
{{- end -}}

{{- with .Values.extraEnvVars }}
{{ toYaml . }}
{{- end -}}

{{- end -}}
