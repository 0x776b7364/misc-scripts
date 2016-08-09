#!/usr/bin/env python

# inspiration from http://raidersec.blogspot.com/2012/12/automated-open-source-intelligence.html

# By default, Windows uses codepage 850, which may cause problems when
# displaying data. To fix it, perform the following in the Windows shell:
# c:\> chcp 65001
# c:\> set PYTHONIOENCODING=utf-8

import requests  
import json  
import urllib

key = '<google_api_key>'	# Google API key
cx = '<google_custom_search_engine_id>' # Google custom search engine ID for 'nz.linkedin.com'
startidx = '0'

filter = '"company name"' # insert company name here; keep the double quotations

ofile = open('output.csv', "w")
ofile.write("Name,Title,Company,Location,Profile_URL\n")

while True:
	print "\n************************"
	print "filter = %s" % (filter)
	print "startidx = %s" % (startidx)
	print "************************\n"
	
	url = 'https://www.googleapis.com/customsearch/v1?key=' + key + '&cx=' + cx + '&q=' + urllib.quote('site:nz.linkedin.com intitle:" | Linkedin" ' + filter + ' -intitle:profiles -inurl:groups -inurl:company -inurl:title')
	if (startidx != '0'):
		url = url + '&start=' + startidx
	response = requests.get(url, verify=False)
	
	for item in response.json()['items']:
		print "======================================"
		hcard = ""
		try:
			hcard = item['pagemap']['hcard']
		except:
			pass
		affiliations = []  
		name = 'N/A'  
		photo_url = 'N/A'  
		position = 'N/A'  
		company = 'N/A'  
		try:
			location = item['pagemap']['person'][0]['location'] 
			profile_url = item['formattedUrl']  
		except:
			pass
		
		for card in hcard:  
			# If we are in our main contact info card  
			if 'title' in card:  
				if 'fn' in card: name = card['fn']  
				position = card['title'].split(' at ')[0]
				if (len(card['title'].split(' at '))>1):
					company = card['title'].split(' at ')[1]
				else:
					company = ""
		
		if (hcard):
			print 'Name: ' + name  
			print 'Position: ' + position  
			print 'Company: ' + company  
			print 'Location: ' + location  
			print 'Profile: ' + profile_url  

			# generate csv row
			row = "\"" + name.encode('utf-8') + "\",\"" + position.encode('utf-8') + "\",\"" + company.encode('utf-8') + "\",\"" + location.encode('utf-8') + "\",\"" + profile_url.encode('utf-8')+ "\"\n"
			ofile.write(row)
	
	nextpage = ""
	try:
		nextpage = response.json()['queries']['nextPage']
	except:
		pass
	
	if (nextpage):
		cont = raw_input('Press <ENTER> to continue or q to quit: ')
		if (cont == 'q'):
			ofile.close()
			break
		startidx = str(response.json()['queries']['nextPage'][0]['startIndex'])
	else:
		print "End of results."
		ofile.close()
		break
