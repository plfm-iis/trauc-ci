function get_commit() {
    TMPDIR=${TARGET}-${BENCHMARK}
    rm -rf $TMPDIR
    mkdir $TMPDIR
    git clone --branch $BRANCH $REPO_URL ${TMPDIR}
    cd ${TMPDIR}
    COMMIT_HASH="$(git log -1 --abbrev-commit --oneline $BRANCH \
         | awk '{print $1}')"
    cd ../ && rm -rf ${TMPDIR}

    echo "Commit hash=$COMMIT_HASH"
}
