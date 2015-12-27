import sys

import gpxpy.parser as parser

with open(sys.argv[1], 'r') as gpx_file:
    gpx_parser = parser.GPXParser(gpx_file)
    gpx_parser.parse()

for track in gpx_parser.gpx.tracks:
    for segment in track.segments:
        for point in segment.points:
            print 'Point at ({0},{1}) -> {2}'.format(point.latitude, point.longitude, point.elevation)
