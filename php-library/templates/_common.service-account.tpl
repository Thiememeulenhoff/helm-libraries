{{- define "phplibrary.common.serviceAccount.tpl" -}}
{{- $top := first . }}
{{- $container := index . 1 }}

{{- with merge ($container.serviceAccount | default dict) ($top.Values.serviceAccount | default dict) ($top.Values.phplibrary.serviceAccount | default dict) }}
{{- if . }}
serviceAccountName: {{ include "phplibrary.serviceAccountName" (list $top .) | quote }}
automountServiceAccountToken: true
{{- end }}
{{- end }}

{{- end }}

{{- define "phplibrary.common.serviceAccount" -}}
{{- include "phplibrary.util.merge" (append . "phplibrary.common.serviceAccount.tpl") }}
{{- end }}
