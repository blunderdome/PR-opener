This is a script that, given two commits in a repo, opens all the PRs in the diff in new tabs in your default browser.

Instructions

After forking the repo

    git clone github.com/blunderdome/PR-opener.git
    cd pr_opener
    chmod +x ./script.sh
    ./script.sh from_commit to_commit base_url git_directory

That should look something like this:

    ./script.sh origin/production origin/staging https://github.com/myusername/myproject/pull/ ~/Documents/programs/myproject

If you set a base_url and a git_directory, the script will use those as defaults whenever they aren't specified

    export REPO_URL=https://github.com/myusername/myproject/pull/
    export LOCAL_REPO_PATH=/Users/alexanderroy/Documents/NoRedInk/.git
    
The `from_commit` and `to_commit` variables default to `origin/production` and `origin/stagin`, respectively.

Warning: running this script may open a lot of new tabs!
