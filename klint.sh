#!/bin/bash

if [ "$1" != "-s" ]
then
	npm install --save-dev eslint-config-kellyirc
fi

read -r -d '' KLINT_JSON <<JSON
{
	"extends": "kellyirc",
	"rules": {
		"require-yield": "off"
	}
}
JSON

jq --indent 4 ". + $KLINT_JSON" .eslintrc.json > .tmp.eslintrc.json
rm .eslintrc.json
mv .tmp.eslintrc.json .eslintrc.json
