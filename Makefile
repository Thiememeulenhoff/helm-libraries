package:
	make lint
	helm package php-library --destination docs/
	helm repo index docs/ --url https://thiememeulenhoff.github.io/helm-libraries

lint:
	helm lint php-library --strict --with-subcharts
