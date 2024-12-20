{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "geoipupdate.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "geoipupdate.fullname" -}}
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
Selector labels
*/}}
{{- define "geoipupdate.selectorLabels" -}}
app.kubernetes.io/name: geoipupdate
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geoipupdate.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "geoipupdate.labels" -}}
{{ include "geoipupdate.selectorLabels" . }}
helm.sh/chart: {{ include "geoipupdate.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
rollout expand
*/}}
{{- define "geoipupdate.rollout" -}}
{{- if .Values.geoipupdate.rolloutrestart -}}
{{- if .Values.geoipupdate.rolloutrestart.enable -}}
{{- $result := "" -}}
{{- range .Values.geoipupdate.rolloutrestart.restarts -}}
{{- $namespace := .namespace -}}
{{- $deployments := .deployments | join "," -}}
{{- if $result -}}
{{- $result = printf "%s;%s:%s" $result $namespace $deployments -}}
{{- else -}}
{{- $result = printf "%s:%s" $namespace $deployments -}}
{{- end -}}
{{- end -}}
{{ $result }}
{{- end -}}
{{- end -}}
{{- end -}}
