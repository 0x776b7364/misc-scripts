#!/bin/bash

# Tested on Fedora 24
# Requires xmllint and oscap

# References:
# - https://www.reddit.com/r/commandline/comments/1lsau2/bash_when_printing_an_array_only_the_last_item/

echo "[*] Checking dependencies ..."
ret=$(command -v xmllint)
if [ $? -ne 0 ]; then
	echo "[!] xmllint not found!"
	exit
fi
ret=$(command -v oscap)
if [ $? -ne 0 ]; then
	echo "[!] oscap not found!"
	exit
fi

echo "[*] Creating directories ..."
mkdir dl_folder
mkdir outputs

while read url; do
	echo "[*] Downloading $url ..."
	wget $url -q -P dl_folder
done <stig_zip_urls.txt

cd dl_folder
echo "[*] Unzipping files ..."
unzip -qq -o -j "*.zip"

echo "[*] Copying xml files ..."
cp *.xml ../outputs

cd ../outputs

rm -rf ../dl_folder

for filename in *.xml; do
	echo -e "\n[*] Processing $filename ..."
	profileID=$(xmllint --xpath "string(//*[local-name()='Benchmark']/@id)" $filename)
	echo "[*] Profile ID $profileID retrieved."
	cntProfiles=$(xmllint --xpath "count(//*[local-name()='Profile']/@id)" $filename)
	echo "[*] $cntProfiles profiles detected."
	for i in $(eval echo "{1..$cntProfiles}")
	do
		profileName=$(xmllint --xpath "string(//*[local-name()='Profile'][$i]/@id)" $filename)
		title=$(xmllint --xpath "//*[local-name()='Profile'][$i]/*[local-name()='title']/text()" $filename)
		echo "[*] Generating guide for profile $i - $profileName (\"$title\") ..."
		oscap xccdf generate guide --profile $profileName --output $profileID-$profileName.html $filename
	done	
done

echo -e "\n[*] Done!"

# to evaluate:
# oscap xccdf eval --profile $profilename [--results $resultoutputfile.xml] [--report $reportoutputfile.html] [--cpe /path/to/cpe.xml] /path/to/os-xccdf.xml
