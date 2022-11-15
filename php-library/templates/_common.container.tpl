{{- define "phplibrary.common.container.tpl" -}}
{{- $top := first . }}
{{- $container := index . 1 }}
name: {{ $container.name }}

{{- if $container.securityContext }}
securityContext: {{- toYaml $container.securityContext | nindent 4 }}
{{- end }}

{{- with merge ($container.image | default dict) $top.Values.image }}
image: {{ include "phplibrary.fullImageName" (list . $top) | quote }}
imagePullPolicy: {{ .pullPolicy | default "IfNotPresent" }}
{{- end }}

{{- if $container.command }}
command: {{ toYaml $container.command | nindent 4 }}
{{- if $container.args }}
args: {{ toYaml $container.args | nindent 4 }}
{{- end }}
{{- end }}

{{- if $container.resources }}
resources: {{- toYaml $container.resources | nindent 4 }}
{{- end }}

{{- with merge ($container.volumeMounts | default dict) ($top.Values.volumeMounts | default dict) }}
{{- if . }}
volumeMounts:
{{- range $name, $volumeMount := . }}
  - {{- toYaml (merge $volumeMount (dict "name" $name)) | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}

{{- with concat ($container.envFrom | default list) ($top.Values.envFrom | default list) }}
{{- if . }}
envFrom: {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{- with concat ($container.env | default list) ($top.Values.env | default list) }}
{{- if . }}
env: {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{- with ($container.livenessProbe | default dict) }}
{{- if . }}
livenessProbe: {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{- with ($container.readinessProbe | default dict) }}
{{- if . }}
readinessProbe: {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{- with ($container.lifecycle | default dict) }}
{{- if . }}
lifecycle: {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}

{{- end }}

{{- define "phplibrary.common.container" -}}
{{ include "phplibrary.util.merge" (append . "phplibrary.common.container.tpl") }}
{{- end -}}
