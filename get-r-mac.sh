#!/usr/bin/env bash
set -e

# Download and extract the main Mac Resources directory
# Requires xar and cpio, both installed in the Dockerfile
mkdir -p r-mac
curl -o r-mac/latest_r.pkg \
     https://cloud.r-project.org/bin/macosx/base/R-4.1.0.pkg

cd r-mac
xar -xf latest_r.pkg
rm -r R-app.pkg Resources tcltk.pkg texinfo.pkg Distribution latest_r.pkg #Remove the downloaded package file as well as all unneccessary files after extraction.
cat R-fw.pkg/Payload | gunzip -dc | cpio -i # Take the contents of R-fw.pkg/Payload directory, pass is to gunzip and then to cpio to extract it as a folder
mv R.framework/Versions/Current/Resources/* . # move all extracted files to the current place and then delete the R-fw.pkg and R.framework files
rm -r R-fw.pkg R.framework

# Patch the main R script
sed -i.bak '/^R_HOME_DIR=/d' bin/R
sed -i.bak 's;/Library/Frameworks/R.framework/Resources;${R_HOME};g' \
    bin/R
chmod +x bin/R
rm -f bin/R.bak

# Remove unneccessary files TODO: What else
rm -r doc tests
rm -r lib/*.dSYM
