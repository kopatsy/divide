import argparse
import sys

from jinja2 import FileSystemLoader, Environment
import googlemaps
from geopy.distance import distance
from gpxpy import parser as gpxpy_parser

gmap = googlemaps.Client(key='AIzaSyA-spyWeUEjIzyuW7qxiwLjmf-g60eeK2U')

parser = argparse.ArgumentParser()
parser.add_argument('gpx_filename', help='Path of the input GPX file.')
parser.add_argument('--elevation', help='Correct elevation using Google API.', default=False)

args = parser.parse_args()

GRADES = [
    (-sys.maxint, 2, (0, 255, 0)),  # Green.
    (2, 4, (255, 255, 0)),  # Yellow.
    (4, 6, (255, 128, 0)),  # Orange.
    (6, 8, (255, 0, 0)),  # Red.
    (8, 10, (153, 51, 255)),  # Purple.
    (10, sys.maxint, (0, 0, 0))  # Black.
]

with open(args.gpx_filename, 'r') as gpx_file:
    gpx_parser = gpxpy_parser.GPXParser(gpx_file)
    gpx_parser.parse()

points = []
for track in gpx_parser.gpx.tracks:
    for segment in track.segments:
        for point in segment.points:
            points.append(point)

def render_from_template(directory, template_name, **kwargs):
    loader = FileSystemLoader(directory)
    env = Environment(loader=loader)
    template = env.get_template(template_name)
    return template.render(**kwargs)

graphs = []
cur_graph = None

acc_dist = 0
cur_dist = 0
for idx, point in enumerate(points):
    if cur_graph is None:
        cur_graph = dict(
            from_mile=int(acc_dist / 100.0) * 100,
            data=[]
        )

    grade = 0
    if idx < len(points) - 1:
        next_point = points[idx + 1]
        d = distance((point.latitude, point.longitude), (next_point.latitude, next_point.longitude))
        elev_diff = next_point.elevation - point.elevation
        grade = (elev_diff / d.meters) * 100

    if idx > 0:
        last_point = points[idx - 1]
        d = distance((last_point.latitude, last_point.longitude), (point.latitude, point.longitude))
        acc_dist += d.miles
        cur_dist += d.miles

    for min_grade, max_grade, color in GRADES:
        if min_grade <= grade and grade <= max_grade:
            break

    cur_graph['data'].append(dict(
        distance=acc_dist,
        elevation=point.elevation * 3.28084,
        color=color
    ))

    if cur_dist >= 100:
        cur_graph['to_mile'] = int(acc_dist / 100.0) * 100
        graphs.append(cur_graph)
        cur_graph = None
        cur_dist = 0

print render_from_template('.', 'template.js', graphs=graphs)

