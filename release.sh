#!/bin/bash

PRODUCTS="comoonics-bootimage comoonics-software"
[ -n "$2" ] && PRODUCTS="$2"
SERVER="bugzilla.atix.de"
[ -z "$BASE_PATH" ] && BASE_PATH="/atix/ATIX/applications"
[ -z "$COMMAND_PATH" ] && COMMAND_PATH="${BASE_PATH}/linux/bin"
[ -z "$XSL_PATH" ] && XSL_PATH="${BASE_PATH}/resources/xslt"
[ -z "$SAXON_PATH" ] && SAXON_PATH="${BASE_PATH}/resources/java/saxon9"  

PREBUILD_COMMAND="python ${COMMAND_PATH}/gen_releasenotes.py"
DB2HTML_COMMAND="db2x_xsltproc"

HEAD_XSL="${XSL_PATH}/bugzilla2plonehead-releasenotes.xsl"
BODY_XSL="${XSL_PATH}/bugzilla2docbook-releasenotes2.xsl"
HTML_XSL="/usr/share/sgml/docbook/xsl-stylesheets/xhtml/docbook.xsl"
[ -z "$TIMESTAMP" ] && TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
VERSION="noversion-${TIMESTAMP}"
[ -n "$1" ] && VERSION=$1

SAXON_CMD="java -jar ${SAXON_PATH}/saxon9.jar"

[ -z "$RELEASE_SITE_URL" ] && RELEASE_SITE_URL="http://atix-plone.cl.atix:9102/"
[ -z "$RELEASE_SITE_RELEASE_DIR" ] && RELEASE_SITE_RELEASE_DIR="opensharedroot/development"
[ -z "$MOUNT_POINT" ] && MOUNT_POINT="/media/webdav"

function error() {
	if [ $? -ne 0 ]; then
		echo "Error during $*" >&2
		exit 1
	fi
}

echo -e "Cleaning unspecified versions"
rm -f releasenotes/*noversion*
echo " [OK]"
tmpfile=/tmp/release-$$.xml
for product in $PRODUCTS; do
	echo "Prebuilding to releasenotes/${product}-${VERSION}"
	$PREBUILD_COMMAND --product=$product --server=$SERVER --onlyxml | sed -e 's/https/http/g' > $tmpfile
	$SAXON_CMD -t -s:$tmpfile -dtd:off -xsl:$BODY_XSL > releasenotes/${product}-${VERSION}.xml
	error "Prebuilding"
	rm -f $tmpfile

	echo "Generating formats"

	echo "Generating html..."
	$DB2HTML_COMMAND -s $HTML_XSL releasenotes/${product}-${VERSION}.xml >> releasenotes/${product}-${VERSION}.html
	error "Generating html"

	echo "Generating plone file releasenotes/${product}-${VERSION}"
	cat > releasenotes/${product}-${VERSION} <<EOF
id: ${product}-${VERSION}
title: Releasenotes of $product $VERSION
description: releasenotes description
Content-Type: text/html

EOF
	cat releasenotes/${product}-${VERSION}.html >> releasenotes/${product}-${VERSION}
	error "Generating plone files"
	
#	rm releasenotes/${product}-${VERSION}-plonehead.txt
	
	if [ "$VERSION" != "noversion-${TIMESTAMP}" ]; then
	
		mount | grep "${MOUNT_POINT}" >/dev/null
		if [ $? -ne 0 ]; then
			if [ -z "$username" ]; then
				echo "Enter username for $RELEASE_SITE_URL"
				read -p "username: " username
				echo
			fi
			if [ -z "$password" ]; then
				echo "Enter username for $RELEASE_SITE_URL"
				read -p "password: " -s password
				echo
			fi	
	
			echo -e "Mounting website ${RELEASE_SITE_URL}/${RELEASE_SITE_RELEASE_DIR} to ${MOUNT_POINT}:"
			wdfs -u $username -p "$password" ${RELEASE_SITE_URL}/${RELEASE_SITE_RELEASE_DIR} $MOUNT_POINT
			error "Mounting of website"
			echo " [OK]"
		fi
		echo -e "Copying files to $MOUNT_POINT/${product}/releasenotes/"
		cp releasenotes/${product}-${VERSION} $MOUNT_POINT/${product}/releasenotes/
		echo " [OK]"
		echo -e "Umouning ${MOUNT_POINT}"
		umount ${MOUNT_POINT}
		echo " [OK]"
	fi
done