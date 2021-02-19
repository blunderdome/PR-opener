#!/usr/bin/env bash

# This script lists merge commits between production and master
# it further shows whether they passed ci-status checks.
# It filters to only auto-merge commits, so won't be fully inclusive
# of all changes.
#
# Requirements:
# - git (brew install git)
# - hub (brew install hub)
#

# Helpers for color output
function success() {
    printf "✅  \033[0;32m%s\033[0m %s\n" "${1}" "${2}"
}
function failed() {
    printf "❌  \033[0;31m%s\033[0m %s\n" "${1}" "${2}"
}
function warning() {
    printf "🟠  \033[0;33m%s\033[0m %s\n" "${1}" "${2}"
}

# Helper to retrive ci-status and report based on that status
function report_status () {
    commit_sha=$(echo "${line}" | cut -d ' ' -f 1)
    commit_info=$(echo "${line}" | cut -d ' ' -f 2-)
    status=$(hub ci-status "${commit_sha}")
    case "$status" in
    "success")
        success "$commit_sha" "$commit_info"
        ;;
    "failure")
        warning "$commit_sha" "$commit_info"
        ;;
    "error")
        failed "$commit_sha" "$commit_info"
        ;;
    *)
        warning "$commit_sha" "$commit_info"
        ;;
    esac
}

function fail {
    printf "Error: %s\n" "$1"
    exit 1
}
# End Helpers

if [ "$1" == "--help" ]; then
  printf "Identifies good commits between production and master if QA load is too high for the day.\n\n"
  printf "Usage:\n"
  printf "./qa-able-commits.sh [from_commit] [to_commit] [git_directory] [subdirectory]\n"
  printf "Note\n"
  printf "  <from_commit> defaults to 'origin/production'\n"
  printf "  <to_commit> defaults to 'origin/master'\n"
  printf "  <git_directory> defaults to environment variable LOCAL_REPO_PATH\n"
  printf "  <subdirectory> defaults to environment variable SUBDIRECTORY\n"
  exit 1
fi

if ! command -v git &> /dev/null
then
    fail "git was not found, maybe install using 'brew install git'"
fi

if ! command -v hub &> /dev/null
then
    fail "hub was not found, maybe install using 'brew install hub'"
fi

from_commit=${1:-'origin/production'}
to_commit=${2:-'origin/master'}
git_directory=${3:-$LOCAL_REPO_PATH}
project_subdirectory=${4:-$LOCAL_REPO_SUBDIRECTORY}
match_on=${5:-${LOCAL_REPO_MATCH_ON:-^Auto merge of #}}

[[ -d "${git_directory/.git}" ]] || fail "Could not find git within directory ${git_directory}"

if [ -z "$project_subdirectory" ];
then
    scope=()
else
    scope=(-- "${project_subdirectory}")
fi

printf "Fetching to ensure up to date..."
pushd "${git_directory}" > /dev/null || fail "Unable to find project directory ${git_directory}"
git fetch > /dev/null 2>&1 || fail "Failed to 'git fetch' in ${git_directory}"
printf " ✅\n"
printf "Checking commit status...\n"

printf "===== %s ======\n" "${to_commit}"

while read -r line
do
    report_status "${line}"
done < <(git log "${from_commit}..${to_commit}" --merges --first-parent --grep="${match_on}" --format="%h %s" "${scope[@]}") || fail "Unable to read git logs in ${git_directory}"

printf "===== %s ======\n" "$from_commit"
printf "✅  above means that this merge passed our status checks. If there is too much\n"
printf "to QA between the last production deploy and master then one of these commits\n"
printf "is a good staging deploy candidate.\n"
printf "Commits at the bottom of this list are closer to production and those at the\n"
printf "top are closer to master.\n"

popd > /dev/null || exit 0
