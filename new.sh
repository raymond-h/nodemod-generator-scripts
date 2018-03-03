#!/bin/bash

# Generate files and folders
mkdir -p lib/ test/

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

cat > .gitignore <<EOF
node_modules/

*.log
EOF

cat > .npmignore <<EOF
node_modules/

*.log
EOF

cat > .eslintrc.json <<EOF
{
  "env": {
    "node": true,
    "es6": true
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

echo "// The entry point of all to come..." > lib/index.js

cat > test/test.js <<EOF
import test from 'ava';

test.todo('write a test');
EOF

cat > package.json <<EOF
{
  "main": "lib/index.js",
  "license": "MIT",
  "scripts": {
    "lint": "eslint --fix lib/ test/",
    "test": "ava",
    "watch": "run-p watch:*",
    "watch:test": "ava -w",
    "prepublish": "run-s lint test"
  }
}
EOF

npm init -y

AUTHOR="$(jq -r '.author' package.json | sed 's/^\(.\+\)\s\+<.\+$/\1/g')"

npx mit "$AUTHOR" > LICENSE

# Install dependencies
npm install --save-dev eslint ava npm-run-all

"$(dirname $0)/klint.sh"

npx sort-package-json
