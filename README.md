This is a script that, given two commits in a repo, opens all the PRs in the diff in new tabs in your default browser.

Instructions

To fork the repository and navigate to the folder:

    git clone github.com/blunderdome/PR-opener.git
    cd pr_opener
    
To run the script:

    ./script.sh from_commit to_commit base_url git_directory project_subdirectory

Example:

    ./script.sh origin/production origin/staging https://github.com/myusername/myproject/pull/ ~/Documents/programs/myproject tooling
    
Will open PRs that made changes to files in the `tooling/` directory of a project. The `project_subdirectory` parameter is optional, and if none is specified the script will look in the entire project rather than a specific subdirectory.

If you set a `base_url` and a `git_directory`, the script will use those as defaults whenever they aren't specified. Example:

    export REPO_URL=https://github.com/myusername/myproject/pull/
    export LOCAL_REPO_PATH=/Users/myusername/Documents/programs/myproject/.git
    
You can also add these directly to your `bash_profile` (or whatever profile you use).
    
The `from_commit` and `to_commit` variables default to `origin/production` and `origin/staging`, respectively.

Warning: running this script may open a lot of new tabs!
