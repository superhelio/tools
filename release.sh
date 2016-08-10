#!/usr/bin/env bash

# Git-flow release automation with
# version bumping and changelog generation
#
# Based on many great starting points:
#   https://gist.github.com/mareksuscak/1f206fbc3bb9d97dec9c
#   https://gist.github.com/pete-otaqui/4188238
#   https://gist.github.com/bclinkinbeard/1331790

# file in which to update version number
FILE_VERSION="VERSION"
# file to use as our change log
FILE_CHANGELOG="CHANGELOG.md"

NOW="$(date +'%Y-%m-%d')"
RED="\033[1;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
PURPLE="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

LATEST_HASH=$(git log --pretty=format:'%h' -n 1)

# Guess our remote url from remote.origin.url (minus .git from the end),
# change to your github project url. used to create Full changelog link
PROJECT_URL=$(git config --get remote.origin.url | sed 's/^\.git*//')

# current Git branch
BRANCH_CURRENT=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# establish branch and tag name variables
BRANCH_DEV=develop
BRANCH_MASTER=master


QUESTION_FLAG="${GREEN}?"
WARNING_FLAG="${YELLOW}!"
ERROR_FLAG="${RED}!"
NOTICE_FLAG="${CYAN}❯"

ADJUSTMENTS_MSG="${QUESTION_FLAG} ${CYAN}Now you can make adjustments to ${WHITE}CHANGELOG.md${CYAN}. Then press enter to continue."
PUSHING_MSG="${NOTICE_FLAG} Pushing new version to the ${WHITE}origin${CYAN}..."


if [ ! "$LATEST_HASH" ]; then
    echo -e "${ERROR_FLAG} No commits in the repo. Cannot continue."
    exit 1
fi

# Do we have a file with our version?
if [ ! -f $FILE_VERSION ]; then
    echo -ne "${QUESTION_FLAG} ${CYAN}Can't find version file (${FILE_VERSION}), create one?"

    read -r RESPONSE
    if [[ $RESPONSE =~ [yY](es)* ]] || [ "$RESPONSE" = "" ]; then
        echo "0.0.0" > $FILE_VERSION
    else
        exit 1
    fi
fi

# Do we have a file with our changes?
if [ ! -f $FILE_CHANGELOG ]; then
    echo -ne "${QUESTION_FLAG} ${CYAN}Can't find changelog file (${FILE_CHANGELOG}), create one?"

    read -r RESPONSE
    if [[ $RESPONSE =~ [yY](es)* ]] || [ "$RESPONSE" = "" ]; then
        echo "" > $FILE_CHANGELOG
    else
        exit 1
    fi
fi

# Continue to guess new value for our version
BASE_STRING=$(cat $FILE_VERSION)

if [ "$BASE_STRING" = "" ]; then
    BASE_STRING="0.0.0"
fi

BASE_LIST=($(echo $BASE_STRING | tr '.' ' '))
V_MAJOR=${BASE_LIST[0]}
V_MINOR=${BASE_LIST[1]}
V_PATCH=${BASE_LIST[2]}

echo -e "${NOTICE_FLAG} Current version: ${WHITE}$BASE_STRING"
echo -e "${NOTICE_FLAG} Latest commit hash: ${WHITE}$LATEST_HASH"

# We default to patch level bump
V_PATCH=$((V_PATCH + 1))


SUGGESTED_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
echo -ne "${QUESTION_FLAG} ${CYAN}Enter a version number [${WHITE}$SUGGESTED_VERSION${CYAN}]: "
read -r NEW_VERSION
if [ "$NEW_VERSION" = "" ]; then
    NEW_VERSION=$SUGGESTED_VERSION
fi
echo -e "${NOTICE_FLAG} Will set new version to be ${WHITE}$NEW_VERSION"
echo ""
echo -ne "${WARNING_FLAG} This is the last chance to bail out before anything has happened."
read -r

# Set up our release branch name
BRANCH_RELEASE=release-$NEW_VERSION

# create the release branch from the -develop branch
git checkout -b "$BRANCH_RELEASE" "$BRANCH_DEV"

# Set our new version to our version file
echo "$NEW_VERSION" > "$FILE_VERSION"

# Create our changelog
echo "## $NEW_VERSION ($NOW)" > tmpfile
git log --pretty=format:"  - %h %ad | %s%d [%an]" --date=short --no-merges "$BASE_STRING"...HEAD >> tmpfile
echo "" >> tmpfile
echo "[Full changelog]($PROJECT_URL/compare/$BASE_STRING...$NEW_VERSION)"
echo "" >> tmpfile
echo "" >> tmpfile
cat "$FILE_CHANGELOG" >> tmpfile
mv tmpfile $FILE_CHANGELOG

echo -e "$ADJUSTMENTS_MSG"
read -r
echo -e "$PUSHING_MSG"

# Make sure changes have been added
git add "$FILE_VERSION" "$FILE_CHANGELOG"

# Commit version number increment
git commit -am "Incrementing version number to $NEW_VERSION"

# Merge release branch with the new version number into master
git checkout "$BRANCH_MASTER"
git merge --no-ff "$BRANCH_RELEASE"

# Create tag for new version from -master
git tag -am "Tag version ${NEW_VERSION}." "$NEW_VERSION"

# Merge release branch with the new version number back into develop
git checkout "$BRANCH_DEV"
git merge --no-ff "$BRANCH_RELEASE"

# Remove release branch
git branch -d "$BRANCH_RELEASE"

echo -ne "${QUESTION_FLAG} ${CYAN}Push?"

read -r PUSH
if [[ $PUSH =~ [yY](es)* ]] || [ "$PUSH" = "" ]; then
    git push --all origin
fi

echo -e "${NOTICE_FLAG} Done!"
