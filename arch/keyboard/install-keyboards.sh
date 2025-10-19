#!/bin/bash

sudo cp -f ./es_based /usr/share/X11/xkb/symbols/es_based
sudo rm -rf ~/.config/fcitx5/
cp -rf ./fcitx5/ ~/.config/
mkdir -p ~/.local/share/fcitx5/themes/catpuccin-blue/
cp -r ./theme/* ~/.local/share/fcitx5/themes/catpuccin-blue/

XML_FILE="/usr/share/X11/xkb/rules/evdev.xml"
LAYOUT_NAME="es_based"
LAYOUT_SHORT_DESC="es"
LAYOUT_DESC="Spanish (based)"
COUNTRY_CODE="ES"
LANGUAGE_CODE="spa"

# Check if the variant already exists to prevent duplicates
# This XPath looks for a variant with a configItem/name matching ours, inside the Spanish layout
if xmlstarlet sel -t -v "//layout[configItem/name='${LAYOUT_NAME}']/configItem/name" "$XML_FILE" 2>/dev/null | grep -q "${LAYOUT_NAME}"; then
    echo "Layout '${LAYOUT_NAME}' already exists in ${XML_FILE}. Skipping."
else
    echo "Adding layout '${LAYOUT_NAME}' to ${XML_FILE}..."
    # Use xmlstarlet to append the new variant to the Spanish layout's variantList
    sudo xmlstarlet ed --inplace --pf \
        --subnode "//layoutList" --type elem -n "layout" \
        --subnode "//layoutList/layout[last()]" --type elem -n "configItem" \
        --subnode "//layoutList/layout[last()]/configItem" --type elem -n "name" -v "${LAYOUT_NAME}" \
        --subnode "//layoutList/layout[last()]/configItem" --type elem -n "shortDescription" -v "${LAYOUT_SHORT_DESC}" \
        --subnode "//layoutList/layout[last()]/configItem" --type elem -n "description" -v "${LAYOUT_DESC}" \
        --subnode "//layoutList/layout[last()]/configItem" --type elem -n "countryList" \
        --subnode "//layoutList/layout[last()]/configItem/countryList" --type elem -n "iso3166Id" -v "${COUNTRY_CODE}" \
        --subnode "//layoutList/layout[last()]/configItem" --type elem -n "languageList" \
        --subnode "//layoutList/layout[last()]/configItem/languageList" --type elem -n "iso639Id" -v "${LANGUAGE_CODE}" \
        "$XML_FILE"

    if [ $? -eq 0 ]; then
        echo "Successfully added the layout."
    else
        echo "Error: xmlstarlet command failed."
    fi
fi
