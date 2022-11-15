{{- define "phplibrary.common.replicas.tpl" -}}
{{- $top := first . }}
{{- $container := index . 1 }}

{{- if not $container.hpa }}
replicas: {{ $container.replicas | default 1 }}
{{- end }}
{{- end }}

{{- define "phplibrary.common.replicas" -}}
{{- include "phplibrary.util.merge" (append . "phplibrary.common.replicas.tpl") }}
{{- end }}
