#!/bin/bash

function cleanup () {
    rm -Rf /app/.heroku/php
}

pushd $WORKSPACE_DIR

# First, build our libraries since our ‘apps’ depend on them
for lib in libraries/*; do
    cleanup
    echo $lib;
    bob --overwrite deploy $lib
    echo; echo;
done

# Build our apps
for app in {nginx,apache,php,hhvm}-*; do
    cleanup
    echo $app
    bob --overwrite deploy $app
    echo; echo;
done

# Add ‘bare’ PHP extensions before our normal extensions
for ext in extensions/*/*-bare; do
    cleanup
    echo $ext;
    bob --overwrite deploy $ext
    echo; echo;
done

# Add normal PHP extensions
for ext in extensions/*/*; do
    if [[ "$ext" == *-bare ]]; then
        continue;
    fi
    cleanup
    echo $ext;
    bob --overwrite deploy $ext
    echo; echo;
done

# Add composer
cleanup
bob deploy composer

popd

echo "DONE"