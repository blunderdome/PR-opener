if [ $# -eq 0 ]; then
  echo "Usage: ./script.sh base_url git_directory"
  exit 1
fi

base_url="$1"
git_directory="$2"

git --git-dir=$git_directory fetch
git --git-dir=$git_directory log --oneline origin/production..origin/master |
grep -o '[#][0-9]\{1,5\}' |
cut -c 2- |
sed -e "s|^|$base_url|" |
xargs echo
