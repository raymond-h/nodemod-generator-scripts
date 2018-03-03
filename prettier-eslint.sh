#!/bin/bash

npm install --save-dev onchange prettier-eslint-cli

PRETTIER="prettier-eslint --write \\\"!(node_modules/**/*)\\\""
ONCHANGE_PRETTIER="onchange src/ test/ prettier-eslint --write {{changed}}"

jq ".scripts.format = \"$PRETTIER\"" package.json > tmp.package.json
cat tmp.package.json > package.json

npm run format
