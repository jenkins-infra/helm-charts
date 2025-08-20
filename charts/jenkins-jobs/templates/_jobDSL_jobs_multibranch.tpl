{{/* vim: set filetype=mustache: */}}
{{/*
Generate the job-dsl definition of a multibranch job
*/}}
{{- define "multibranch-job-dsl-definition" -}}
  {{- $repository := .repository | default .id -}}
  {{- $repoOwner := (coalesce .repoOwner .root.Values.defaults.repoOwner) -}}
multibranchPipelineJob('{{ .fullId | default .id }}') {
  triggers {
    periodicFolderTrigger {
      interval('{{ coalesce .triggerScanInterval .root.Values.defaults.triggerScanInterval }}')
    }
  }

  branchSources {
    branchSource {
      source {
        github {
          id('{{ .fullId | default .id | toString }}')
          credentialsId('{{ coalesce .githubCredentialsId .parentGithubCredential "github-app-infra" }}')
          configuredByUrl(true)
          repositoryUrl('https://github.com/{{ $repoOwner }}/{{ $repository }}')
          repoOwner('{{ $repoOwner }}')
          repository('{{ $repository }}')
          traits {
            gitHubNotificationContextTrait {
              contextLabel('jenkins/{{ .root.Values.jenkinsFqdn | default "localhost" }}/{{ .fullId | default .id }}')
              typeSuffix(true)
            }
            gitHubSCMSourceStatusChecksTrait {
              // Note: changing this name might have impact on github branch protections if they specify status names
              name({{ .githubCheckName | default "jenkins" | squote }})
    {{- if empty .enableGitHubChecks }}
              skip(true)
              skipProgressUpdates(true)
    {{- else }}
              skip({{ not .enableGitHubChecks }})
              skipProgressUpdates({{ not .enableGitHubChecks }})
    {{- end }}
              // If this option is checked, the notifications sent by the GitHub Branch Source Plugin will be disabled.
    {{- if empty .disableGitHubNotifications }}
              skipNotifications(false)
    {{- else }}
              skipNotifications({{ .disableGitHubNotifications }})
    {{- end }}
              // Default value: false. Warning: risk of secret leak in console if the build fails
              // Please note that it only disable the detailed logs. If you really want no logs, then use "skip(false)' instead
              suppressLogs(true)
              unstableBuildNeutral(false)
            }
            gitHubBranchDiscovery {
              strategyId(1) // 1-only branches that are not pull requests
            }
            gitHubPullRequestDiscovery {
              // 1 - Merging the pull request with the current target branch revision
              // 2 - The current pull request revision
              strategyId({{ .mergePrWithTargetRevision | default false | ternary "1" "2"  }})
            }
            gitHubForkDiscovery {
              // 1 - Merging the pull request with the current target branch revision
              // 2 - The current pull request revision
              strategyId({{ .mergePrWithTargetRevision | default false | ternary "1" "2"  }})
              trust {
                gitHubTrustPermissions()
              }
            }
            pruneStaleBranchTrait()
    {{- if not .disableTagDiscovery }}
            gitHubTagDiscovery()
    {{- end }}
            pullRequestLabelsBlackListFilterTrait {
              labels('on-hold,ci-skip,skip-ci')
            }
            // Select branches and tags to build based on these filters
            headWildcardFilterWithPR {
              includes('{{ .branchIncludes | default "main master PR-*" }}') // only branches listed here
              excludes('{{ .branchExcludes | default "" }}')
              tagIncludes('*')
              tagExcludes('')
            }
          }
        }
        buildStrategies {
          buildAnyBranches {
            strategies {
    {{- if eq (.buildOnFirstIndexing | toString) "<nil>" }}
              skipInitialBuildOnFirstBranchIndexing()
    {{- end }}
              buildChangeRequests {
                ignoreTargetOnlyChanges(true)
    {{- if eq (.allowUntrustedChanges | toString) "<nil>" }}
                ignoreUntrustedChanges(true)
    {{- else }}
                ignoreUntrustedChanges({{ not .allowUntrustedChanges }})
    {{- end }}
              }
              buildRegularBranches()
    {{- if not .disableTagDiscovery }}
              buildTags {
                atLeastDays('-1')
                atMostDays('3')
              }
    {{- end }}
            }
          }
        }
      }
    }
  }
  factory {
    workflowBranchProjectFactory {
      scriptPath('{{ coalesce .jenkinsfilePath .root.Values.defaults.jenkinsfilePath }}')
    }
  }
  orphanedItemStrategy {
    defaultOrphanedItemStrategy {
      pruneDeadBranches(true)
      daysToKeepStr("{{ .orphanedItemStrategyDaysToKeep | default "" }}")
      numToKeepStr("{{ .orphanedItemStrategyNumToKeep | default "" }}")
      abortBuilds(true)
    }
  }
{{ indent 2 (include "common-job-dsl-definition" .) }}
}
{{- end }}
