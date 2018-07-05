Deg2Rad = (degrees) ->
	degrees * Math.PI / 180

Rad2Deg = (radians) ->
	radians * 180 / Math.PI

module.exports = (point1, point2) ->
	a1 = Deg2Rad(point1[1])
	a2 = Deg2Rad(point2[1])
	b1 = Deg2Rad(point1[0])
	b2 = Deg2Rad(point2[0])

	Bx = Math.cos(a2) * Math.cos(b2-b1)
	By = Math.cos(a2) * Math.sin(b2-b1)
	lat = Math.atan2(Math.sin(a1) + Math.sin(a2), Math.sqrt( (Math.cos(a1)+Bx)*(Math.cos(a1)+Bx) + By*By ) )
	lon = b1 + Math.atan2(By, Math.cos(a1) + Bx)

	[Rad2Deg(lon), Rad2Deg(lat)]