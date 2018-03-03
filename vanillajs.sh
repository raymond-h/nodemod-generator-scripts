#!/bin/bash

# Ask questions
DEFAULT_MODULE_NAME="$(basename "$(pwd)")"
read -e -p "Module name ($DEFAULT_MODULE_NAME): " MODULE_NAME
MODULE_NAME=${MODULE_NAME:-$DEFAULT_MODULE_NAME}

read -e -p "Description: " DESCRIPTION

DEFAULT_AUTHOR="$(git config user.name)"
read -e -p "Author ($DEFAULT_AUTHOR): " AUTHOR
AUTHOR=${AUTHOR:-$DEFAULT_AUTHOR}

cat > .editorconfig <<EOF
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
EOF

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

npx mit "$AUTHOR" > LICENSE

# Install node modules
npm install --save-dev eslint ava npm-run-all
