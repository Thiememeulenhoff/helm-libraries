{{- define "phplibrary.common.imagePullSecrets.tpl" -}}
{{- $top := first . }}
{{- $container := index . 1 }}

{{- with concat ($container.imagePullSecrets | default list) ($top.Values.imagePullSecrets | default list) ($top.Values.phplibrary.imagePullSecrets | default list) }}
{{- if . }}
imagePullSecrets:
{{- range $name := . }}
  - name: {{ $name | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- end }}

{{- define "phplibrary.common.imagePullSecrets" -}}
{{- include "phplibrary.util.merge" (append . "phplibrary.common.imagePullSecrets.tpl") }}
{{- end }}
