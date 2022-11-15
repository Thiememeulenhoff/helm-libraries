{{- define "phplibrary.common.volumes.tpl" -}}
{{- $top := first . }}
{{- $container := index . 1 }}

{{- with merge ($container.volumes | default dict) ($top.Values.volumes | default dict) ($top.Values.phplibrary.volumes | default dict) }}
{{- if . }}
volumes:
{{- range $name, $volume := . }}
{{- $name := $name }}
  - {{- include "phplibrary.common.volumes.volume" (list (dict "name" $name) $volume) | indent 4 }}
{{- end }}
{{- end }}
{{- end }}

{{- end }}

{{- define "phplibrary.common.volumes.volume" -}}
{{- $name := first . }}
{{- $volume := index . 1 }}
name: {{ $name.name }}
{{ $volume | toYaml }}
{{- end }}

{{- define "phplibrary.common.volumes" -}}
{{- include "phplibrary.util.merge" (append . "phplibrary.common.volumes.tpl") }}
{{- end }}
