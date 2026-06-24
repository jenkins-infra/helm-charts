#!/bin/bash
set -eux -o pipefail

mvn_cache_dir="${MVN_CACHE_DIR:-"/tmp"}"
test -d "${mvn_cache_dir}"
mvn_local_repo="${MVN_LOCAL_REPO:-"${HOME}/.m2/repository"}"
mvn_cache_archive="${mvn_cache_dir}/maven-bom-local-repo.tar.gz"
# As 'dependency:go-offline' always use latest and until https://github.com/jenkins-infra/helpdesk/issues/5198 is fixed let's pin to 3.10.0
mvn_dependency_offline_target='org.apache.maven.plugins:maven-dependency-plugin:3.10.0:go-offline'

MVN_OPTS=("-Dmaven.repo.local=${mvn_local_repo}" "${mvn_dependency_offline_target}")

# Set up local working directory with BOM code
test -d ./bom || git clone https://github.com/jenkinsci/bom
pushd ./bom

read -r -a build_lines <<< "${RELEASE_LINES:-}"

read -r -a build_lines <<< "${RELEASE_LINES:-}"
for build_line in "${build_lines[@]}"; do
  if [[ $build_line != "weekly" ]]; then
      MVN_OPTS+=("-P $build_line")
  fi
  time mvn -pl sample-plugin \
      -DincludeScore=runtime,compile,test \
      "${MVN_OPTS[@]}"
done

# Generate a new cache archive from the local Maven repository
pushd "${mvn_local_repo}"
df -h .
du -sh .
time tar czf "${mvn_cache_archive}" ./
du -sh "${mvn_cache_dir}"/*
