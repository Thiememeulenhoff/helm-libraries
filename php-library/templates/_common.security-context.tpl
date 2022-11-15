{{- define "phplibrary.common.securityContext.tpl" -}}
{{- $top := first . }}
{{- $container := index . 1 }}

{{- with merge ($container.securityContext | default dict) ($top.Values.securityContext | default dict) $top.Values.phplibrary.securityContext }}
{{- if .fsGroup }}
securityContext:
    fsGroup: {{ .fsGroup | default nil }}
{{- end }}
{{- end }}

{{- end }}

{{- define "phplibrary.common.securityContext" -}}
{{- include "phplibrary.util.merge" (append . "phplibrary.common.securityContext.tpl") }}
{{- end }}
