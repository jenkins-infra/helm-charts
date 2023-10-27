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

{{/*
Define the azure file persistent volume claim name (if enabled).
Must be 63 chars. maximum.
*/}}
{{- define "mirrorbits-parent.pvc-name" -}}
{{- printf "%s-%s" .Release.Name "mirrorbits-parent-data" -}}
{{- end -}}

{{/*
This template method checks the current ingress path and fails with a user facing message if needed, or returns empty.
Expected argument: dict{
  "currentBackendService": <string>,
  "rootContext": { },
}
 */}}
{{- define "mirrorbits-parent.validateIngressBackend" -}}
{{- if eq .currentBackendService "mirrorbits" -}}
  {{- if not (index .rootContext.Values "mirrorbits-lite" "enabled") -}}
    {{- fail "Cannot use mirrorbits-lite as backend if it is disabled." }}
  {{- end -}}
  {{- if not (index .rootContext.Values "mirrorbits-lite" "backendServiceNameTpl") -}}
    {{- fail "Cannot determine mirrorbits backend service due to missing value 'mirrorbits-lite.currentBackendServiceNameTpl." }}
  {{- end -}}
{{- else if eq .currentBackendService "httpd" -}}
  {{- if not (index .rootContext.Values "httpd" "enabled") -}}
    {{- fail "Cannot use httpd as backend if it is disabled." }}
  {{- end -}}
  {{- if not (index .rootContext.Values "httpd" "backendServiceNameTpl") -}}
    {{- fail "Cannot determine httpd backend service due to missing value 'httpd.currentBackendServiceNameTpl." }}
  {{- end -}}
{{- else -}}
  {{- fail "Required key: backendService for ingress.hosts[].paths[] objects must have the value 'httpd' or 'mirrorbits'." }}
{{- end -}}
{{- end -}}

{{/*
This template method returns the name of the current path backend service. It includes validation and checks of the context.
Expected argument: dict{
  "currentBackendService": <string>,
  "rootContext": { },
}
 */}}
{{- define "mirrorbits-parent.ingressBackendName" -}}
{{- include "mirrorbits-parent.validateIngressBackend" . }}
{{- if eq .currentBackendService "mirrorbits" -}}
  {{ printf "%s" (tpl (index .rootContext.Values "mirrorbits-lite" "backendServiceNameTpl") .rootContext) | trim | trunc 63 }}
{{- else if eq .currentBackendService "httpd" -}}
  {{ printf "%s" (tpl (index .rootContext.Values "httpd" "backendServiceNameTpl") .rootContext) | trim | trunc 63 }}
{{- end -}}
{{- end -}}

{{/*
This template method returns the name of the current path backend service. It includes validation and checks of the context.
Expected argument: dict{
  "currentBackendService": <string>,
  "rootContext": { },
}
 */}}
{{- define "mirrorbits-parent.ingressBackendPort" -}}
{{- include "mirrorbits-parent.validateIngressBackend" . }}
{{- if eq .currentBackendService "mirrorbits" -}}
  {{ index .rootContext.Values "mirrorbits-lite" "service" "port" }}
{{- else if eq .currentBackendService "httpd" -}}
  {{ index .rootContext.Values "httpd" "service" "port" }}
{{- end -}}
{{- end -}}


{{- define "jenkins.serviceAccountName" -}}
  {{- if .Values.serviceaccount.existingServiceAccount -}}
    {{- splitList ":" .Values.serviceaccount.existingServiceAccount | last -}}
  {{- else -}}
    {{- "mirrorbits" -}}
  {{- end -}}
{{- end -}}

{{- define "jenkins.serviceAccountNamespace" -}}
  {{- if .Values.serviceaccount.existingServiceAccount -}}
    {{- splitList ":" .Values.serviceaccount.existingServiceAccount | first -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}
