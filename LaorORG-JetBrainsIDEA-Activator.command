#!/bin/bash

# បង្ហាញ ASCII Art ពណ៌ខៀវ
echo -e "\e[36mJJJJJJ   EEEEEEE   TTTTTTTT  BBBBBBB    RRRRRR    AAAAAA    IIIIIIII  NNNN   NN   SSSSSS"
echo "   JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NNNNN  NN  SS"
echo "   JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NN NNN NN   SS"
echo "   JJ    EEEEE        TT     BBBBBBB    RRRRRR    AAAAAA       II     NN  NNNNN    SSSSS"
echo "   JJ    EE           TT     BB    BB   RR  RR    AA  AA       II     NN   NNNN         SS"
echo "JJ JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NN    NNN          SS"
echo -e " JJJJ    EEEEEEE      TT     BBBBBBB    RR   RR   AA  AA    IIIIIIII  NN    NNN    SSSSSS\e[0m"

echo -e "\nWelcome to JetBrains Activation Tool | LaorORG (macOS Native)"
echo -e "Warning: This script will forcibly re-activate all products!!!"

read -p "Custom license name [LaorORG]: " LICENSE_NAME
[ -z "$LICENSE_NAME" ] && LICENSE_NAME="LaorORG"

read -p "Custom expiration date [2099-12-31]: " EXPIRY_DATE
[ -z "$EXPIRY_DATE" ] && EXPIRY_DATE="2099-12-31"

echo -e "\nPlease make sure all JetBrains software is closed, press Enter to continue..."
read -r

echo -e "\nProcessing, please wait patiently..."

DIR_WORK="/tmp/.jb_run"
DIR_CONFIG="$DIR_WORK/config"
DIR_PLUGINS="$DIR_WORK/plugins"
rm -rf "$DIR_WORK"
mkdir -p "$DIR_CONFIG" "$DIR_PLUGINS"

URL_DOWNLOAD="https://ckey.run"
curl -sL "$URL_DOWNLOAD/ja-netfilter.jar" -o "$DIR_WORK/ja-netfilter.jar"
for conf in dns env native power url; do
    curl -sL "$URL_DOWNLOAD/config/$conf.conf" -o "$DIR_CONFIG/$conf.conf"
    curl -sL "$URL_DOWNLOAD/plugins/$conf.jar" -o "$DIR_PLUGINS/$conf.jar"
done
curl -sL "$URL_DOWNLOAD/plugins/hideme.jar" -o "$DIR_PLUGINS/hideme.jar"
curl -sL "$URL_DOWNLOAD/plugins/privacy.jar" -o "$DIR_PLUGINS/privacy.jar"

# ផ្លូវ Folder របស់ Mac
JB_DIR="$HOME/Library/Application Support/JetBrains"
if [ ! -d "$JB_DIR" ]; then
    echo -e "\e[31mDirectory not found: $JB_DIR!\e[0m"
    read -p "Press Enter to exit..."
    exit 1
fi

PRODUCTS=("idea" "clion" "phpstorm" "goland" "pycharm" "webstorm" "rider" "datagrip" "rubymine" "appcode" "dataspell" "rustrover")
PRODUCT_CODES=("II,PCWMP,PSI" "CL,PSI,PCWMP" "PS,PCWMP,PSI" "GO,PSI,PCWMP" "PC,PSI,PCWMP" "WS,PCWMP,PSI" "RD,PDB,PSI,PCWMP" "DB,PSI,PDB" "RM,PCWMP,PSI" "AC,PCWMP,PSI" "DS,PSI,PDB,PCWMP" "RR,PSI,PCWP")

for i in "${!PRODUCTS[@]}"; do
    PRD="${PRODUCTS[$i]}"
    CODE="${PRODUCT_CODES[$i]}"
    
    for d in "$JB_DIR"/*; do
        if [[ -d "$d" && "$(basename "$d" | tr '[:upper:]' '[:lower:]')" == *"$PRD"* ]]; then
            PRD_FULL_NAME=$(basename "$d")
            echo "Processing: $PRD_FULL_NAME"
            
            VM_FILE="$d/${PRD}.vmoptions"
            if [ -f "$VM_FILE" ]; then
                echo "Configuration file already exists, cleaning..."
                sed -i '' '/-javaagent:/d' "$VM_FILE"
                echo "Updating VMOptions: $VM_FILE"
                echo "-javaagent:$DIR_WORK/ja-netfilter.jar" >> "$VM_FILE"
            fi
            
            KEY_FILE="$d/$PRD.key"
            [ -f "$KEY_FILE" ] && rm -f "$KEY_FILE"
            
            JSON_BODY="{\"assigneeName\":\"$LICENSE_NAME\",\"expiryDate\":\"$EXPIRY_DATE\",\"licenseName\":\"$LICENSE_NAME\",\"productCode\":\"$CODE\"}"
            
            curl -s -X POST "https://ckey.run" \
                 -H "Content-Type: application/json" \
                 -d "$JSON_BODY" -o "$KEY_FILE"
                 
            PLUGIN_FILE="$d/disabled_plugins.txt"
            if [ -f "$PLUGIN_FILE" ]; then
                sed -i '' '/com.intellij.modules.ultimate/d' "$PLUGIN_FILE"
            fi
            echo -e "\e[32m$PRD_FULL_NAME activated successfully!\e[0m"
        fi
    done
done

echo -e "\n\e[32mAll items processed. If you need an activation code, please visit the website!\e[0m"
read -p "Press Enter to exit..."
