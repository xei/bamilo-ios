#!/bin/bash

cd Jumia/

wti pull
wti push

cd ..

touch credentials.git
auth="https://$GIT_USER:$GIT_PASS@github.com"
echo $auth > credentials.git

git config --local user.email "mobile-rocket-porto@gmail.com"
git config --local user.name "mobile-rocket-porto"
git config --local credential.helper 'store --file=credentials.git' 

git checkout -- JumiaTests/*.plist Jumia/*.plist
git add Jumia/ar.lproj/RIStrings.strings
git add Jumia/fa.lproj/RIStrings.strings
git add Jumia/fr.lproj/RIStrings.strings
git add Jumia/my.lproj/RIStrings.strings
git add Jumia/pt.lproj/RIStrings.strings
git add Jumia/ur.lproj/RIStrings.strings

git commit -m "Uploading new translations from wti"
git push origin HEAD:development 

