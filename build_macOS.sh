#!/bin/bash

set -o errexit -o nounset

# Hold on to current directory
project_dir=$(pwd)

# Output macOS version
sw_vers

# Update platform
echo "Updating platform..."
brew update

# Install p7zip for packaging
brew install p7zip

# Install npm appdmg if you want to create custom dmg files with it
# npm install -g appdmg

# Install Qt
echo "Installing Qt..."
cd /usr/local/
sudo wget https://github.com/adolby/qt-more-builds/releases/download/5.7/qt-opensource-5.7.0-macos-x86_64-clang.zip
sudo 7z x qt-opensource-5.7.0-macos-x86_64-clang.zip &>/dev/null
sudo chmod -R +x /usr/local/Qt-5.7.0/bin/

# Add Qt binaries to path
PATH=/usr/local/Qt-5.7.0/bin/:${PATH}

# Create temporary symlink for Xcode8 compatibility
cd /Applications/Xcode.app/Contents/Developer/usr/bin/
sudo ln -s xcodebuild xcrun

# Build your app
echo "Building LiriCalculator..."
cd ${project_dir}
mkdir -p ./appdir
git clone -b develop https://github.com/lirios/fluid
cd fluid
git submodule update --init
./scripts/fetch_icons.sh
mkdir build
cd build
qmake CONFIG+=use_qt_paths ..
make -j4
sudo make install
# sudo make INSTALL_ROOT=../../appdir install ; sudo chown -R $USER ../../appdir ; find ../../appdir/
cd ../../
mkdir build
cd build
qmake LIRI_INSTALL_PREFIX=/usr ..
make -j4
sudo make INSTALL_ROOT=../appdir install ; sudo chown -R $USER ../appdir ; find ../appdir/
cd ../
#wget -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage" 
#chmod a+x linuxdeployqt*.AppImage
#unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
#./linuxdeployqt*.AppImage ./appdir/usr/share/applications/*.desktop -bundle-non-qt-libs -qmldir=. -verbose=2
#  - rm ./appdir/io.liri.Calculator.png # Workaround for linuxedeloyqt bug
#  - ./linuxdeployqt*.AppImage ./appdir/usr/share/applications/*.desktop -appimage -qmldir=. -verbose=2
#  - find ./appdir -executable -type f -exec ldd {} \; | grep " => /usr" | cut -d " " -f 2-3 | sort | uniq
#  - curl --upload-file ./Liri_Calculator*.AppImage https://transfer.sh/Liri_Calculator-git.$(git rev-parse --short HEAD)-x86_64.AppImage
#qmake -config release
#make

# Build and run your tests here

# Package your app
echo "Packaging LiriCalculator..."
cd appdir
ls

# Remove build directories that you don't want to deploy
rm -rf moc
rm -rf obj
rm -rf qrc

echo "Creating dmg archive..."
macdeployqt LiriCalculator.app -qmldir=../../../../../src -dmg
mv LiriCalculator.dmg "LiriCalculator_${TAG_NAME}.dmg"

# You can use the appdmg command line app to create your dmg file if
# you want to use a custom background and icon arrangement. I'm still
# working on this for my apps, myself. If you want to do this, you'll
# remove the -dmg option above.
# appdmg json-path LiriCalculator_${TRAVIS_TAG}.dmg

# Copy other project files
cp "${project_dir}/README.md" "README.md"
cp "${project_dir}/LICENSE" "LICENSE"
cp "${project_dir}/Qt License" "Qt License"

echo "Packaging zip archive..."
7z a LiriCalculator_${TAG_NAME}_macos.zip "LiriCalculator_${TAG_NAME}.dmg" "README.md" "LICENSE" "Qt License"

echo "Done!"

exit 0