{{- define "phplibrary.base.service.tpl" -}}
{{- $top := first . }}
{{- $service := index . 1 }}
apiVersion: v1
kind: Service
metadata:
    name: {{ $service.name | default (include "phplibrary.name" $top) }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $service.name) $top $service) | nindent 8 }}
spec:
    type: {{ $service.type | default "NodePort" }}
    selector: {{- include "phplibrary.selectorLabels" (merge $top $service) | nindent 8 }}
    {{- include "phplibrary.base.service.ports" (list $top $service) | indent 4 }}
{{- end -}}

{{- define "phplibrary.base.service.ports" -}}
{{- $top := first . }}
{{- $service := index . 1 }}
ports:
{{- if $service.ports }}
{{- range $i, $port := $service.ports }}
  - {{- include "phplibrary.base.service.port" (list $port $i) | indent 4 }}
{{- end }}
{{- else if $service.port }}
  - {{- include "phplibrary.base.service.port" (list (dict "port" $service.port) 1) | indent 4 }}
{{- else }}
  - {{- include "phplibrary.base.service.port" (list (dict "port" 80) 1) | indent 4 }}
{{- end }}
{{- end }}

{{- define "phplibrary.base.service.port" -}}
{{- $port := first . }}
{{- $index := index . 1 }}
port: {{ $port.port }}
targetPort: {{ $port.targetPort | default $port.port }}
protocol: {{ $port.protocol | default "TCP" }}
name: {{ $port.name | default (printf "http-%d" $index) }}
{{- end }}

{{- define "phplibrary.base.service" -}}
{{- $top := first . }}
{{- $service := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $service) "phplibrary.base.service.tpl") -}}
{{- end -}}
