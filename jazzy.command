#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
jazzy   --github_url https://github.com/bmlt-enabled/BMLTiOSLib \
        --build-tool-arguments -scheme,"BMLTiOSLib" \
        --readme ./README.md \
        --title "BMLTiOSLib Doumentation" \
        --author BMLT-Enabled \
        --theme fullwidth \
        --author_url https://bmlt.app \
        --min-acl public
cp ./img/* docs/img
cd "${CWD}"
