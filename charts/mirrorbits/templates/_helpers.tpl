{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mirrorbits.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mirrorbits.fullname" -}}
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
{{- define "mirrorbits.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mirrorbits.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mirrorbits.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "mirrorbits.labels" -}}
{{ include "mirrorbits.selectorLabels" . }}
helm.sh/chart: {{ include "mirrorbits.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mirrorbits.files.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mirrorbits.name" . }}-files
app.kubernetes.io/instance: {{ .Release.Name }}-files
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mirrorbits.rsyncd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mirrorbits.name" . }}-rsyncd
app.kubernetes.io/instance: {{ .Release.Name }}-rsyncd
{{- end }}
