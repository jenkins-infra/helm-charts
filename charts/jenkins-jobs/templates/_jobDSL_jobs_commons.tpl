{{/* vim: set filetype=mustache: */}}
{{/*
Generate the job-dsl configuration from specified values
*/}}
{{- define "jobs-dsl-config" }}
  {{- $root := . }}
  {{- range $jobId, $jobDef := .Values.jobsDefinition }}
- script: >
    {{- include "generic-job-dsl-definition" (merge $jobDef (dict "id" $jobId "root" $root)) | indent 4 }}
    {{- range $childId, $childDef := $jobDef.children }}
      {{- /*  Jenkins + Job DSL allow to define job children by concatenating their id with the parent id, separated by a / */}}
      {{- $childFullId := printf "%s/%s" $jobId $childId }}
      {{- $parentGithubCredential := $jobDef.childrenGithubCredential }}
      {{- $child := (dict "id" $childId "fullId" $childFullId "root" $root "parentGithubCredential" $parentGithubCredential) }}
      {{- if $childDef }}
        {{- $child = (merge $childDef (dict "id" $childId "fullId" $childFullId "root" $root "parentGithubCredential" $parentGithubCredential)) }}
      {{- end }}
      {{- include "generic-job-dsl-definition" $child | indent 4 }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Generate the job-dsl definition of a single generic item
*/}}
{{- define "generic-job-dsl-definition" }}
  {{- $jobKind := .kind | default "multibranchPipelineJob" }}
  {{- if eq "folder" $jobKind }}
    {{- include "folder-job-dsl-definition" . }}
  {{- else if eq "multibranchPipelineJob" $jobKind }}
    {{- include "multibranch-job-dsl-definition" . }}
  {{- end }}
{{- end }}

{{/*
Generate the the "common" elements for any job-dsl definition
*/}}
{{- define "common-job-dsl-definition" }}
displayName('{{ coalesce .name .id }}')
description('{{ coalesce .description .name .id }}')
  {{- include "common-credentials-job-dsl-definition" . }}
{{- end }}

{{/* vim: set filetype=mustache: */}}
{{/*
Generate the job-dsl definition of a folder
*/}}
{{- define "folder-job-dsl-definition" }}
folder('{{ .id }}') {
  {{- include "common-job-dsl-definition" . | indent 2 }}
}
{{- end }}
