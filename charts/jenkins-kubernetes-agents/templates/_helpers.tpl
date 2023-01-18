{{/* https://helm.sh/docs/howto/charts_tips_and_tricks/ */}}
{{- define "imagePullSecret" }}
{{- with .Values.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{- define "jenkins.serviceAccountName" -}}
  {{- if .Values.serviceAccount.reuseExistingServiceAccount -}}
    {{- .Values.serviceAccount.existingServiceAccountName -}}
  {{- else -}}
    {{- .Values.serviceAccount.name -}}
  {{- end -}}
{{- end -}}

{{- define "jenkins.serviceAccountNamespace" -}}
  {{- if .Values.serviceAccount.reuseExistingServiceAccount -}}
    {{- .Values.serviceAccount.existingServiceAccountNamespace -}}
  {{- else -}}
    {{- if .Values.serviceAccount.namespaceOverride -}}
      {{- .Values.serviceAccount.namespaceOverride -}}
    {{- else -}}
      {{- .Release.Namespace -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
