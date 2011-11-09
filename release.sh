#!/bin/bash

TIMESTAMP=${TIMESTAMP:-$(date '+%Y%m%d-%H%M%S')}
VERSION="noversion-${TIMESTAMP}"
if [ -n "$1" ]; then
    VERSION=$1
    shift
fi
BASEPRODUCT="comoonics-enterprise-it-platform"
PRODUCTS="initrd+ng comoonics-software"
[ -n "$1" ] && PRODUCTS="$@"

SERVER="bugzilla.atix.de"
BASE_PATH=${BASE_PATH:-$(dirname $0)}
COMMAND_PATH=${COMMAND_PATH:-"${BASE_PATH}"}
XSL_PATH=${XSL_PATH:-"${BASE_PATH}/xslt"}
SAXON_PATH=${SAXON_PATH:-"~/atix/atix-scripts/resources/java/saxon9"}  

PREBUILD_COMMAND=${PREBUILD_COMMAND:-"python ${COMMAND_PATH}/gen_releasenotes.py"}
DB2HTML_COMMAND=${DB2HTML_COMMAND:-"db2x_xsltproc"}

HEAD_XSL=${HEAD_XSL:-"${XSL_PATH}/bugzilla2plonehead-releasenotes.xsl"}
BODY_XSL=${BODY_XSL:-"${XSL_PATH}/bugzilla2docbook-releasenotes2.xsl"}
HTML_XSL=${HTML_XSL:-"xslt/html.xsl"}
PRINT_XSL=${PRINT_XSL:-"xslt/print.xsl"}

FOP_CMD=${FOP_CMD:-fop}
SAXON_CMD=${SAXON_CMD:-saxonb-xslt}
#"java -jar ${SAXON_PATH}/saxon9.jar"

RELEASE_SITE_URL=${RELEASE_SITE_URL:-"http://atix-plone.cl.atix:9102/"}
RELEASE_SITE_RELEASE_DIR=${RELEASE_SITE_RELEASE_DIR:-"opensharedroot/development"}
MOUNT_POINT=${MOUNT_POINT:-"/media/webdav"}

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
echo "Prebuilding to releasenotes/${BASEPRODUCT}-${VERSION}"
productopts=""
for product in $PRODUCTS; do
    productopts="--product=$product $productopts"
done
$PREBUILD_COMMAND $productopts --server=$SERVER --onlyxml | sed -e 's/https/http/g' > $tmpfile
$SAXON_CMD -t -s:$tmpfile -dtd:off -xsl:$BODY_XSL productversion=$VERSION > releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.xml
error "Prebuilding"
rm -f $tmpfile

echo "Generating formats"

echo "Generating html..."
$DB2HTML_COMMAND --stylesheet $HTML_XSL releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.xml > releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.html
error "Generating html"

echo "Generating plone file releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}"
cat > releasenotes/releasenotes-${BASEPRODUCT}-${VERSION} <<EOF
id: releasenotes-${BASEPRODUCT}-${VERSION}
title: Releasenotes of $BASEPRODUCT $VERSION
description: releasenotes description
Content-Type: text/html

EOF
	cat releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.html >> releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}
	error "Generating plone files"

	
echo "Generating pdf file releasenotes/${BASEPRODUCT}-${VERSION}"
$DB2HTML_COMMAND --stylesheet $PRINT_XSL -o releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.fo releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.xml
$FOP_CMD -pdf releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.pdf -fo releasenotes/releasenotes-${BASEPRODUCT}-${VERSION}.fo
#	rm releasenotes/${product}-${VERSION}-plonehead.txt
	
#	if [ "$VERSION" != "noversion-${TIMESTAMP}" ]; then
#	
#		mount | grep "${MOUNT_POINT}" >/dev/null
#		if [ $? -ne 0 ]; then
#			if [ -z "$username" ]; then
#				echo "Enter username for $RELEASE_SITE_URL"
#				read -p "username: " username
#				echo
#			fi
#			if [ -z "$password" ]; then
#				echo "Enter username for $RELEASE_SITE_URL"
#				read -p "password: " -s password
#				echo
#			fi	
#	
#			echo -e "Mounting website ${RELEASE_SITE_URL}/${RELEASE_SITE_RELEASE_DIR} to ${MOUNT_POINT}:"
#			wdfs -u $username -p "$password" ${RELEASE_SITE_URL}/${RELEASE_SITE_RELEASE_DIR} $MOUNT_POINT
#			error "Mounting of website"
#			echo " [OK]"
#		fi
#		echo -e "Copying files to $MOUNT_POINT/${product}/releasenotes/"
#		cp releasenotes/${product}-${VERSION} $MOUNT_POINT/${product}/releasenotes/
#		echo " [OK]"
#		echo -e "Umouning ${MOUNT_POINT}"
#		umount ${MOUNT_POINT}
#		echo " [OK]"
#	fi