#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
#set -x

# Render runtime env vars into injectable JSON.
vars_as_json=`ruby -E utf-8:utf-8 -r /app/.heroku/create-react-app/injectable_env.rb -e InjectableEnv.render`

# Each bundle is generated with a unique hash name to bust browser cache.
js_bundle=`ls /app/build/static/js/main.*.js`

# Inject the escaped JSON into the Webpack bundle.
runtime_bundle=`sed s/{{REACT_APP_VARS_AS_JSON}}/${vars_as_json}/ $js_bundle`
echo $runtime_bundle > $js_bundle
