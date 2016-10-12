#!/usr/bin/env python

import urllib2
import getpass
import re
import json
import cookielib

APIVERSION = "1.4.0"
PAGESIZE = 100
TOTALITEMS = 99999
PAGENUMBER = 1
EXTRACTEDIMAGEFILENAMEARRAY = []
GALLERYCONFIG_REGEX = 'Y.SM.Page.galleryConfig = (.+?);'

print("hotshotsgallery.hotshotsphotobooth.co.nz Downloader")
print("by 0x776b7364")

### Get required inputs ###

input_url = raw_input('\nEnter hotshotsgallery URL: ')
input_password = getpass.getpass('Enter gallery password: ')

# hardcode url and password
#input_url = "http://hotshotsgallery.hotshotsphotobooth.co.nz/albumname/n-nodeid/"
#input_password = "PasswordHere"

url_splitted = re.split('/', input_url)

url_domain = url_splitted[2]

# simple url domain check
if url_domain != "hotshotsgallery.hotshotsphotobooth.co.nz":
	print("[!] Invalid URL!")
	exit(1)

node_id = re.split('-', url_splitted[4])[1]


### Login to application ###

opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookielib.CookieJar()))

login_url = "http://" + url_domain + "/services/api/json/" + APIVERSION + "/"
login_data = "NodeID=" + node_id + "&Password=" + input_password + "&Remember=0&method=rpc.node.auth"

print("[*] Performing POST login request ...")
#login_resp = urllib2.urlopen(url=login_url, data=login_data)
login_resp = opener.open(login_url, login_data)

login_resp_json = json.loads(login_resp.read())
has_access_value = login_resp_json.get("Node", []).get("HasAccess", [])
if not has_access_value:
	print("[!] Invalid password!")
	exit(1)
else:
	print("[*] Login successful!")


### Get albumkey and albumId values ###

print("[*] Performing GET album request ...")
album_resp = opener.open(input_url).read()
galleryconfig_output = re.search(GALLERYCONFIG_REGEX, album_resp)
if galleryconfig_output:
	galleryconfig_output_json = json.loads(galleryconfig_output.group(1))
	album_key = galleryconfig_output_json.get("galleryRequestData", []).get("albumKey", [])
	album_id = galleryconfig_output_json.get("galleryRequestData", []).get("albumId", [])
	# print album_key, album_id
else:
	print("[!] Error in album request.")
	exit(1)


### Get photo image URLs ###

while True:
	print("[*] Performing GET album photos request, page %s ..." % PAGENUMBER)
	photos_url = "http://" + url_domain + "/services/api/json/" + APIVERSION + "/?galleryType=album&albumId=" + str(album_id) + "&albumKey=" + album_key + "&nodeId=" + node_id + "&PageNumber=" + str(PAGENUMBER) + "&imageId=0&imageKey=&returnModelList=true&PageSize=" + str(PAGESIZE) + "&method=rpc.gallery.getalbum"
	photos_resp_json = json.loads(opener.open(photos_url).read())
	#print photos_resp_json

	TOTALITEMS = photos_resp_json.get("Pagination",[]).get("TotalItems", [])

	for image_record in photos_resp_json.get("Images", []):
		#print image_record.get("URLFilename")
		EXTRACTEDIMAGEFILENAMEARRAY.append(image_record.get("URLFilename"))

	if (PAGENUMBER*PAGESIZE >= TOTALITEMS):
		break

	PAGENUMBER += 1

print("[*] Completed image enumeration.")

### Download photos! ***

print("[*] Downloading photos ...")
for record in EXTRACTEDIMAGEFILENAMEARRAY:
	download_url = input_url + record + "/0/L/" + record + ".jpg"
	
	file_name = download_url.split('/')[-1]
	u = urllib2.urlopen(download_url)
	f = open(file_name, 'wb')
	meta = u.info()
	file_size = int(meta.getheaders("Content-Length")[0])
	print "Downloading: %s Bytes: %s" % (file_name, file_size)
	
	file_size_dl = 0
	block_sz = 8192
	while True:
	    buffer = u.read(block_sz)
	    if not buffer:
	        break
	
	    file_size_dl += len(buffer)
	    f.write(buffer)
	    status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl * 100. / file_size)
	    status = status + chr(8)*(len(status)+1)
	    print status,
	
	f.close()

print("[*] Done!")
