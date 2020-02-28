# TODO: think about quote marks

if [ "$1" == "--help" ]; then
  echo "Usage: ./script.sh from_commit to_commit base_url git_directory project_subdirectory"
  exit 1
fi
if [ "$1" == "--markdown" ]; then
  command -v hub >/dev/null 2>&1 || { echo >&2 "To generate markdown, you need to install hub first by running:\nbrew install hub\nSee https://github.com/github/hub for more information."; exit 1; }
  markdown="true"
  shift
fi

from_commit=${1:-'origin/production'}
to_commit=${2:-'origin/staging'}
base_url=${3:-$REPO_URL}
git_directory=${4:-$LOCAL_REPO_PATH}
project_subdirectory=${5:-$SUBDIRECTORY}

# Works on repos up to 99,999 issues / PRs. If your repo hits 100,000, change to {1,6\}
pull_request_regex='[#][0-9]\{1,5\}'

function keep_merges_that_change_subdirectory() {
  while read -r logline; do
    commit_hash=$(echo "$logline" | cut -d ' ' -f 1)
    if commit_changed_file_in_subdirectory "$commit_hash"; then
      echo "$logline"
    fi
  done
}

function commit_changed_file_in_subdirectory() {
  commithash=$1
  git --git-dir="$git_directory" log -m -1 --name-only --first-parent --pretty="format:" "$commithash" |
    grep "^${project_subdirectory}"
}

git --git-dir=$git_directory fetch

pr_numbers=$(
  git --git-dir=$git_directory log --oneline $from_commit..$to_commit |
  grep $pull_request_regex |
  keep_merges_that_change_subdirectory |
  grep -o $pull_request_regex |
  cut -c 2-
)

if [ "$markdown" == "true" ]; then
  echo "Generating markdown..."
  echo "$pr_numbers" |
  xargs -n 1 hub --git-dir=$LOCAL_REPO_PATH pr show -f "[ ] %i [%t](%U) (%au)" |
  pbcopy
  pbpaste
  echo "Markdown copied to clipboard."
fi

echo "$pr_numbers" |
sed -e "s|^|$base_url|" |
xargs open