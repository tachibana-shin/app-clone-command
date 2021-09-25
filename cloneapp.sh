#!/bin/bash

APP_ROOT="/var/containers/Bundle/Application"
APP_GROUP_DATA_ROOT="/var/mobile/Containers/Shared/AppGroup"
APP_DATA_ROOT="/var/mobile/Containers/Data/Application"

APP_NAME="$1"
NEW_APP_NAME="$2"
BUNDLE_ID=""

function defineAppPaths {
    # Loop folders in APP_GROUP_DATA_ROOT and APP_DATA_ROOT 
    # then locate MCMMetadataIdentifier in 
    # the .com.apple.mobile_container_manager.metadata plist file
    
    local metadata=".com.apple.mobile_container_manager.metadata.plist"
    for APP_FOLDER in $APP_GROUP_DATA_ROOT/*; do
        if [ -d ${APP_FOLDER} ]; then
            if [ -f "$APP_FOLDER/$metadata" ]; then
                local this_bundle_id=$(plutil -key MCMMetadataIdentifier "$APP_FOLDER/$metadata" 2> /dev/null)
                for id in "${GROUP_BUNDLE_ID[@]}" #loop all group bundles
                do
                    if [ "$id" == "$this_bundle_id" ] || [ "$BUNDLE_ID" == "$this_bundle_id" ] || [[ "$this_bundle_id" == *"$BUNDLE_ID" ]]; then
                        local fld=$(basename "$APP_FOLDER")
                        APP_GROUP_DATA_GUID+=("${fld}")
                    fi
                done
            fi
        fi
    done

    for APP_FOLDER in $APP_DATA_ROOT/*; do
        if [ -d ${APP_FOLDER} ]; then
            if [ -f "$APP_FOLDER/$metadata" ]; then
                local this_bundle_id=$(plutil -key MCMMetadataIdentifier "$APP_FOLDER/$metadata" 2> /dev/null)
                if [ "$DATA_BUNDLE_ID" == "$this_bundle_id" ] || [ "$BUNDLE_ID" == "$this_bundle_id" ]; then
                    APP_DATA_GUID=$(basename "$APP_FOLDER")
                fi
            fi
        fi
    done

    local items=${#APP_GROUP_DATA_GUID[@]}
    if [ $items -gt 0 ] && [[ -z "$APP_DATA_GUID" ]]; then
        echo "CANNOT FIND APP DATA"
        rm -f ${RUNNING}
        exit 1;
    fi
}

function cvDone () {
   echo -e "\e[1;32m ====== Tác giả là shin-chan ====== \e[0m"

   echo -e "\e[1;32m == Giấy phép MIT cho mọi hoạt động về myJS == \e[0m"

   echo -e "\e[1;31m Nếu xảy ra lỗi trong quá trình cài đặt vui lòng liên hệ thanhnguyennguyen1995@gmail.com \e[0m"
}

function existsApp () {
local ROOT_FOLDER
for ROOT_FOLDER in $APP_ROOT/*; do
  if [ -d ${ROOT_FOLDER} ]; then
local APP_FOLDER
     for APP_FOLDER in $ROOT_FOLDER/*; do
        if [[ "$APP_FOLDER" = *".app" && -f "$APP_FOLDER/Info.plist" ]]; then

if [ "$1" == "$(plutil -key CFBundleIdentifier "$APP_FOLDER/Info.plist" 2> /dev/null)" ]; then
    return 1
fi

          fi
      done
   fi
done

return 0
}


function cloneApp () {


local cloneAppPath
local arg="$1"
local INFO_ROOT

cloneAppPath="/var/mobile/CloneApp/Payload"

rm -rf "$cloneAppPath"
rm -rf "$cloneAppPath.ipa"
cp -a "$1" "$cloneAppPath"

#lọc bỏ file

for file in $cloneAppPath/*; do
   if [ ! -d "$file" ]; then
     rm -rf "$file"
   fi
done

for file in $cloneAppPath/.*; do
   if [ ! -d "$file" ]; then
     rm -rf "$file"
   fi
done

local BUNDLE_ID
local BUNDLE_ID_NEW
local NUMBER_VER_CLONE=0


for ROOT_FOLDER in $cloneAppPath/*; do
  if [ -d ${ROOT_FOLDER} ]; then
     if [[ "$ROOT_FOLDER" = *".app" ]]; then
        if [ -f "$ROOT_FOLDER/Info.plist" ]; then

INFO_ROOT="$ROOT_FOLDER/Info.plist"

BUNDLE_ID=$(plutil -key CFBundleIdentifier "$ROOT_FOLDER/Info.plist")

while true; do
  existsApp "CLONE$NUMBER_VER_CLONE.$BUNDLE_ID"
  if [[ $? == 0 ]]; then
     BUNDLE_ID_NEW="CLONE$NUMBER_VER_CLONE.$BUNDLE_ID"

     break
  fi
  NUMBER_VER_CLONE=`expr $NUMBER_VER_CLONE + 1`
done

plutil -key CFBundleIdentifier -string $BUNDLE_ID_NEW $INFO_ROOT

if [ -d "$ROOT_FOLDER/PlugIns" ]; then

   for PLUGIN in $ROOT_FOLDER/PlugIns/*; do
      if [ -d "$PLUGIN" ]; then
         if [[ "$PLUGIN" = *".appex" ]]; then
             if [ -f "$PLUGIN/Info.plist" ]; then

BUNDLE_ID=$(plutil -key CFBundleIdentifier "$PLUGIN/Info.plist")

plutil -key CFBundleIdentifier -string "CLONE$NUMBER_VER_CLONE.$BUNDLE_ID" "$PLUGIN/Info.plist"


             fi
         fi
      fi
   done
fi

        fi
     fi
  fi
done

local newname

if [ -n "$NEW_APP_NAME" ]; then
   plutil -key CFBundleDisplayName -string "$NEW_APP_NAME" $INFO_ROOT
else
   echo -e "\e[1;31m Tên ứng dụng = \e[0m" 

   read newname

   if [ -n "$newname" ]; then
      plutil -key CFBundleDisplayName -string "$newname" $INFO_ROOT
   fi
fi

pw=$(pwd)
cd $(dirname "$cloneAppPath")
zip -r "Payload.ipa" "Payload"
echo -e "\e[1;32m Đang cài đặt... \e[0m"
myinst Payload.ipa
rm -rf Payload
rm -rf Payload.ipa
cd $pw
echo -e "\e[1;32m Xong \e[0m"
cvDone
}


function setup () {
local stop=0
for ROOT_FOLDER in $APP_ROOT/*; do
  if [ -d ${ROOT_FOLDER} ]; then
     if [ $stop == 1 ]; then
         break
     fi
     for APP_FOLDER in $ROOT_FOLDER/*; do
        if [ -d "$APP_FOLDER" ]; then
            if [[ "$APP_FOLDER" = *".app" ]]; then
                if [ -f "$APP_FOLDER/Info.plist" ]; then

local this_name=$(plutil -key CFBundleIdentifier "$APP_FOLDER/Info.plist" 2> /dev/null)

if [ "$APP_NAME" == "$this_name" ]; then
    cloneApp "$ROOT_FOLDER"
    stop=1
    break
fi

local this_name=$(plutil -key CFBundleDisplayName "$APP_FOLDER/Info.plist" 2> /dev/null)

if [ "$APP_NAME" == "$this_name" ]; then
    cloneApp "$ROOT_FOLDER"
    stop=1
    break
fi
                            
local this_name=$(plutil -key CFBundleName "$APP_FOLDER/Info.plist" 2> /dev/null)

if [ "$APP_NAME" == "$this_name" ]; then
    cloneApp "$ROOT_FOLDER"
    stop=1
    break
fi
                fi
             fi
          fi
      done
   fi
done

if [ $stop == 0 ]; then
   echo -e "\e[0;31m Không tìm thấy ứng dụng \e[0m"
   cvDone
fi

}

setup

## hmm checking file Info.plist...

#changeIdent "$ROOT/Info.plist"

## check done

## checking PlugIns


exit 0
