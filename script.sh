if [ "$1" == "--help" ]; then
  echo "Usage: ./script.sh from_commit to_commit base_url git_directory"
  exit 1
fi

from_commit=${1:-'origin/production'}
to_commit=${2:-'origin/staging'}
base_url=${3:-$REPO_URL}
git_directory=${4:-$LOCAL_REPO_PATH}

git --git-dir=$git_directory fetch
git --git-dir=$git_directory log --oneline $from_commit..$to_commit |
grep -o '[#][0-9]\{1,5\}' |
cut -c 2- |
sed -e "s|^|$base_url|" |
xargs open
