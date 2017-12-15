#!/bin/sh
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
jazzy --github_url https://github.com/LittleGreenViper/BMLTiOSLib
cp icon.png docs/
