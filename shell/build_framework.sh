#!/bin/sh

BASEDIR="$(cd "$(dirname "$0")" && pwd)"

#指定时间格式
export LANG="zh_CN.UTF-8"

PROJECT="JJBase"
VERSION=$(date "+%y.%m.%d")  
#echo 'VERSION= '$VERSION
#echo 'BASEDIR= '$BASEDIR

CONFIGURATION="Release"

function buildFatFramework() {
	flags="OTHER_CFLAGS='-fembed-bitcode' -target $1 -configuration ${CONFIGURATION} build"

	xcodebuild -sdk iphoneos ${flags} || exit 1

	xcodebuild -sdk iphonesimulator ${flags} || exit 1

	cp -r "build/${CONFIGURATION}-iphoneos/$1.framework" "${BASEDIR}"

	lipo -create -output "${BASEDIR}/$1.framework/$1" "build/${CONFIGURATION}-iphonesimulator/$1.framework/$1" "build/${CONFIGURATION}-iphoneos/$1.framework/$1" || exit 1
}

function build() {
	buildFatFramework "$PROJECT"

	/usr/libexec/PlistBuddy -c "Set CFBundleShortVersionString $VERSION" "./$PROJECT.framework/info.plist"
	/usr/libexec/PlistBuddy -c "Set CFBundleVersion $VERSION" "./$PROJECT.framework/info.plist"

	zip -r "$PROJECT-$VERSION.zip" "./$PROJECT.framework"

	rm -r -f *.framework
}

build