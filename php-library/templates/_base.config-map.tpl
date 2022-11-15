{{- define "phplibrary.base.configMap.tpl" -}}
{{- $top := first . }}
{{- $configuration := index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
    name: {{ include "phplibrary.util.configmapName" (list $top $configuration) }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $configuration.name) $top $configuration) | nindent 8 }}
        app.kubernetes.io/configuration: {{ $top.Release.Name }}
    annotations:
        "helm.sh/hook": "pre-install,pre-upgrade"
        "helm.sh/hook-weight": "-10"
        "helm.sh/hook-delete-policy": before-hook-creation
data: {{ tpl (toYaml $configuration.data) $top | nindent 4 }}
{{- end -}}

{{- define "phplibrary.base.configMap" -}}
{{- $top := first . }}
{{- $configuration := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $configuration) "phplibrary.base.configMap.tpl") -}}
{{- end -}}
