#!/usr/bin/env bash

# បង្ហាញ ASCII Art ពណ៌ខៀវ
echo -e "\e[36mJJJJJJ   EEEEEEE   TTTTTTTT  BBBBBBB    RRRRRR    AAAAAA    IIIIIIII  NNNN   NN   SSSSSS"
echo "   JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NNNNN  NN  SS"
echo "   JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NN NNN NN   SS"
echo "   JJ    EEEEE        TT     BBBBBBB    RRRRRR    AAAAAA       II     NN  NNNNN    SSSSS"
echo "   JJ    EE           TT     BB    BB   RR  RR    AA  AA       II     NN   NNNN         SS"
echo "JJ JJ    EE           TT     BB    BB   RR   RR   AA  AA       II     NN    NNN          SS"
echo -e " JJJJ    EEEEEEE      TT     BBBBBBB    RR   RR   AA  AA    IIIIIIII  NN    NNN    SSSSSS\e[0m"

echo -e "\n\e[37mWelcome to JetBrains Activation Tool | LaorORG\e[0m"
echo -e "\e[33mScript Date: 2026-1-28 (Native Bash Edition)\e[0m"
echo -e "\e[31mWarning: This script will forcibly re-activate all products!!!\e[0m"

# សួរព័ត៌មានអតិថិជន
read -p "Custom license name (Press Enter for default [LaorORG]): " LICENSE_NAME
[ -z "$LICENSE_NAME" ] && LICENSE_NAME="LaorORG"

read -p "Custom expiration date (Press Enter for default [2099-12-31]): " EXPIRY_DATE
[ -z "$EXPIRY_DATE" ] && EXPIRY_DATE="2099-12-31"

echo -e "\nProcessing, please wait patiently..."

# រៀបចំថតការងារ
DIR_WORK="/tmp/.jb_run"
DIR_CONFIG="$DIR_WORK/config"
DIR_PLUGINS="$DIR_WORK/plugins"
rm -rf "$DIR_WORK"
mkdir -p "$DIR_CONFIG" "$DIR_PLUGINS"

# ទាញយកឯកសារ ckey.run
URL_DOWNLOAD="https://ckey.run"
echo "Configuring ja-netfilter..."
curl -sL "$URL_DOWNLOAD/ja-netfilter.jar" -o "$DIR_WORK/ja-netfilter.jar"
for conf in dns env native power url; do
    curl -sL "$URL_DOWNLOAD/config/$conf.conf" -o "$DIR_CONFIG/$conf.conf"
    curl -sL "$URL_DOWNLOAD/plugins/$conf.jar" -o "$DIR_PLUGINS/$conf.jar"
done
curl -sL "$URL_DOWNLOAD/plugins/hideme.jar" -o "$DIR_PLUGINS/hideme.jar"
curl -sL "$URL_DOWNLOAD/plugins/privacy.jar" -o "$DIR_PLUGINS/privacy.jar"

# កំណត់ទីតាំងកម្មវិធី JetBrains លើ Linux
JB_DIR="$HOME/.config/JetBrains"
if [ ! -d "$JB_DIR" ]; then
    echo -e "\e[31mError: JetBrains directory not found at $JB_DIR\e[0m"
    exit 1
fi

# រាយឈ្មោះកម្មវិធីដែលចង់ Activate
PRODUCTS=("idea" "clion" "phpstorm" "goland" "pycharm" "webstorm" "rider" "datagrip" "rubymine" "appcode" "dataspell" "rustrover")
PRODUCT_CODES=("II,PCWMP,PSI" "CL,PSI,PCWMP" "PS,PCWMP,PSI" "GO,PSI,PCWMP" "PC,PSI,PCWMP" "WS,PCWMP,PSI" "RD,PDB,PSI,PCWMP" "DB,PSI,PDB" "RM,PCWMP,PSI" "AC,PCWMP,PSI" "DS,PSI,PDB,PCWMP" "RR,PSI,PCWP")

# ដំណើរការកែប្រែ VMOptions និងទាញយក Key
for i in "${!PRODUCTS[@]}"; do
    PRD="${PRODUCTS[$i]}"
    CODE="${PRODUCT_CODES[$i]}"
    
    # ស្វែងរក Folder របស់កម្មវិធីនីមួយៗ (ឧទាហរណ៍៖ IntelliJIdea2024.3)
    for d in "$JB_DIR"/*; do
        if [[ -d "$d" && "$(basename "$d" | tr '[:upper:]' '[:lower:]')" == *"$PRD"* ]]; then
            echo -e "\nProcessing: $(basename "$d")"
            
            # កែសម្រួលឯកសារ .vmoptions ក្នុង Folder Config
            VM_FILE="$d/${PRD}64.vmoptions"
            [ ! -f "$VM_FILE" ] && VM_FILE="$d/${PRD}.vmoptions"
            
            if [ -f "$VM_FILE" ]; then
                # លុប javaagent ចាស់ចោល
                sed -i '/-javaagent:/d' "$VM_FILE"
                # បញ្ចូល javaagent ថ្មី
                echo "-javaagent:$DIR_WORK/ja-netfilter.jar" >> "$VM_FILE"
            fi
            
            # ផ្ញើ POST Request ទៅកាន់ API ដើម្បីយក Key ដើរតួជំនួស PowerShell
            KEY_FILE="$d/$PRD.key"
            JSON_BODY="{\"assigneeName\":\"$LICENSE_NAME\",\"expiryDate\":\"$EXPIRY_DATE\",\"licenseName\":\"$LICENSE_NAME\",\"productCode\":\"$CODE\"}"
            
            curl -s -X POST "https://ckey.run" \
                 -H "Content-Type: application/json" \
                 -d "$JSON_BODY" -o "$KEY_FILE"
                 
            # សម្អាត disabled_plugins.txt
            PLUGIN_FILE="$d/disabled_plugins.txt"
            if [ -f "$PLUGIN_FILE" ]; then
                sed -i '/com.intellij.modules.ultimate/d' "$PLUGIN_FILE"
            fi
            
            echo -e "\e[32m$PRD activated successfully!\e[0m"
        fi
    done
done

echo -e "\n\e[32mAll items processed. Enjoy your software!\e[0m"
