{{- define "web-app.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "web-app.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}
