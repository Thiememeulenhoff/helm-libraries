{{- define "phplibrary.phpDeployment" }}
{{- $top := first . }}
{{- $deploymentOverrides := index . 1 }}
{{- $deployment := merge $deploymentOverrides (fromYaml (include "phplibrary.phpDeployment.config" (list $top $deploymentOverrides))) }}
{{- include "phplibrary.util.merge" (append (list $top $deployment) "phplibrary.base.deployment") }}
{{- end }}

{{- define "phplibrary.phpDeployment.config" }}
{{- $top := first . }}
{{- $overrides := last . }}
{{- $codeCopyEnabled := eq ($overrides.disableCodeCopy | default false) false }}
name: application
annotations:
    ad.datadoghq.com/php.check_names: '["php_fpm"]'
    ad.datadoghq.com/php.init_configs: '[{}]'
    ad.datadoghq.com/php.instances: '[{"status_url":"http://%%host%%:9000/status", "ping_url":"http://%%host%%:9000/ping", "use_fastcgi": true, "ping_reply": "pong"}]'
    ad.datadoghq.com/nginx.check_names: '["nginx"]'
    ad.datadoghq.com/nginx.init_configs: '[{}]'
    ad.datadoghq.com/nginx.instances: '[{"nginx_status_url": "http://%%host%%:81/nginx_status/"}]'
containers:
    {{- with $overrides.php | default (dict "" "") }}
    php:
        datadogSource: php
        {{- if $codeCopyEnabled }}
        volumeMounts:
            code:
                mountPath: /volume
        {{- end }}
        command: ["/usr/local/sbin/php-fpm"]
        livenessProbe:
            tcpSocket:
                port: 9000
            initialDelaySeconds: 1
            failureThreshold: 5
        readinessProbe:
            tcpSocket:
                port: 9000
            initialDelaySeconds: 1
            failureThreshold: 5
        {{- with .resources | default (dict "" "") }}
        resources:
            {{- with .limits | default (dict "" "") }}
            limits:
                cpu: {{ .cpu | default "1000m" }}
                memory: {{ .memory | default "1000Mi" }}
            {{- end }}
            {{- with .requests | default (dict "" "") }}
            requests:
                cpu: {{ .cpu | default "1000m" }}
                memory: {{ .memory | default "1000Mi" }}
            {{- end }}
        {{- end }}
        lifecycle:
            {{- if $codeCopyEnabled }}
            postStart:
                exec:
                    command: ["/bin/bash", "-c", "cp -r {{ .root | default "/var/www/application" }} /volume/application"]
            {{- end }}
            preStop:
                exec:
                    command: ["/bin/bash", "-c", "/bin/sleep 20; kill -QUIT 1"]
    {{- end }}
    {{- with $overrides.nginx | default (dict "" "") }}
    nginx:
        datadogSource: nginx
        {{- with .image | default (dict "" "") }}
        image:
            repository: {{ .repository | default "nginx" }}
            tag: {{ .tag | default "1.26" }}
        {{- end }}
        volumeMounts:
            {{- if $codeCopyEnabled }}
            code:
                mountPath: /var/www
                subPath: application
            {{- end }}
            http-conf:
                mountPath: /etc/nginx/conf.d/default.conf
                name: nginx-configuration
                subPath: http.conf
        resources:
          limits:
              cpu: 50m
              memory: 50Mi
          requests:
              cpu: 20m
              memory: 15Mi
        lifecycle:
          preStop:
              exec:
                  command: ["/bin/sh", "-c", "sleep 20; /usr/sbin/nginx -s quit"]
    {{- end }}
volumes:
    {{- if $codeCopyEnabled }}
    code:
      emptyDir: {}
    {{- end }}
    nginx-configuration:
        configMap:
            name: {{ include "phplibrary.util.configmapName" (list $top (dict "name" "nginx-configuration")) }}
{{- end -}}
