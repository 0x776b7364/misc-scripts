#!/usr/bin/env python

import requests
from random import randint
from time import sleep
from bs4 import BeautifulSoup
from PIL import Image
from StringIO import StringIO

USER_AGENT = "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0"
INITIAL_URL = "https://www.my-site.com"

add_header = {
	'User-Agent': USER_AGENT,
	'DNT': '1',
	'Upgrade-Insecure-Requests': '1'
}

print("[I] Sending initial request ...")
initial_req = requests.head(INITIAL_URL, headers=add_header, allow_redirects=True)
redir_url = initial_req.url
print("[I] Obtained redirected URL: %s" % (redir_url))

for i in range(1,5):
	sleep(randint(2,5))
	curr = "%03d" % (i,)
	req = requests.get(redir_url + "keyword" + curr, headers=add_header)
	resp_parsed = BeautifulSoup(req.text, 'html.parser')
	image_element = resp_parsed.find("meta", property="og:image")
	if image_element:
		image_url = image_element["content"]
		print("[I] %s: Found. Saving image %s ..." % (curr, image_url))
		image_req = requests.get(image_url)
		image_obj = Image.open(StringIO(image_req.content))
		image_obj.save("keyword"+curr+".jpg")
	else:
		print("[E] %s: Not Found" % (curr))

print("[I] Script completed.")
