{{/* https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.21/#metricspec-v2beta2-autoscaling */}}

{{- define "phplibrary.base.hpa.tpl" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
    name: {{ $hpa.name | default (include "phplibrary.name" $top) }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $hpa.name) $top $hpa) | nindent 8 }}
spec:
    {{ with $hpa.target | default dict }}
    scaleTargetRef:
        apiVersion: {{ .apiVersion | default "apps/v1" }}
        kind: {{ .kind | default "Deployment" }}
        name: {{ .name | default ($hpa.name | default (include "phplibrary.name" $top)) }}
    {{ end }}

    {{ with $hpa.replicas }}
    minReplicas: {{ .min | default 1 }}
    maxReplicas: {{ .max | default . }}
    {{ end }}

    {{ with $hpa.metrics | default list }}
    metrics:
        {{ range $metric := . }}
        - type: {{ $metric.type | default "Resource" }}
          {{ ($metric.type | default "Resource") | snakecase | lower | camelcase }}:
              name: {{ $metric.name }}
              target:
                  {{ if $metric.utilization }}
                  type: Utilization
                  averageUtilization: {{ $metric.utilization }}
                  {{ else if $metric.averageValue }}
                  type: AverageValue
                  averageValue: {{ $metric.averageValue }}
                  {{ else if $metric.value }}
                  type: Value
                  value: {{ $metric.value }}
                  {{ end }}
        {{ end }}
    {{ end }}

    {{ if $hpa.behavior }}
    {{ $hpa.behavior }}
    {{ end }}
{{- end -}}

{{- define "phplibrary.base.hpa" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $hpa) "phplibrary.base.hpa.tpl") -}}
{{- end -}}
