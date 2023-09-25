{{/* vim: set filetype=mustache: */}}
{{/*
Define the full "release" (e.g. chart installation) name.
Must be 63 chars. maximum.
*/}}
{{- define "mirrorbits-parent.name" -}}
{{- $name := .Chart.Name -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
Must be 63 chars. maximum.
*/}}
{{- define "mirrorbits-parent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Define the common labels.
*/}}
{{- define "mirrorbits-parents.labels" -}}
app.kubernetes.io/name: {{ include "mirrorbits-parent.name" . }}
helm.sh/chart: {{ include "mirrorbits-parent.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Define the azure file persistent volume's secret name (if enabled).
Must be 63 chars. maximum.
*/}}
{{- define "mirrorbits-parent.pv-secretname" -}}
{{- printf "%s-%s" (include "mirrorbits-parent.name" . | trunc 43 ) "persistentvolume-secret" -}}
{{- end -}}
