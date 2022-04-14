{{/* vim: set filetype=mustache: */}}
{{/*
Generate the job-dsl configuration from specified values
*/}}
{{- define "jobs-dsl-config" -}}
  {{- range $jobId, $jobDef := .Values.jobsDefinition }}
- script: >
{{- include "generic-job-dsl-definition" (merge $jobDef (dict "id" $jobId)) | indent 4 }}
    {{- range $childId, $childDef := $jobDef.children }}
      {{- /*  Jenkins + Job DSL allow to define job children by concatenating their id with the parent id, separated by a / */}}
      {{- $childFullId := printf "%s/%s" $jobId $childId }}
      {{- $child := (dict "id" $childId "fullId" $childFullId ) }}
      {{- if $childDef }}
      {{- $child = (merge $childDef (dict "id" $childId "fullId" $childFullId )) }}
      {{- end }}
{{ include "generic-job-dsl-definition" $child | indent 6 }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/******************* Jobs (foler, multibranch, etc.) ***********************/}}
{{/*
Generate the job-dsl definition of a single generic item
*/}}
{{- define "generic-job-dsl-definition" -}}
{{- $jobKind := .kind | default "multibranchPipelineJob" }}
{{- if eq "folder" $jobKind -}}
{{ include "folder-job-dsl-definition" . }}
{{- else if eq "multibranchPipelineJob" $jobKind -}}
{{- include "multibranch-job-dsl-definition" . }}
{{- end -}}
{{- end -}}

{{/*
Generate the the "common" elements for any job-dsl definition
*/}}
{{- define "common-job-dsl-definition" -}}
displayName('{{ coalesce .name .id }}')
description('{{ coalesce .description .name .id }}')
  {{- if .credentials -}}
    {{- /* Prepare the 2 dicts of credentials: bindings and hackishxml */}}
    {{- $credentialsWithBindings := dict }}
    {{- $credentialsWithHackishXml := dict }}
    {{- range $credentialId, $credentialDef := .credentials }}
      {{- $credentialKind := .kind }}
      {{- if empty $credentialKind }}
        {{- /* Try to gues which kind of credential if not specified */}}
        {{- if and (hasKey $credentialDef "fileName") (hasKey $credentialDef "secretBytes") }}
          {{- $credentialKind = "file" }}
        {{- else if and (hasKey $credentialDef "azureEnvironmentName") (hasKey $credentialDef "clientId") }}
          {{- $credentialKind = "azure-serviceprincipal" }}
        {{- else if and (hasKey $credentialDef "privateKey") (hasKey $credentialDef "username") }}
          {{- $credentialKind = "ssh" }}
        {{- else if and (hasKey $credentialDef "password") (hasKey $credentialDef "username") }}
          {{- $credentialKind = "usernamePassword" }}
        {{- else if and (hasKey $credentialDef "accessKey") (hasKey $credentialDef "secretKey") }}
          {{- $credentialKind = "aws" }}
        {{- else if and (or (hasKey $credentialDef "appID") (hasKey $credentialDef "appId") (hasKey $credentialDef "appid")) (hasKey $credentialDef "privateKey") }}
          {{- $credentialKind = "githubapp" }}
        {{- else }}
          {{- $credentialKind = "string" }}
        {{- end }}
      {{- end }}
      {{- $credentialDef = set $credentialDef "kind" $credentialKind }}
      {{- if has $credentialKind (list "string" "file" "azure-serviceprincipal" "ssh" "githubapp") }}
        {{- $_ := set $credentialsWithHackishXml $credentialId $credentialDef }}
      {{- else if has $credentialKind (list "usernamePassword" "aws") }}
        {{- $_ := set $credentialsWithBindings $credentialId $credentialDef }}
      {{- end }}
    {{- end }}

properties {
  folderCredentialsProperty {
    domainCredentials {
      domainCredentials {
        domain {
          name('{{ .name }}')
          description('Credentials for the job {{ .name }}')
        }
{{- if $credentialsWithBindings }}
{{ include "binding-credentials-dsl-definition" $credentialsWithBindings | indent 8 }}
{{- end }}
      }
    }
  }
}
{{- /* Some credentials does not have a job-dsl binding (e.g. having a human-usable syntax) -
- https://issues.jenkins.io/browse/JENKINS-59971?focusedCommentId=383059&page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel#comment-383059
- https://issues.jenkins.io/browse/JENKINS-57435
- https://github.com/jenkinsci/job-dsl-plugin/pull/1202
*/}}
{{- if $credentialsWithHackishXml }}
{{ include "hackishxml-credentials-dsl-definition" $credentialsWithHackishXml }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Generate the job-dsl definition of a folder
*/}}
{{- define "folder-job-dsl-definition" }}
folder('{{ .id }}') {
{{ include "common-job-dsl-definition" . | indent 2 }}
}
{{- end -}}

{{/*
Generate the job-dsl definition of a multibranch job
*/}}
{{- define "multibranch-job-dsl-definition" -}}
{{- $repository := .repository | default .id }}
{{- $repositoryOwner := .repoOwner | default "jenkins-infra" }}
multibranchPipelineJob('{{ .fullId | default .id }}') {
  triggers {
    periodicFolderTrigger {
      interval('2h')
    }
  }

  branchSources {
    branchSource {
      source {
        github {
          id('{{ .fullId | default .id | toString }}')
          credentialsId('{{ .githubCredentialsId | default "github-app-infra" }}')
          configuredByUrl(true)
          repositoryUrl('https://github.com/{{ $repositoryOwner }}/{{ $repository }}')
          repoOwner('{{ $repositoryOwner }}')
          repository('{{ $repository }}')
          traits {
            gitHubSCMSourceStatusChecksTrait {
              // Note: changing this name might have impact on github branch protections if they specify status names
              name({{ .githubCheckName | default "jenkins" | squote }})
              skip({{ .disableGitHubChecks | default "false" }})
              // If this option is checked, the notifications sent by the GitHub Branch Source Plugin will be disabled.
              skipNotifications(false)
              skipProgressUpdates(false)
              // Default value: false. Warning: risk of secret leak in console if the build fails
              // Please note that it only disable the detailled logs. If you really want no logs, then use "skip(false)' instead
              suppressLogs(true)
              unstableBuildNeutral(false)
            }
            gitHubBranchDiscovery {
              strategyId(1) // 1-only branches that are not pull requests
            }
            // Only Origin Pull Request
            gitHubPullRequestDiscovery {
              strategyId(1) // 1-Merging the pull request with the current target branch revision
            }
            pruneStaleBranchTrait()
            gitHubTagDiscovery()
            pullRequestLabelsBlackListFilterTrait {
              labels('on-hold,ci-skip,skip-ci')
            }
            // Select branches and tags to build based on these filters
            headWildcardFilterWithPR {
              includes('main master PR-*') // only branches listed here
              excludes('')
              tagIncludes('*')
              tagExcludes('')
            }
          }
        }
        buildStrategies {
          buildAnyBranches {
            strategies {
              buildChangeRequests {
                ignoreTargetOnlyChanges(true)
                {{- if eq (.allowUntrustedChanges | toString) "<nil>" }}
                ignoreUntrustedChanges(true)
                {{- else }}
                ignoreUntrustedChanges({{ not .allowUntrustedChanges }})
                {{- end }}
              }
              buildRegularBranches()
              buildTags {
                atLeastDays('-1')
                atMostDays('3')
              }
            }
          }
        }
      }
    }
  }
  factory {
    workflowBranchProjectFactory {
      scriptPath('{{ .jenkinsfilePath | default "Jenkinsfile_k8s" }}')
    }
  }
  orphanedItemStrategy {
    // Remove unused items as soon as possible
    discardOldItems {
      // Keep removed SCM heads/branch/PRs only for 1 day (not 0 days to be sure that jobs are all finished/timeouted when deleting)
      // Does not apply to the build history of kept branches(use Pipeline for that)
      daysToKeep(1)
    }
  }
  configure { node ->
    def traits = node / 'sources' / 'data' / 'jenkins.branch.BranchSource' / 'source' / 'traits'
    // Not discovered by Job-DSL: need to be configured as raw-XML
    traits << 'org.jenkinsci.plugins.github__branch__source.ForkPullRequestDiscoveryTrait' {
      strategyId(1) // 1-Merging the pull request with the current target branch revision
      trust(class: 'org.jenkinsci.plugins.github_branch_source.ForkPullRequestDiscoveryTrait$TrustPermission')
    }
  }

{{ include "common-job-dsl-definition" . | indent 2 }}
}
{{- end -}}


{{/******************* Credentials ***********************/}}
{{/*
Generate the job-dsl definition of credentials with bindings available for job-dsl
*/}}
{{- define "binding-credentials-dsl-definition" }}
credentials {
  {{- range $credentialsId, $credentialDef := . }}
    {{- $kind := .kind | default "string" }}
    {{- if eq $kind "usernamePassword" }}
{{ include "username-password-credential-dsl-definition" (merge $credentialDef (dict "id" $credentialsId )) | indent 2 }}
    {{- else if eq $kind "aws"}}
{{ include "aws-credential-dsl-definition" (merge $credentialDef (dict "id" $credentialsId )) | indent 2 }}
    {{- end }}
  {{- end }}
}
{{- end -}}

{{/*
Generate the common job-dsl definition of a credential
*/}}
{{- define "credential-common-dsl-definition" -}}
scope('{{ .scope | default "GLOBAL" }}')
id('{{ .id }}')
description('{{ .description | default .id }}')
{{- end }}

{{/*
Generate the job-dsl definition of credentials with NO bindings, eg. through configuration of the XML configuration file
*/}}
{{- define "hackishxml-credentials-dsl-definition" -}}
{{/* Definition through the XML tree as per https://issues.jenkins.io/browse/JENKINS-59971 */}}
configure { node ->
  def configNode = node / 'properties' /  'com.cloudbees.hudson.plugins.folder.properties.FolderCredentialsProvider_-FolderCredentialsProperty' /  'domainCredentialsMap' / 'entry' / 'java.util.concurrent.CopyOnWriteArrayList'
  {{- range $credentialsId, $credentialDef := . }}
    {{- $credential := merge $credentialDef (dict "id" $credentialsId ) -}}
    {{- if empty .kind }}
{{ include "string-credential-dsl-definition" $credential | indent 2 }}
    {{- else if eq .kind "string" }}
{{ include "string-credential-dsl-definition" $credential | indent 2 }}
    {{- else if eq .kind "file" }}
{{ include "file-credential-dsl-definition" $credential | indent 2 }}
    {{- else if eq .kind "azure-serviceprincipal" }}
{{ include "azuresp-credential-dsl-definition" $credential | indent 2 }}
    {{- else if eq .kind "ssh" }}
{{ include "ssh-credential-dsl-definition" $credential | indent 2 }}
    {{- else if eq .kind "githubapp" }}
{{ include "githubapp-credential-dsl-definition" $credential | indent 2 }}
    {{- end -}}
  {{- end }}
}
{{- end -}}


{{/*
Generate the job-dsl definition of a string credential
*/}}
{{- define "string-credential-dsl-definition" }}
configNode << 'org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl'(plugin: 'plain-credentials') {
{{ include "credential-common-dsl-definition" . | indent 2 }}
  secret(hudson.util.Secret.fromString('{{ .secret }}').getEncryptedValue())
}
{{- end }}

{{/*
Generate the job-dsl definition of a file credential
*/}}
{{- define "file-credential-dsl-definition" }}
configNode << 'org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl' {
{{ include "credential-common-dsl-definition" . | indent 2 }}
  fileName('{{ .fileName }}')
  secretBytes(com.cloudbees.plugins.credentials.SecretBytes.fromBytes(new String('{{ .secretBytes }}').decodeBase64()).toString())
}
{{- end }}

{{/*
Generate the job-dsl definition of a file credential
*/}}
{{- define "azuresp-credential-dsl-definition" }}
configNode << 'com.microsoft.azure.util.AzureCredentials'(plugin: 'azure-credentials') {
{{ include "credential-common-dsl-definition" . | indent 2 }}
  data {
    subscriptionId(hudson.util.Secret.fromString('{{ .subscriptionId }}').getEncryptedValue())
    clientId(hudson.util.Secret.fromString('{{ .clientId }}').getEncryptedValue())
    {{- if .clientSecret }}
    clientSecret(hudson.util.Secret.fromString('{{ .clientSecret }}').getEncryptedValue())
    {{- end }}
    {{- if .certificateId }}
    certificateId('{{ .certificateId }}')
    {{- end }}
    tenant(hudson.util.Secret.fromString('{{ .tenant }}').getEncryptedValue())
    azureEnvironmentName('{{ .azureEnvironmentName }}')
  }
}
{{- end }}

{{/*
Generate the job-dsl definition of a usernamePassword credential
*/}}
{{- define "username-password-credential-dsl-definition" -}}
usernamePassword {
{{ include "credential-common-dsl-definition" . | indent 2 }}
  username('{{ .username }}')
  password('{{ .password }}')
  usernameSecret({{ .usernameSecret | default false}})
}
{{- end }}


{{/*
Generate the job-dsl definition of an aws credential
*/}}
{{- define "aws-credential-dsl-definition" -}}
awsCredentialsImpl {
{{ include "credential-common-dsl-definition" . | indent 2 }}
  accessKey('{{ .accessKey }}')
  secretKey('{{ .secretKey }}')
  iamRoleArn('{{ .iamRoleArn }}')
  iamMfaSerialNumber('{{ .iamMfaSerialNumber }}')
  iamExternalId('{{ .iamExternalId }}')
  {{- if .stsTokenDuration }}
  stsTokenDuration('{{ .stsTokenDuration }}')
  {{- end }}
}
{{- end }}

{{/*
Generate the job-dsl definition of a ssh username + key credential
*/}}
{{- define "ssh-credential-dsl-definition" -}}
configNode << 'com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey' {
{{ include "credential-common-dsl-definition" . | indent 2 }}
  username('{{ .username }}')
  {{- if .passphrase }}
  passphrase('{{ .passphrase }}')
  {{- end }}
  usernameSecret({{ .usernameSecret | default false}})
  privateKeySource(class:"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource") {
    privateKey('''{{ .privateKey }}''')

  }
}
{{- end }}

{{/*
Generate the job-dsl definition of a Github App credential
*/}}
{{- define "githubapp-credential-dsl-definition" -}}
configNode << 'org.jenkinsci.plugins.github__branch__source.GitHubAppCredentials'(plugin: 'github-branch-source') {
{{ include "credential-common-dsl-definition" . | indent 2 }}
  appID('{{ coalesce .appID .appId .appid }}')
  privateKey('''{{ .privateKey }}''')
  {{- if .owner }}
  owner({{ .owner }})
  {{- end }}
}
{{- end }}
