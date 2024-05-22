{{/* https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.26/#metricspec-v2-autoscaling */}}

{{- define "phplibrary.base.hpa.tpl" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
    name: {{ $hpa.name | default (include "phplibrary.name" $top) }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $hpa.name) $top $hpa) | nindent 8 }}
spec:
    {{- include "phplibrary.base.hpa.scaleTargetRef" (list $top $hpa) | nindent 4 -}}
    {{- include "phplibrary.base.hpa.replicas" (list $top $hpa) | nindent 4 -}}
    {{- include "phplibrary.base.hpa.metrics" (list $top $hpa) | nindent 4 -}}
    {{- include "phplibrary.base.hpa.behavior" (list $top $hpa) | nindent 4 -}}
{{- end -}}

{{- define "phplibrary.base.hpa.scaleTargetRef" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
{{- with merge ($hpa.target | default dict) (dict "name" $hpa.name) }}
scaleTargetRef:
    apiVersion: {{ .apiVersion | default "apps/v1" }}
    kind: {{ .kind | default "Deployment" }}
    name: {{ .name | default (include "phplibrary.name" $top) }}
{{- end }}
{{- end -}}

{{- define "phplibrary.base.hpa.replicas" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
{{- with $hpa.replicas }}
minReplicas: {{ .min | default 1 }}
maxReplicas: {{ .max | default . }}
{{- end -}}
{{- end -}}

{{- define "phplibrary.base.hpa.metrics" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
{{- range $metric := $hpa.metrics -}}
metrics:
  - type: {{ $metric.type | default "Resource" }}
    {{- if eq ($metric.type | default "Resource") "Resource" -}}{{- include "phplibrary.base.hpa.metrics.resource" (list $top $metric) | nindent 4 -}}{{- end -}}
{{- end -}}
{{- end -}}

{{- define "phplibrary.base.hpa.metrics.resource" -}}
{{- $top := first . -}}
{{- $metric := index . 1 -}}
resource:
    name: {{ $metric.name }}
    target:
        {{- if $metric.utilization }}
        type: Utilization
        averageUtilization: {{ $metric.utilization }}
        {{- else if $metric.averageValue }}
        type: AverageValue
        averageValue: {{ $metric.averageValue }}
        {{- else if $metric.value }}
        type: Value
        value: {{ $metric.value }}
        {{- end -}}
{{- end -}}

{{- define "phplibrary.base.hpa.behavior" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
behavior:
    scaleDown:
        policies:
        - type: Pods
          value: {{ $hpa.behavior.scaleDownPods | default 3 }}
          periodSeconds: {{ $hpa.behavior.scaleDownPodsPeriodSeconds | default 180 }}
        - type: Percent
          value: {{ $hpa.behavior.scaleDownPercentage | default 15 }}
          periodSeconds: {{ $hpa.behavior.scaleDownPercentagePeriodSeconds | default 180 }}
    selectPolicy: {{ $hpa.behavior.selectPolicy | default "Min" }}
    stabilizationWindowSeconds: {{ $hpa.behavior.stabilizationWindowSeconds | default 210 }}
{{- end -}}

{{- define "phplibrary.base.hpa" -}}
{{- $top := first . }}
{{- $hpa := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $hpa) "phplibrary.base.hpa.tpl") -}}
{{- end -}}
