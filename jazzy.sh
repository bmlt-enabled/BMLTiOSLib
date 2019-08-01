#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
jazzy   --github_url https://github.com/bmlt-enabled/BMLTiOSLib\
        --readme ./README.md --theme fullwidth\
        --author Little\ Green\ Viper\ Software\ Development\ LLC\
        --author_url https://littlegreenviper.com\
        --min-acl public
cp icon.png docs/
cd "${CWD}"
