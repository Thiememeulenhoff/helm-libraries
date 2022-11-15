{{- define "phplibrary.base.job.tpl" -}}
{{- $top := first . }}
{{- $job := index . 1 }}
{{- $name := $job.name }}
apiVersion: batch/v1
kind: Job
metadata:
    name: {{ $name }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $job.name) $top $job) | nindent 8 }}
    annotations:
        "helm.sh/hook": "pre-install,pre-upgrade"
        "helm.sh/hook-weight": "-5"
        "helm.sh/hook-delete-policy": before-hook-creation
spec:
    template: {{ include "phplibrary.common.pod" (list $top $job) | nindent 8 }}
            restartPolicy: {{ $job.restartPolicy | default "Never" }}
{{- end -}}

{{- define "phplibrary.base.job" -}}
{{- $top := first . }}
{{- $values := index . 1 }}
{{- $job := index . 2 }}
{{- include "phplibrary.util.merge" (append (list $top $job) "phplibrary.base.job.tpl") -}}
{{- end -}}
