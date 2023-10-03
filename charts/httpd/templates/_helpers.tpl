{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "httpd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "httpd.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "httpd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "httpd.labels" -}}
app.kubernetes.io/name: {{ include "httpd.name" . }}
helm.sh/chart: {{ include "httpd.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Data directory volume definition. Might be defined from parent chart templates or autonomously
based on the presence of the global value provided by the parent chart.
*/}}
{{- define "httpd.html-volume" -}}
{{- if (dig "global" "storage" "enabled" false .Values.AsMap) -}}
persistentVolumeClaim:
  claimName: {{ include "mirrorbits-parent.pvc-name" . }}
{{- else }}
  {{- if or .Values.repository.persistentVolumeClaim.enabled .Values.repository.reuseExistingPersistentVolumeClaim }}
persistentVolumeClaim:
  claimName: {{ .Values.repository.name | default (printf "%s-binary" (include "httpd.fullname" .)) }}
  {{- else }}
emptyDir: {}
  {{- end -}}
{{- end -}}
{{- end -}}
