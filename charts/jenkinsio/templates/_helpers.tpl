{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "jenkinsio.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "jenkinsio.fullname" -}}
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
{{- define "jenkinsio.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "jenkinsio.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jenkinsio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jenkinsio.labels" -}}
{{ include "jenkinsio.selectorLabels" . }}
helm.sh/chart: {{ include "jenkinsio.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
jenkins.io/maintainer: {{ (index .Chart.Maintainers 0).Name }}
{{- end -}}


{{/*
Selector labels
*/}}
{{- define "jenkinsio-zh.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jenkinsio.name" . }}-zh
app.kubernetes.io/instance: {{ .Release.Name }}-zh
{{- end }}

{{/*
Common labels
*/}}
{{- define "zh-jenkinsio.labels" -}}
{{ include "jenkinsio-zh.selectorLabels" . }}
helm.sh/chart: {{ include "jenkinsio.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}-zh
jenkins.io/maintainer: {{ (index .Chart.Maintainers 0).Name }}
{{- end -}}
