{{- define "phplibrary.common.terminationGracePeriodSeconds.tpl" -}}
{{- $top := first . }}
{{- $pod := index . 1 }}

{{- $period := ($pod.terminationGracePeriodSeconds | default ($top.Values.terminationGracePeriodSeconds | default 60)) }}
terminationGracePeriodSeconds: {{ $period }}
{{- end }}

{{- define "phplibrary.common.terminationGracePeriodSeconds" -}}
{{- include "phplibrary.util.merge" (append . "phplibrary.common.terminationGracePeriodSeconds.tpl") }}
{{- end }}
