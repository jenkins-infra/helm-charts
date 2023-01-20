{{- define "jenkins.serviceAccountName" -}}
  {{- if .Values.existingServiceAccount -}}
    {{- splitList ":" .Values.existingServiceAccount | last -}}
  {{- else -}}
    {{- "jenkins-agent" -}}
  {{- end -}}
{{- end -}}

{{- define "jenkins.serviceAccountNamespace" -}}
  {{- if .Values.existingServiceAccount -}}
    {{- splitList ":" .Values.existingServiceAccount | first -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}
