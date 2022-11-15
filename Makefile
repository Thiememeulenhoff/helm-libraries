build:
	helm dependency update php-application

package:
	helm package php-library --destination docs/
	helm repo index docs/ --url https://thiememeulenhoff.github.io/helm-libraries
