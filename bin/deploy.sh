# /usr/bin/bash

# On Codeship files are stored in the the ~/clone directory
cd ~/clone/

# Prepare the gh-pages branch by checking it out into the same directory
# as its normally generated into by Hugo (i.e. public)
git clone `git config remote.origin.url` --branch gh-pages public

# Delete everything that was already in the directory so we can regenerate the site
# This will skip the CNAME file for custom hosting, and all dot files
find public -depth ! -name "public" ! -name "CNAME" ! -path "public/.*" -exec rm -r {} \;

# Get Hugo as a Debian package locked to a specific version
# specified in the ENV variables as a url like
# https://github.com/spf13/hugo/releases/download/v0.19/hugo_0.19-64bit.deb
#
# For the latest version, you could also just use
# go get -v github.com/spf13/hugo
wget "${HUGO_PACKAGE}" -O hugo.deb
dpkg -x hugo.deb hugo-build

# Output the Hugo version for nice logging,
# and then generate new static files in the normal public dir
./hugo-build/usr/bin/hugo version
./hugo-build/usr/bin/hugo

# Then we can add all the newly generated files
cd public
git add -A

# If no changes were made, then don't even bother trying to commit them
! $(git diff --cached --quiet --exit-code) || exit 0

# Commit, push to git, and then it will be live!
git config user.name "${CI_NAME}"
git config user.email "${CI_COMMITTER_EMAIL}"
git commit -m "Deploy to GitHub Pages by ${CI_NAME}: ${CI_COMMIT_ID} --skip-ci"
git push origin gh-pages
