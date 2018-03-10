#!/bin/bash

npm install --save-dev babel-cli babel-preset-env

cat > .babelrc <<EOF
{
  "presets": ["env"]
}
EOF

rm -rf lib/
mkdir -p src/
echo "// The entry point of all to come..." > src/index.js

echo "lib/" >> .gitignore
echo "src/" >> .npmignore

jq ".scripts.build = \"babel -d lib/ src/\" | \
	.scripts[\"watch:build\"] = \"npm run build -- --watch\"" package.json > tmp.package.json
mv -f tmp.package.json package.json

npx sort-package-json

npm run build
