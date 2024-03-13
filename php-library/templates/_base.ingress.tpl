{{- define "phplibrary.base.ingress.tpl" -}}
{{- $top := first . }}
{{- $ingress := index . 1 }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: {{ $ingress.name | default (include "phplibrary.name" $top) }}
    namespace: {{ $top.Release.Namespace }}
    labels: {{ include "phplibrary.labels" (merge (dict "name" $ingress.name) $top $ingress) | nindent 8 }}
    annotations: {{ include "phplibrary.base.ingress.annotations" (list $top $ingress) | nindent 8 }}
spec:
    {{- include "phplibrary.base.ingress.rules" (list $top $ingress) | indent 4 }}
{{- end -}}

{{- define "phplibrary.base.ingress.annotations" -}}
{{- $top := first . }}
{{- $ingress := index . 1 }}
kubernetes.io/ingress.class: alb
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
{{- if $ingress.securityGroups }}
alb.ingress.kubernetes.io/security-groups: {{ join "," $ingress.securityGroups | quote }}
{{- end }}
alb.ingress.kubernetes.io/tags: {{ include "phplibrary.base.ingress.annotations.tags" (list $top $ingress) | quote }}
{{- if eq true ($ingress.healthcheck | default false) }}
alb.ingress.kubernetes.io/healthcheck-path: {{ $ingress.healthcheckPath | default "/healthz" }}
alb.ingress.kubernetes.io/healthcheck-port: {{ $ingress.healthcheckPort | default 80 | quote }}
alb.ingress.kubernetes.io/healthcheck-interval-seconds: {{ $ingress.healthcheckInterval | default 30 | quote }}
alb.ingress.kubernetes.io/success-codes: {{ $ingress.healthcheckSuccessCodes | default "200" | quote }}
{{- end }}
{{- if $ingress.waf | default false }}
alb.ingress.kubernetes.io/wafv2-acl-arn: {{ $ingress.wafAclArn | quote }}
{{- end }}
{{- if and (not $ingress.waf) $ingress.albgroup | default false }}
alb.ingress.kubernetes.io/group.name: {{ $top.Values.environment }}
{{- end }}
{{- if and $ingress.waf $ingress.albgroup | default false }}
alb.ingress.kubernetes.io/group.name: {{ $top.Values.environment }}{{ $ingress.wafAclArn | quote }}
{{- end }}
{{- end }}
{{- if $ingress.ssl | default false }}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}, {"HTTPS":443}]'
alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
alb.ingress.kubernetes.io/load-balancer-attributes: {{ include "phplibrary.base.ingress.annotations.loadBalancerAttributes" (list $top $ingress) }}
alb.ingress.kubernetes.io/target-group-attributes: deregistration_delay.timeout_seconds={{ $ingress.deregistrationDelay | default 15 }}
alb.ingress.kubernetes.io/ssl-policy: {{ $ingress.sslPolicy | default "ELBSecurityPolicy-TLS13-1-2-Res-2021-06" }}
{{- else }}
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
{{- end }}
{{- end }}

{{- define "phplibrary.base.ingress.annotations.tags" -}}
{{- $top := first . }}
{{- $ingress := index . 1 }}

# <If WAF and ALB Group is enabled>
{{- if and $ingress.waf $ingress.albgroup | default false }}
{{- $environment := dict "Environment" ($top.Values.environment | default) }}
{{- $wafAclArn := dict "wafAclArn" ($ingress.wafAclArn | default) }}

{{- $tagsDict := merge $environment $wafAclArn }}
# </If WAF and ALB Group is enabled>
# <Else If ALB Group is enabled>
{{- else if and (not $ingress.waf) $ingress.albgroup | default false }}
{{- $environment := dict "Environment" ($top.Values.environment | default) }}

{{- $tagsDict := $environment }}
# </Else If ALB Group is enabled>
{{- else }}
{{- $environment := dict "Environment" ($top.Values.environment | default) }}
{{- $infrastructure := dict "Infrastructure" ($top.Values.infrastructure | default) }}
{{- $namespace := dict "Namespace" ($top.Release.Namespace | default) }}

{{- $tagsDict := merge $environment $infrastructure $namespace }}
{{- end }}
{{- $tagsList := list }}

{{- range $name, $item := $tagsDict }}
{{- if $item }}
{{- $tagsList = concat $tagsList (list (printf "%s=%v" $name $item))}}
{{- end }}
{{- end }}

{{- join "," $tagsList }}
{{- end }}

{{- define "phplibrary.base.ingress.annotations.loadBalancerAttributes" -}}
{{- $top := first . }}
{{- $ingress := index . 1 }}

{{- $dict := dict "routing.http2.enabled" "true" "idle_timeout.timeout_seconds" "300" }}

{{- with merge ($ingress.accessLogs | default dict) ($top.Values.accessLogs | default dict) }}
{{- if . }}
{{- $dict = merge $dict (dict "access_logs.s3.enabled" "true" "access_logs.s3.bucket" .bucket "access_logs.s3.prefix" (.prefix | default $top.Release.Namespace)) }}
{{- end }}
{{- end }}

{{- $tagsList := list }}
{{- range $name, $item := $dict }}
{{- if $item }}
{{- $tagsList = concat $tagsList (list (printf "%s=%v" $name $item))}}
{{- end }}
{{- end }}
{{- join "," $tagsList }}
{{- end }}

{{- define "phplibrary.base.ingress.rules" -}}
{{- $top := first . }}
{{- $ingress := index . 1 }}
rules:
{{- range $rule := $ingress.rules }}
  - {{- include "phplibrary.base.ingress.rule" (list $ingress $rule) | indent 4 }}
{{- end }}
{{- end }}

{{- define "phplibrary.base.ingress.rule" -}}
{{- $ingress := first . }}
{{- $rule := index . 1 }}

{{- $host := $rule.host | default ($ingress.host | default nil) }}
{{- if $host }}
host: {{ $host }}
{{- end }}
http: {{- include "phplibrary.base.ingress.paths" (list $ingress $rule) | indent 4 }}
{{- end }}

{{- define "phplibrary.base.ingress.paths" -}}
{{- $ingress := first . }}
{{- $rule := index . 1 }}
paths:
{{- if $rule.ssl | default ($ingress.ssl | default false) }}
  - {{- include "phplibrary.base.ingress.path" (list (dict "service" "ssl-redirect" "port" "use-annotation")) | indent 4 }}
{{- end }}
{{- if not $rule.paths }}
  - {{- include "phplibrary.base.ingress.path" (list $rule) | indent 4 }}
{{- end }}
{{- range $path := $rule.paths }}
  - {{- include "phplibrary.base.ingress.path" (list $path) | indent 4 }}
{{- end }}
{{- end }}

{{- define "phplibrary.base.ingress.path" -}}
{{- $path := first . }}
backend:
    service:
        name: {{ $path.service }}
        port:
            {{- $port := ($path.port | default 80) }}
            {{- if kindIs "string" $port }}
            name: {{ $port }}
            {{- else }}
            number: {{ $port }}
            {{- end }}
path: {{ $path.path | default "/*" | quote }}
pathType: {{ $path.pathType | default "ImplementationSpecific" }}
{{- end }}

{{- define "phplibrary.base.ingress" -}}
{{- $top := first . }}
{{- $ingress := index . 1 }}
{{- include "phplibrary.util.merge" (append (list $top $ingress) "phplibrary.base.ingress.tpl") -}}
{{- end -}}
