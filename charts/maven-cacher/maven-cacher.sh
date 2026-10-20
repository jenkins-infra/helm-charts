#!/bin/bash
set -eux -o pipefail

: "${RELEASE_LINES:-weekly}"
: "${JENKINS_BRANCHES:-master}"
: "${ADDITIONAL_DEPENDENCIES:-}"

mvn_cache_dir="${MVN_CACHE_DIR:-"/tmp"}"
test -d "${mvn_cache_dir}"
mvn_local_repo="${MVN_LOCAL_REPO:-"${HOME}/.m2/repository"}"
mvn_cache_archive="${mvn_cache_dir}/maven-bom-local-repo.tar.gz"
# As 'dependency:go-offline' always use latest and until https://github.com/jenkins-infra/helpdesk/issues/5198 is fixed let's pin to 3.10.0
mvn_dependency_offline_target='org.apache.maven.plugins:maven-dependency-plugin:3.10.0:go-offline'

mvn_global_opts=("-Dmaven.repo.local=${mvn_local_repo}")
mvn_global_opts_and_go_offline=("${mvn_global_opts[@]}" "${mvn_dependency_offline_target}")

test -d ./jenkins || git clone https://github.com/jenkinsci/jenkins
pushd ./jenkins
read -r -a branches <<< "${JENKINS_BRANCHES}"
for branch in "${branches[@]}"; do
	git checkout "${branch}"
    time mvn "${mvn_global_opts_and_go_offline[@]}"
done

if [[ -n "${ADDITIONAL_DEPENDENCIES}" ]]; then
	read -r -a dependencies <<< "${ADDITIONAL_DEPENDENCIES}"
	for dependency in "${dependencies[@]}"; do
		time mvn "${mvn_global_opts[@]}" dependency:get -Dartifact="${dependency}"
	done
fi
popd

test -d ./bom || git clone https://github.com/jenkinsci/bom
pushd ./bom
time mvn "${mvn_global_opts_and_go_offline[@]}"
# Stay in the bom for its sub-project 'sample-plugin'
read -r -a build_lines <<< "${RELEASE_LINES:-}"
for build_line in "${build_lines[@]}"; do
    mvn_buildline_opts=("${mvn_global_opts_and_go_offline[@]}")
    if [[ $build_line != "weekly" ]]; then
        mvn_buildline_opts+=("-P" "${build_line}")
    fi
    time mvn -pl sample-plugin \
        -DincludeScore=runtime,compile,test \
        "${mvn_buildline_opts[@]}"
done
popd

# Generate a new cache archive from the local Maven repository
pushd "${mvn_local_repo}"
df -h .
du -sh .
time tar czf "${mvn_cache_archive}" ./
du -sh "${mvn_cache_dir}"/*.gz
