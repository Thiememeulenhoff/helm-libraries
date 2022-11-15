{{- define "phplibrary.common.pod.tpl" -}}
{{- $top := first . }}
{{- $pod := index . 1 }}
metadata:
    {{- with (include "phplibrary.common.pod.labels" (list (dict "name" $pod.name) $top $pod)) }}
    {{ if . }}labels: {{- . | nindent 8 }}{{- end }}
    {{- end }}
    {{- with (include "phplibrary.common.pod.annotations" (list $top $pod)) }}
    {{ if . }}annotations: {{- . | nindent 8 }}{{- end }}
    {{- end }}

spec:
    {{- include "phplibrary.common.imagePullSecrets" (list $top $pod) | indent 4 }}
    {{- include "phplibrary.common.serviceAccount" (list $top $pod) | indent 4 }}
    {{- include "phplibrary.common.securityContext" (list $top $pod) | indent 4 }}
    {{- include "phplibrary.common.terminationGracePeriodSeconds" (list $top $pod) | indent 4 }}
    {{- include "phplibrary.common.pod.initContainers" (list $top $pod) | indent 4 }}
    {{- include "phplibrary.common.pod.containers" (list $top $pod) | indent 4 }}
    {{- include "phplibrary.common.volumes" (list $top $pod) | nindent 4 }}
{{- end }}

{{- define "phplibrary.common.pod.labels" -}}
{{- $top := first . }}
{{- $pod := index . 1 }}
{{- include "phplibrary.selectorLabels" (merge $top $pod) }}

{{- if $pod.labels }}
{{- toYaml $pod.labels }}
{{- end }}
{{- end }}

{{- define "phplibrary.common.pod.annotations" -}}
{{- $top := first . }}
{{- $pod := index . 1 }}

{{- range $name, $container := $pod.initContainers | default dict }}
ad.datadoghq.com/{{ $name }}.logs: '[{"source":"{{ $container.datadogSource | default ($top.Values.datadogSource | default "unknown") }}","service":"{{ printf "%s-%s" $top.Release.Namespace $pod.name }}"}]'
{{- end }}
{{- range $name, $container := $pod.containers | default (dict "container" dict) }}
ad.datadoghq.com/{{ $name }}.logs: '[{"source":"{{ $container.datadogSource | default ($top.Values.datadogSource | default "unknown") }}","service":"{{ printf "%s-%s" $top.Release.Namespace $pod.name }}"}]'
{{- end }}

{{- if $pod.saveToEvict | default true }}
cluster-autoscaler.kubernetes.io/safe-to-evict: 'true'
{{- end }}

{{- if $pod.annotations }}
{{ toYaml $pod.annotations }}
{{- end }}
{{- end }}

{{- define "phplibrary.common.pod.containers" -}}
{{- $top := first . }}
{{- $pod := index . 1 }}
containers:
{{- if $pod.containers }}
{{- range $name, $container := $pod.containers }}
{{- $name := $name }}
  - {{- include "phplibrary.common.container" (list $top (merge (dict "name" $name) (merge $container $pod))) | indent 4 }}
{{- end }}
{{- else }}
  - {{- include "phplibrary.common.container" (list $top (merge (dict "name" "container") $pod)) | indent 4 }}
{{- end }}
{{- end }}

{{- define "phplibrary.common.pod.initContainers" -}}
{{- $top := first . }}
{{- $pod := index . 1 }}
{{- if $pod.initContainers }}
initContainers:
{{- range $name, $container := $pod.initContainers }}
{{- $name := $name }}
  - {{- include "phplibrary.common.container" (list $top (merge (dict "name" $name) (merge $container $pod))) | indent 4 }}
{{- end }}
{{- end }}
{{- end }}

{{- define "phplibrary.common.pod" -}}
{{- $top := first . }}
{{- $pod := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $pod) "phplibrary.common.pod.tpl") -}}
{{- end }}
