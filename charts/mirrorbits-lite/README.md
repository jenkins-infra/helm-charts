# Mirrorbits Lite
<!-- TODO: update to lite -->

<!--
This chart deploys two services [mirrorbits](https://github.com/etix/mirrorbits) and a simple httpd (Apache2) service that return every file

A "Quick Start" is available on [etix/mirrorbits](repository)

Docker image used in this chart is defined from [jenkins-infra/docker-mirrorbits](https://github.com/jenkins-infra/docker-mirrorbits)

## Requirements

This chart requires a redis database which can be deployed with the redis helm [chart](https://github.com/helm/charts/tree/master/stable/redis)

## Settings

Look at the [`values.yaml` source file](./values.yaml) to get the possible configuration values.

## HowTo

Mirrorbits is configured using its cli. The configuration is stored in the redis database which means that you can either store a configuration locally and run the cli from your machine or you can connect inside one of the pod running to use the cli.

### Access Mirrorbits CLI

You need to first identify a pod name and then run a bash command inside it.

```shell
kubectl get pods --label "app.kubernetes.io/name=mirrorbits"
kubectl exec --interactive --tty --container=mirrorbits <POD_NAME> -- bash`
```

## Links

* [Mirrorbits](https://github.com/etix/mirrorbits) - Upstream project
* [Mirrorbits](https://github.com/jenkins-infra/docker-mirrorbits) - Docker Image
-->
