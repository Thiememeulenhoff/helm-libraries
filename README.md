# Helm libraries

This repo contains some Helm libraries you can use.

## Use

To use the repo, install the repo `https://thiememeulenhoff.github.io/helm-libraries` and select the correct package.

## When preparing to do a new release

Update the Chart version in `php-library/Chart.yml`.

Also package the new Chart version like this:

```shell
helm lint php-library --strict --with-subcharts && helm package php-library --destination docs/ && helm repo index docs/ --url https://thiememeulenhoff.github.io/helm-libraries
```
