{{- define "phplibrary.base.deployment.tpl" -}}
{{- $top := first . }}
{{- $deployment := index . 1 }}
apiVersion: apps/v1
kind: Deployment
metadata:
    name: {{ $deployment.name }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $deployment.name) $top $deployment) | nindent 8 }}
spec:
    {{- include "phplibrary.common.replicas" (list $top $deployment) | indent 4 }}
    revisionHistoryLimit: {{ $deployment.revisionHistoryLimit | default 3 }}
    minReadySeconds: {{ $deployment.minReadySeconds | default 0 }}
    {{- include "phplibrary.base.deployment.deploymentStrategy" (list $top $deployment) | indent 4 }}
    selector:
        matchLabels: {{- include "phplibrary.selectorLabels" (merge (dict "name" $deployment.name) $top $deployment) | nindent 12 }}
    template: {{- include "phplibrary.common.pod" (list $top $deployment) | nindent 8 }}
{{- end -}}

{{- define "phplibrary.base.deployment.deploymentStrategy" -}}
{{- $top := first . }}
{{- $deployment := index . 1 }}
{{- $deploymentStrategy := $deployment.deploymentStrategy | default dict }}
{{- $type := ($deploymentStrategy.type | default "RollingUpdate") }}
strategy:
    type: {{ $type }}
    {{- if eq $type "RollingUpdate" }}
    rollingUpdate:
        maxSurge: {{ $deploymentStrategy.maxSurge | default 1 }}
        maxUnavailable: {{ $deploymentStrategy.maxUnavailable | default 1 }}
    {{- end }}
{{- end }}

{{- define "phplibrary.base.deployment" -}}
{{- $top := first . }}
{{- $deployment := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $deployment) "phplibrary.base.deployment.tpl") -}}
{{- end -}}
