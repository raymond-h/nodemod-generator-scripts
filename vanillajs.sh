#!/bin/bash

# Ask questions
DEFAULT_MODULE_NAME="$(basename "$(pwd)")"
read -e -p "Module name ($DEFAULT_MODULE_NAME): " MODULE_NAME
MODULE_NAME=${MODULE_NAME:-$DEFAULT_MODULE_NAME}

read -e -p "Description: " DESCRIPTION

DEFAULT_AUTHOR="$(git config user.name)"
read -e -p "Author ($DEFAULT_AUTHOR): " AUTHOR
AUTHOR=${AUTHOR:-$DEFAULT_AUTHOR}

# Generate files and folders
mkdir -p lib/ test/

echo "// The entry point of all to come..." > lib/index.js

cat > test/test.js <<EOF
import test from 'ava'

test.todo('write a test')
EOF

cat > .gitignore <<EOF
node_modules/

*.log
EOF

cat > .npmignore <<EOF
node_modules/

*.log
EOF

cat > package.json <<EOF
{
	"name": "$MODULE_NAME",
    "description": $(DESCRIPTION=$DESCRIPTION node -e "console.log(JSON.stringify(process.env.DESCRIPTION))"),
	"author": $(AUTHOR=$AUTHOR node -e "console.log(JSON.stringify(process.env.AUTHOR))"),
	"license": "MIT",
	"scripts": {
		"lint": "eslint lib/ test/",
		"test": "ava",
		"watch": "ava -w",
		"prepublish": "run-s lint test"
	}
}
EOF

cat > .eslintrc.json <<EOF
{
	"env": {
		"node": true
	}
}
EOF

cat > test/.eslintrc.json <<EOF
{
	"parserOptions": {
		"sourceType": "module"
	}
}
EOF

cat > LICENSE <<EOF
Copyright (c) $(date +%Y) $AUTHOR

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Install node modules
npm install --save-dev eslint ava npm-run-all
