#!/bin/bash

BASE="$(dirname $(readlink -f $0))"

"$BASE/new.sh"

rm -rf lib/
mkdir -p src/

cat > src/index.js <<EOF
console.log('hello world!', document.getElementById('root'));
EOF

cat > src/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>React with Parcel</title>
  </head>
  <body>
    <div id="root"></div>
    <script src="./index.js"></script>
  </body>
</html>
EOF

echo ".cache/" >> .gitignore
echo "dist/" >> .gitignore
echo ".env*" >> .gitignore
rm .npmignore

npm install --save-dev parcel-bundler

jq ".scripts.build = \"parcel build --public-url / src/index.html\" | \
	.scripts.start = \"parcel -p 8080 src/index.html\" | \
	(.main, .directories.lib, .scripts.lint) |= gsub(\"lib\"; \"src\")" \
	package.json > tmp.package.json
mv -f tmp.package.json package.json

jq ".env.browser = true" \
	.eslintrc.json > tmp.eslintrc.json
mv -f tmp.eslintrc.json .eslintrc.json

npx sort-package-json
npm run lint
