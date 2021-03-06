#!/bin/sh

set -e
set -x

echo 'Setting up the docs script...'

doxygen doxygen.conf

ls -lah docs/

git clone -b gh-pages https://git@$GH_REPO_REF temp

cd temp

git config --global push.default simple
git config user.name "Travis CI"
git config user.email "travis@travis-ci.org"
rm -rf *
echo "" > .nojekyll

cd ../

mv docs/html/* temp/


cd temp

if [ -n "$(git status --porcelain)" ] && [ -f "index.html" ]; then
    echo 'Uploading documentation to the gh-pages branch...'
    git add --all
    git commit -m "Deploy code docs to GitHub Pages Travis build: ${TRAVIS_BUILD_NUMBER}" -m "Commit: ${TRAVIS_COMMIT}"
    git push --force "https://${GH_REPO_TOKEN}@${GH_REPO_REF}" > /dev/null 2>&1
else
    echo '' >&2
    echo 'Warning: No documentation (html) files have been found!' >&2
    echo 'Warning: Not going to push the documentation to GitHub!' >&2
    exit 1
fi
