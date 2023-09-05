{{- define "phplibrary.base.cronjob.tpl" -}}
{{- $top := first . }}
{{- $cronjob := index . 1 }}
apiVersion: batch/v1
kind: Job
metadata:
    name: {{ $cronjob.name }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $cronjob.name) $top $cronjob) | nindent 8 }}
    annotations:
        "helm.sh/hook": "pre-install,pre-upgrade"
        "helm.sh/hook-weight": "-5"
        "helm.sh/hook-delete-policy": before-hook-creation
spec:
    concurrencyPolicy: {{ $cronjob.concurrencyPolicy | default "Forbid" }}
    schedule: {{ $cronjob.schedule | quote }}
    jobTemplate:
        spec:
            template:
                {{- include "phplibrary.common.pod" (list $top $cronjob) | indent 8 }}
                    restartPolicy: {{ $cronjob.restartPolicy | default "Never" }}
{{- end -}}

{{- define "phplibrary.base.cronjob" -}}
{{- $top := first . }}
{{- $cronjob := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $cronjob) "phplibrary.base.cronjob.tpl") -}}
{{- end -}}
