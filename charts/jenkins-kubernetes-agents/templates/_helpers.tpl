{{/* https://helm.sh/docs/howto/charts_tips_and_tricks/ */}}
{{- define "imagePullSecret" }}
{{- with .Values.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

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
