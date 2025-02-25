#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR
echo "### Will unzip the templates into $DIR..."
unzip -o ./templates.zip
echo "### Completed..."