{{/*
Expand the name of the chart.
*/}}
{{- define "phplibrary.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "phplibrary.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "phplibrary.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "phplibrary.labels" -}}
{{ include "phplibrary.selectorLabels" . }}
app.kubernetes.io/environment: {{ .Values.environment }}
helm.sh/chart: {{ include "phplibrary.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .labels }}
{{ toYaml .labels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "phplibrary.selectorLabels" -}}
app.kubernetes.io/app: {{ include "phplibrary.name" . }}
app.kubernetes.io/name: {{ printf "%s-%s" (include "phplibrary.name" .) (.name | default "") }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "phplibrary.serviceAccountName" -}}
{{- $top := first . }}
{{- with $top | default . }}
{{- if ((.Values.serviceAccount).create | default .Values.phplibrary.serviceAccount.create) }}
{{- default (include "phplibrary.fullname" .) (.Values.serviceAccount | default .Values.phplibrary.serviceAccount).name }}
{{- else }}
{{- default "default" (.Values.serviceAccount | default .Values.phplibrary.serviceAccount).name }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the full image name to use
*/}}
{{- define "phplibrary.fullImageName" -}}
{{- $image := first . }}
{{- $top := last . }}
{{- with merge $image $top.Values.image }}
{{- printf "%v:%v" .repository (include "phplibrary.imageTag" (list $image $top)) }}
{{- end }}
{{- end }}

{{/*
Deployment tag
*/}}
{{- define "phplibrary.imageTag" -}}
{{- $image := first . }}
{{- $top := last . }}
{{- with merge $image $top.Values.image }}
{{- printf "%v" .tag | replace "{{ .Values.version }}" ($top.Values.version | toString) -}}
{{- end -}}
{{- end -}}

{{/*
Merge one or more YAML templates and output the result.
This takes an list of values:
- the top context
- [optional] zero or more template args
- [optional] the template name of the overrides (destination)
- the template name of the base (source)
*/}}
{{- define "phplibrary.util.merge" -}}
{{- $top := first . }}
{{- $tplName := last . }}
{{- $args := initial . }}
{{- if typeIs "string" (last $args) }}
  {{- $overridesName := last $args }}
  {{- $args = initial $args }}
  {{- $tpl := fromYaml (include $tplName $args) | default (dict) }}
  {{- $overrides := fromYaml (include $overridesName $args) | default (dict) }}
  {{- toYaml (merge $overrides $tpl) }}
{{- else }}
  {{- include $tplName $args }}
{{- end }}
{{- end }}

{{/*
Join a list to a comma seperated string
*/}}
{{- define "phplibrary.util.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{/*
Join a list to a comma seperated string
*/}}
{{- define "phplibrary.util.configmapName" -}}
{{- $top := first . }}
{{- $configuration := last . }}
{{- printf "%s-%s" $top.Chart.Name ($configuration.name | default $top.Release.Name) }}
{{- end -}}
