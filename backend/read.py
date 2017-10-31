from bs4 import BeautifulSoup
import re, collections, json
from pprint import pprint
from pyproj import Proj, transform
from pymongo import MongoClient

inProj = Proj(init='epsg:4326')
outProj = Proj(init='epsg:3857')

soup = BeautifulSoup(open("abel.html"))

year = None
month = None
day = None
prevDate = None
prevPage = None
htmls = []
page = None
pages = []
p = 0

entries = []

def addToEntries(el):
	global prevPage
	global prevDate
	global page
	global pages
	global htmls

	def extractGeographicData():
		str = [htmlToString(page['html']) for page in pages]
		html = "".join(str)

		matchLat = re.search(r'latitude(.*?)(\d+)°(\s|<br>)(\d+)\'', html, re.I)
		matchLon = re.search(r'longitude(.*?)(\d+)°(\s|<br>)(\d+)\'', html, re.I)
		# matchLon = re.search(r'latitude(.*)longitude(.*)\'', html, re.I)

		# if prevDate == "1642-August-18":
		lat = None
		lon = None
		geo = {}
		if matchLon is not None:
			# print(matchLat.group(), 
			lonDegrees = matchLon.groups()[1]
			lonMinutes = matchLon.groups()[3]

			lonText = lonDegrees + "° " + lonMinutes + '\''
			lon = int(lonDegrees) + int(lonMinutes)/60
		if matchLat is not None:
			# print(matchLat.group(), 
			latDegrees = matchLat.groups()[1]
			latMinutes = matchLat.groups()[3]

			latText = latDegrees + "° " + latMinutes + '\''
			lat = int(latDegrees) + int(latMinutes)/60

		if lon is not None or lat is not None:
			geo['found-in-text'] = {}

			if lon is not None:
				geo['found-in-text']['longitude'] = lonText
				
			if lat is not None:
				geo['found-in-text']['latitude'] = latText

		if lon is not None and lat is not None:
			lon = lon - 18		
			lat = lat * -1
			
			geo['epsg-4326'] = {
				'type': "Point",
				'coordinates': [lon, lat]
			}
			try:
				geo['epsg-3857'] = transform(inProj, outProj, lon, lat)
			except:
				print(lon, lat)

		return geo

	def htmlToString(html):
		tostring = [str(htm) for htm in html]
		mystr = "".join(tostring)
		return mystr.replace("\n", "<br>")

	def htmlToPages(html):
		str = htmlToString(html)
		data = {
			'pageNumber': prevPage,
			'html': htmlToString(htmls)
		}
		pages.append(data)
	
	if year is not None and month is not None and day is not None:
		date = year + "-" + month + "-" + day

		if prevDate == date and prevPage == page:
			htmls.append(el)
		elif prevDate == date and prevPage != page:
			htmlToPages(htmls)
			del htmls[:]
			
			htmls.append(el)
		else:
			htmlToPages(htmls)

			data = {
				'date': prevDate,
				'pages': pages[:]
			}

			geo = extractGeographicData()
			if geo:
				data['geo'] = geo

			entries.append(data)
			del pages[:]
			
			del htmls[:]
			htmls.append(el)
			
			

		prevPage = page
		prevDate = date

		

for child in soup.children:
	if child.name:
		if child.name == 'p':
			# if not child.attrs and child.string[0] == '[':
			if child.b is not None and not child.b.attrs and child.b.string[0] == '[':
				# print(child.b.string)
				splitted = child.b.string.split(' ')
				month = splitted[0][1:]
				year = splitted[1][:-1]

			elif child.u is not None and child.string[0:11] == '{Page: Jnl.':
				nums = re.findall('\d+', child.u.string)
				page = nums[0]

			elif child.string is not None and child.string[0:8] == 'Item the':
				nums = re.findall('\d+', child.string)
				day = nums[0]

			else:
				addToEntries(child)

		else:
			addToEntries(child)
				
with open('../static/json/entries.json', 'w') as file:
	file.write(json.dumps(entries, file, indent=4))

client = MongoClient('mongodb://localhost:27017/')
db = client.chronovis
collection = db.abeltasman
collection.drop()
collection.insert(entries)