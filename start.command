#!/bin/sh
#
# Copyright Sveinung Kval Bakken 2012
# sveinung.bakken@gmail.com
#
# Please keep this comment, but copy and modify anything below as you want.
# source: https://github.com/sveinungkb/ios-ota-buddy

PLIST_BUDDY="/usr/libexec/PlistBuddy -c"

provisioning() 
{
	if [ -z "$2" ]; then
		unzip -p "$1" "**.mobileprovision"
	else
		unzip -p "$1" "**.mobileprovision" > $2
		echo $"Extracted the .mobileprovison in $1 to: $2"
	fi
}

urlencode()
{
	echo $1 | python -c 'import sys,urllib;print urllib.quote_plus(sys.stdin.read().strip())'
}

otaplist()
{
	#if [ -z "$2" ]; then
	#	echo "Missing URL parameter"
	#	printusage
	#	exit 1
	#elif [ -z "$3" ]; then
	#	echo "Missing output file parameter"
	#	printusage
	#	exit 1
	#else
	#	# Extract IPA-files
	#	APP_PLIST=temp.plist
	#	OTA_PLIST=$3
	#	unzip -p "$1" "**/Info.plist" > $APP_PLIST

	#	#Read contents
	#	BUNDLE_IDENTIFIER=$($PLIST_BUDDY "Print CFBundleIdentifier" $APP_PLIST)
	#	BUNDLE_NAME=$($PLIST_BUDDY "Print CFBundleDisplayName" $APP_PLIST)

	#	# Clean up
	#	rm $APP_PLIST
	#
	#	# Create .plist
	#	$PLIST_BUDDY "Add :items array" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:metadata dict" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:metadata:bundle-identifier string $BUNDLE_IDENTIFIER" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:metadata:title string $BUNDLE_NAME" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:metadata:kind string software" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:assets array" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:assets:0 dict" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:assets:0:kind string software-package" $OTA_PLIST
	#	$PLIST_BUDDY "Add :items:0:assets:0:url string $2" $OTA_PLIST
	#	
	#	echo "Created $OTA_PLIST with values:"
	#	echo "Bundle identifier: $BUNDLE_IDENTIFIER"
	#	echo "Title:             $BUNDLE_NAME"
	#	echo "URL to app:        $2"
	#fi
        # cd "/Users/nobody1/distribution"
        # cd "/Users/kiwiserver/Public/distribution"
        cd "/Volumes/“KIWI Server”的公共文件夹/distribution"
	
	file=`find ./plist . -name "*.plist" | xargs ls -lt | awk '{print $9}'`
        for i in $file
        do
            filename=$i
            break
        done
        filename=`basename $filename`
        OLD_OTA_PLIST=$filename

        rm -rf ./plist/*.plist
         
        file=`find -P . -name "*.ipa" | xargs ls -lt | awk '{print $9}'`
        for i in $file
        do
            filename=$i
            break
        done
        filename=`basename $filename`

    	APP_PLIST=temp.plist
        DATE=`date +"%Y%m%d-%H%M%S"`
		OTA_PLIST=application-$DATE.plist
        IPA_NAME=$filename
        URL="http://192.168.1.239:8080/$IPA_NAME"
		unzip -p "$IPA_NAME" "**/Info.plist" > $APP_PLIST

		#Read contents
		BUNDLE_IDENTIFIER=$($PLIST_BUDDY "Print CFBundleIdentifier" $APP_PLIST)
		BUNDLE_NAME=$($PLIST_BUDDY "Print CFBundleDisplayName" $APP_PLIST)

		# Clean up
		rm $APP_PLIST
	
		# Create .plist
		$PLIST_BUDDY "Add :items array" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata dict" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata:bundle-identifier string $BUNDLE_IDENTIFIER" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata:title string $BUNDLE_NAME" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata:kind string software" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets array" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets:0 dict" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets:0:kind string software-package" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets:0:url string $URL" $OTA_PLIST
		
        mv $OTA_PLIST ./plist/

		echo "Created $OTA_PLIST with values:"
		echo "Bundle identifier: $BUNDLE_IDENTIFIER"
		echo "Title:             $BUNDLE_NAME"
		echo "URL to app:        $URL"

        # sync
        qsync

	# refresh html
        refreshHtml "$OLD_OTA_PLIST" "$OTA_PLIST"
}

itms()
{
	if [ -z $1 ]; then
		echo "Missing URL to .plist"
		printusage
		exit 1
	else
		echo "It can be downloaded with this link:"
		echo "itms-services://?action=download-manifest&url=$(urlencode $1)"
		echo "Example HTML anchor:"
		echo "<a href=\"itms-services://?action=download-manifest&url=$(urlencode $1)\">Download my application</a>"
	fi
}

printusage()
{
	echo "Usage:"
	echo $"$0 provisioning: Will extract the embedded provisioning profile from your application.ipa"
	echo $" $0 provisioning file.ipa, will print the provisioning profile to STDOUT, pipe it where you want (can be used to download)"
	echo $" $0 provisioning file.ipa name.mobileprovision, will extract the provisioning profile to name.mobileprovision"
	echo ""
	echo $"$0 plist: Will generate the .plist required for OTA-distribution"
	echo $" $0 plist file.ipa http://domain.com/path/distribution/file.ipa application.plist"
	echo ""
	echo $"$0 itms: Will generate an itms-services link that can be used to download your application."
	echo $" $0 itms http://domain.com/path/distribution/application.plist"
	exit 1
}

getipa()
{
    file=`find -P . -name "*.ipa" | xargs ls -lt | awk '{print $9}'`
    for i in $file
    do
        echo $i
        break
    done
    #filename=`basename $file`
    #return filename
}

refreshHtml()
{
    cd "/Volumes/“KIWI Server”的公共文件夹/distribution"
    text=`sed "s/$1/$2/" index.html`
    echo $text > index.html
}

qsync()
{
    cd "/Volumes/“KIWI Server”的公共文件夹/distribution/qiniu-devtools"
    `./qrsync config.json`
}

#if [ -z "$2" ]; then
#printusage
#fi

case "$1" in
		provisioning)
			provisioning "$2" "$3"
			;;
		plist)
            echo "hello"
			otaplist "$2" "$3" "$4"
			;;
		itms)
			itms "$2"
			;;
		*)
			# printusage
            otaplist
			
esac
