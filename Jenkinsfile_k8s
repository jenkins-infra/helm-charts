withCredentials([string(credentialsId: 'updatecli-github-token', variable: 'UPDATECLI_GITHUB_TOKEN')]) {
    updatecli(action: 'diff')
    if (env.BRANCH_IS_PRIMARY) {
        updatecli(action: 'apply')
    }
}
