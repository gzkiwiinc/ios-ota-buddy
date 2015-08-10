
#!/bin/sh
#
# Copyright Kiwiinc Team 2015
# info@kiwiinc.net
#
# Please keep this comment, but copy and modify anything below as you want.
# source: https://github.com/gzkiwiinc/ios-ota-buddy
# fork from https://github.com/sveinungkb/ios-ota-buddy

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
    cd "/home/deploy/distribution" 
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

    DATE=`date +"%Y%m%d-%H%M%S"`
    OTA_PLIST=application-$DATE.plist
    IPA_NAME=$filename
    # URL="http://test.yongjia.fm/distribution/$IPA_NAME"
  
    # generate plist
    generatePlist "$IPA_NAME" "$OTA_PLIST"

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

generatePlist()
{
   IPA_NAME=$1
   OTA_PLIST=$2
   text=`sed -e "s/ipa_path/http:\/\/test.yongjia.fm\/distribution\/$IPA_NAME/" template.plist`
   echo $text > ./plist/$OTA_PLIST
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
    # OTA_PLIST=$0
    cd "/home/deploy/distribution"
    text=`sed -e "s/$1/$2/" index.html`
    echo $text > index.html
}

qsync()
{
    cd "/home/deploy/distribution/qiniu-devtools"
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
