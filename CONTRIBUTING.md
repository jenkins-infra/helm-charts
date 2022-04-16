# Contributing Guidelines

Contributions are welcome via GitHub pull requests. This document outlines the process to help get your contribution accepted.

## How to Contribute

1. Fork this repository, develop, and test your changes
2. Remember to sign off your commits as described above
3. Submit a pull request

***NOTE***: In order to make testing and merging of PRs easier, please submit changes to multiple charts in separate PRs.

## Local Development

### Prerequisites

- [helm](https://helm.sh/)
- [quintus/helm-unittest](https://github.com/quintush/helm-unittest)
- Read the [Review Guidelines](./REVIEW_GUIDELINES.md)
<!-- - [minikube](https://minikube.sigs.k8s.io/docs/start/), [k3d](https://k3d.io/), [kind](https://kind.sigs.k8s.io/), [microk8s](https://microk8s.io/) or some other local k8s cluster -->

### Setup

```console
CHART=jenkins-jobs
cd charts

# Validate the chart with Helm
helm lint "$CHART"

# Execute unit tests from ./tests (default) if any
helm unittest --helm3 "$CHART"
```

### Technical Requirements

- Should follow [Charts best practices](https://helm.sh/docs/topics/chart_best_practices/)
- Must pass CI jobs for linting and unit testing
- Any change to a chart requires a version bump following [semver](https://semver.org/) principles. See [Immutability](#immutability) and [Versioning](#versioning) below

Once changes have been merged, the release job will automatically run to package and release changed charts.

### Unit Tests

It's encouraged to add unit tests.
This project uses helm-unittest plugin.
Tests can be executed like this:

```console
# install the unittest plugin
$ helm plugin install https://github.com/quintush/helm-unittest

CHART=jenkins-jobs

# run the unittests
$ helm unittest --helm3 --strict -f 'tests/*.yaml' charts/"$CHART"

### Chart [ jenkins-jobs ] charts/jenkins-jobs

 PASS  default tests    charts/jenkins-jobs/tests/credentials_test.yaml
 PASS  default tests    charts/jenkins-jobs/tests/defaults_test.yaml
 PASS  default tests    charts/jenkins-jobs/tests/folders_test.yaml
 PASS  default tests    charts/jenkins-jobs/tests/multibranch_job_test.yaml

Charts:      1 passed, 1 total
Test Suites: 4 passed, 4 total
Tests:       13 passed, 13 total
Snapshot:    0 passed, 0 total
Time:        47.296375ms
```

### Immutability

Chart releases must be immutable. Any change to a chart warrants a chart version bump even if it is only a change to the documentation.

### Versioning

The chart `version` should follow [semver](https://semver.org/).

Charts should start at `1.0.0`. Any breaking (backwards incompatible) changes to a chart should:

1. Bump the MAJOR version
2. In the README, under a section called "Upgrading", describe the manual steps necessary to upgrade to the new (specified) MAJOR version
