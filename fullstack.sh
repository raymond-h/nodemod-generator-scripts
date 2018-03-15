#!/bin/bash

BASE="$(dirname $(readlink -f $0))"

cat > .dockerignore <<EOF
node_modules
EOF

cat > .gitignore <<EOF
.env*
repo.*.tar
EOF

cat > deploy.sh <<EOF
#!/bin/sh

VARIANT="\$1"

# read vars from .env.{variant} file
export \$(egrep -v '^#' ".env.\$VARIANT" | xargs)

APP_LIST_TMP="\$(ssh "\$DOKKU_HOST" -- --quiet apps:list | grep -E ^\$DOKKU_APP\$)"

if [ -z "\$APP_LIST_TMP" ]; then
  echo "App does not exist, creating..."
  ssh "\$DOKKU_HOST" apps:create "\$DOKKU_APP"

  BUILD_ARGS="\$(grep '^ARG ' "\$VARIANT.Dockerfile")"
  if [ -n "\$BUILD_ARGS" ]; then
    echo "*** App created, but '\$VARIANT.Dockerfile' accepts build args."
    echo "*** Set those up if necessary, using 'dokku docker-options:add', \\
      and then deploy again with the same command."
    echo "*** See: http://dokku.viewdocs.io/dokku/deployment/methods/dockerfiles/#build-time-configuration-variables"
    exit 0
  fi
fi

git archive -o "repo.\$VARIANT.tar" HEAD

link_variant_file () {
  if [ -e "\$VARIANT.\$1" ]; then
    echo "Adding \$VARIANT.\$1 as \$1"
    ln -s "\$VARIANT.\$1" \$1
    tar -r -f "repo.\$VARIANT.tar" \$1
    rm \$1
  fi
}

link_variant_file Dockerfile

echo "Deploying to app \$DOKKU_APP at \$DOKKU_HOST"
ssh "\$DOKKU_HOST" tar:in "\$DOKKU_APP" < "repo.\$VARIANT.tar"
EOF

chmod +x deploy.sh

cat > .env.backend <<EOF
DOKKU_HOST=""
DOKKU_APP=""
EOF

cp .env.backend .env.frontend

cat > backend.Dockerfile <<EOF
FROM node:9.8-alpine

COPY . /app
WORKDIR /app/backend

RUN ["npm", "install", "--prod"]

CMD ["npm", "start"]
EOF

cat > frontend.Dockerfile <<EOF
FROM node:9.8-alpine AS build

ARG API_URL

COPY . /app

WORKDIR /app/frontend

RUN ["npm", "install"]
RUN ["npm", "run", "build"]

FROM nginx:alpine

COPY --from=build /app/frontend/dist /usr/share/nginx/html
EOF

# --- Generate backend
mkdir -p backend/
pushd backend/

"$BASE/new.sh"

cat > lib/index.js <<EOF
const http = require('http');

const server = http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.end('Hello world!');
});

server.listen(process.env.PORT || 8000);
EOF

jq ".scripts.start = \"node .\"" \
  package.json > tmp.package.json
mv -f tmp.package.json package.json

npx sort-package-json

popd

# --- Generate frontend
mkdir -p frontend/
pushd frontend/

"$BASE/new-frontend.sh"

cat > src/index.js <<EOF
console.log('hello world!', document.getElementById('root'));

const apiUrl = process.env.API_URL.replace(/{hostname}/g, location.hostname);

fetch(apiUrl + '/test')
  .then(res => res.text())
  .then(text => console.log('From backend:', text))
  .catch(err => console.error(err));
EOF

popd
