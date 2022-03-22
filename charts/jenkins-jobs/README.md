# Jenkins Jobs Helm Chart

This helm chart generates a Jenkins job-dsl configuration from a YAML definition to allow configuring Jenkins jobs as code in a simpler way.

It was created to allow defining credentials at job level to solve <https://github.com/jenkins-infra/helpdesk/issues/2840>.

IMPORTANT: the generated job-dsl is aimed at the Jenkins Infrastructure. You might be able to adapt to your needs but it's not the goal (better to contribute to the official Jenkins helm chart or JCasc).

## Usage

Install this helm chart by specifying the jobs definitions as helm values (look at the default `./values.yaml` file: there is a commented example).

Don't forget to also specify the value `jenkinsName` to the name of your Jenkins helm chart installation:
it creates a config map with the generated Job-DSL configuration that will be picked by the "kiwi" sidecar of the Jenkins pod, and mounted along your actual JCasc configurations.
