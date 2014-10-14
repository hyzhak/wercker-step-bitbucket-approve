#!/bin/bash
bitbucket-approve

if [ ! -n "$WERCKER_BITBUCKET_APPROVE_PASSWORD" ]; then
  fail 'Missing password property'
fi

if [ ! -n "$WERCKER_BITBUCKET_APPROVE_USERNAME" ]; then
  fail 'Missing username property'
fi

if [ -n "$DEPLOY" ]; then
  fail 'Should be used for build steps'
fi

if [ "$WERCKER_RESULT" = "passed" ]; then
  RESULT=`curl -d "" -u $WERCKER_BITBUCKET_APPROVE_USERNAME:$WERCKER_BITBUCKET_APPROVE_PASSWORD -s "https://api.bitbucket.org/2.0/repositories/$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY/commit/$WERCKER_GIT_COMMIT/approve"  --output $WERCKER_STEP_TEMP/result.txt -w "%{http_code}"`

  if [ "$RESULT" = "500" ]; then
    if grep -Fqx "No token" $WERCKER_STEP_TEMP/result.txt; then
      fail "No token is specified."
    fi

    if grep -Fqx "No hooks" $WERCKER_STEP_TEMP/result.txt; then
      fail "No hook can be found for specified subdomain/token"
    fi

    if grep -Fqx "Invalid channel specified" $WERCKER_STEP_TEMP/result.txt; then
      fail "Could not find specified channel for subdomain/token."
    fi

    if grep -Fqx "No text specified" $WERCKER_STEP_TEMP/result.txt; then
      fail "No text specified."
    fi

    fail "Unknown error."
  fi

  if [ "$RESULT" = "404" ]; then
    fail "Subdomain or token not found."
  fi

else
  export WERCKER_SLACK_NOTIFY_MESSAGE="$WERCKER_SLACK_NOTIFY_FAILED_MESSAGE"
fi