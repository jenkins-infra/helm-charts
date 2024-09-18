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
Ensure coherent name of the repository data PV/PVC objects
*/}}
{{- define "mirrorbits.data-name" -}}
{{ .Values.repository.name }}
{{- end -}}

{{/*
Ensure coherent name of the geoipdata PV/PVC objects
*/}}
{{- define "mirrorbits.geoipdata-name" -}}
{{ .Values.geoipdata.existingPVCName | default (printf "%s-%s" (include "mirrorbits.fullname" .) "geoipdata") }}
{{- end -}}

{{/*
Ensure coherent name of the mirrorbits configuration object (so deployment has the correct key)
*/}}
{{- define "mirrorbits.config-secretname" -}}
  {{ include "mirrorbits.fullname" . }}-config
{{- end -}}

{{/*
Template of the mirrorbits configuration file
*/}}
{{- define "mirrorbits.configmap" -}}
###################
##### GENERAL #####
###################
## Path to the local repository
Repository: {{ .Values.config.repository }}
## Path to the templates (default autodetect)
Templates: {{ .Values.config.templates }}
## Path to the GeoIP2 mmdb databases
GeoipDatabasePath: {{ .Values.config.geoipDatabase }}
## Enable Gzip compression
Gzip: {{ .Values.config.gzip }}
## Host an port to listen on
ListenAddress: :{{ .Values.config.port }}
  {{- if and .Values.config.logs .Values.config.logs.path }}
## Path where to store logs
LogDir: {{ .Values.config.logs.path }}
  {{- end }}

  {{- if .Values.cli.enabled }}
## Host and port to listen for the CLI RPC
RPCListenAddress: 0.0.0.0:{{ .Values.cli.port }}

    {{- with .Values.cli.password }}
## Password for restricting access to the CLI (optional)
RPCPassword: {{ . | quote }}
    {{- end }}
  {{- end }}
## OutputMode can take on the three values:
##  - redirect: HTTP redirect to the destination file on the selected mirror
##  - json: return a json document for pre-treatment by an application
##  - auto: based on the Accept HTTP header
OutputMode: {{ .Values.config.outputMode | default "auto" }}
  {{- with .Values.config.redis }}
####################
##### DATABASE #####
####################
## Redis host and port
RedisAddress: {{ .address }}
## Redis password (if any)
RedisPassword: {{ .password }}
## Redis database ID (if any)
RedisDB: {{ .dbId }}
  {{- end }}

###################
##### MIRRORS #####
###################
## Relative path to the trace file within the repository (optional).
## The file must contain the number of seconds since epoch and should
## be updated every minute (or so) with a cron on the master repository.
TraceFileLocation: {{ .Values.config.traceFile }}
## Interval between two scans of the local repository.
## The repository scan will index new and removed files and collect file
## sizes and checksums.
## This should, more or less, match the frequency where the local repo
## is updated.
RepositoryScanInterval: {{ .Values.config.repositoryScanInterval }}
## Enable or disable specific hashing algorithms
Hashes:
  SHA256: On
  SHA1: On
  MD5: On
## Maximum number of concurrent mirror synchronization to do (rsync/ftp)
ConcurrentSync: {{ .Values.config.concurentSync }}
## Interval in minutes between mirror scan
ScanInterval: {{ .Values.config.scanInterval }}
## Interval in minutes between mirrors HTTP health checks
CheckInterval: {{ .Values.config.checkInterval }}
## Allow a mirror to issue an HTTP redirect.
## Setting this to true will disable the mirror if a redirect is detected.
DisallowRedirects: {{ .Values.config.disallowRedirects }}
## Disable a mirror if an active file is missing (HTTP 404)
DisableOnMissingFile: {{ .Values.config.disableOnMissingFile }}
  {{- with .Values.config.fallbacks }}
## List of mirrors to use as fallback which will be used in case mirrorbits
## is unable to answer a request because the database is unreachable.
## Note: Mirrorbits will redirect to one of these mirrors based on the user
## location but won't be able to know if the mirror has the requested file.
## Therefore only put your most reliable and up-to-date mirrors here.
Fallbacks:
    {{- range . }}
  - URL: {{ .url }}
    CountryCode: {{ .countryCode }}
    ContinentCode: {{ .continentCode }}
    {{- end }}
  {{- end }}
{{- end }}
