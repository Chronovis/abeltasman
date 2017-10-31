from PIL import Image
import glob, os

for imagePath in glob.glob('../journaal/*.jpg'):
	im = Image.open(imagePath)
	width, height = im.size
	
	ratio = height/100
	width = round(width/ratio)

	im2 = im.resize((width, 100), Image.ANTIALIAS)

	baseName = os.path.basename(imagePath)
	im2.save('../journaal/thumbnails/'+baseName, 'JPEG', quality=85)
	print('Saved: '+baseName)