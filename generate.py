import argparse
import sys

import googlemaps
from geopy.distance import distance
from gpxpy import parser as gpxpy_parser

gmap = googlemaps.Client(key='AIzaSyA-spyWeUEjIzyuW7qxiwLjmf-g60eeK2U')

parser = argparse.ArgumentParser()
parser.add_argument('gpx_filename', help='Path of the input GPX file.')
parser.add_argument('--elevation', help='Correct elevation using Google API.', default=False)

args = parser.parse_args()

with open(args.gpx_filename, 'r') as gpx_file:
    gpx_parser = gpxpy_parser.GPXParser(gpx_file)
    gpx_parser.parse()

points = []
for track in gpx_parser.gpx.tracks:
    for segment in track.segments:
        for point in segment.points:
            points.append(point)


data = []

acc_dist = 0
for idx, point in enumerate(points):
    if idx > 0:
        last_point = points[idx - 1]
        d = distance((last_point.latitude, last_point.longitude), (point.latitude, point.longitude))
        elev_diff = point.elevation - last_point.elevation
        grade = (elev_diff / d.meters) * 100

        data.append((acc_dist, point.elevation * 3.28084, grade))

        acc_dist += d.miles

# print data

            # query_cnt += 1
            # elevation = gmap.elevation()
            # print 'Point at ({0},{1}) -> {2}'.format(point.latitude, point.longitude, point.elevation)
