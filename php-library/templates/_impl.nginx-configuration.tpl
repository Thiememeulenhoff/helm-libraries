{{- define "phplibrary.nginxConfiguration" }}
{{- $top := first . }}
{{- $configOverrides := index . 1 }}
{{- $config := fromYaml (include "phplibrary.nginxConfiguration.config" (list $top $configOverrides)) }}
{{- include "phplibrary.util.merge" (append (list $top $config) "phplibrary.base.configMap") }}
{{- end }}

{{- define "phplibrary.nginxConfiguration.config" }}
{{- $top := first . }}
{{- $overrides := last . }}
name: nginx-configuration
data:
    http.conf: |-
        server {
            listen 80;
            listen [::]:80;

            server_name _;
            root /var/www/application/public;

            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header X-Content-Type-Options "nosniff" always;

            {{ if ne ($overrides.cors | default false) false }}
            add_header Access-Control-Allow-Origin "*" always;
            add_header Access-Control-Allow-Credentials "true" always;
            add_header Access-Control-Allow-Methods "GET, POST, DELETE, PUT, OPTIONS" always;
            add_header Access-Control-Allow-Headers "*" always;
            {{ end }}

            location / {
                try_files $uri /index.php$is_args$args;
            }

            location @rewriteapp {
                rewrite ^(.*)$ /index.php/$1 last;
            }

            location ~ ^/index\.php(/|$) {
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_split_path_info ^(.+\.php)(/.*)$;
                include fastcgi_params;
                fastcgi_param HTTPS 'on';
                fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
                fastcgi_param DOCUMENT_ROOT $realpath_root;

                internal;
            }

            location ~ \.php$ {
                return 404;
            }

            error_log /var/log/nginx/error.log;
            access_log /var/log/nginx/access.log;
        }
{{- end }}
