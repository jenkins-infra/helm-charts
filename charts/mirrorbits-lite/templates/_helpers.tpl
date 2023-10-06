{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mirrorbits-lite.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mirrorbits-lite.fullname" -}}
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
{{- define "mirrorbits-lite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mirrorbits-lite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mirrorbits-lite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mirrorbits-lite.labels" -}}
{{ include "mirrorbits-lite.selectorLabels" . }}
helm.sh/chart: {{ include "mirrorbits-lite.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Data directory volume definition. Might be defined from parent chart templates or autonomously
based on the presence of the global value provided by the parent chart.
*/}}
{{- define "mirrorbits-lite.data-volume" -}}
{{- if and (dig "global" "storage" "enabled" false .Values.AsMap) .Values.global.storage.claimNameTpl -}}
persistentVolumeClaim:
  claimName: {{ printf "%s" (tpl .Values.global.storage.claimNameTpl $) | trim | trunc 63 }}
{{- else -}}
  {{- if .Values.repository.persistentVolumeClaim.enabled -}}
persistentVolumeClaim:
  claimName: {{ .Values.repository.name | default (printf "%s-binary" (include "mirrorbits-lite.fullname" .)) }}
  {{- else -}}
emptyDir: {}
  {{- end -}}
{{- end -}}
{{- end -}}
