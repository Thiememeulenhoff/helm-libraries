# Helm libraries

This repo contains some Helm libraries you can use.

## Use

To use the repo, install the repo `https://thiememeulenhoff.github.io/helm-libraries` and select the correct package.

## New chart version

Edit `php-library/Chart.yaml`

Then do:

```shell
helm lint php-library --strict --with-subcharts
helm package php-library --destination docs/
helm repo index docs/ --url https://thiememeulenhoff.github.io/helm-libraries
```

## Updating Chart.lock on a repository using phplibrary

In your repository, you haven't put `Chart.lock` in `.gitignore` to be on the safe side?

Then here's how you update it once you cd to the Helm chart folder:

```shell
helm dependency update
```
