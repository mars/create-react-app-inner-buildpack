#!/bin/bash

# Fail immediately on non-zero exit code.
set -e
# Debug, echo every command
#set -x

# Render runtime env vars into injectable JSON.
vars_as_json=`ruby -E utf-8:utf-8 -r /app/.heroku/create-react-app/injectable_env.rb -e InjectableEnv.render`
# Add another level of escaped-backslashes, so we still have 
# escaped values after sed command, which consumes a level of escapes.
escaped_vars_as_json=$(echo $vars_as_json | sed 's/\\/\\\\/g')

# Each bundle is generated with a unique hash name to bust browser cache.
js_bundle=`ls /app/build/static/js/main.*.js`

# Inject the escaped JSON into the Webpack bundle.
sed --in-place=.orig s/{{REACT_APP_VARS_AS_JSON}}/"${escaped_vars_as_json}"/ $js_bundle
