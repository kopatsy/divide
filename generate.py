import argparse
import json
import sys

from jinja2 import FileSystemLoader, Environment
from geopy.distance import distance
from gpxpy import parser as gpxpy_parser

parser = argparse.ArgumentParser()
parser.add_argument('gpx_filename', help='Path of the input GPX file.')
parser.add_argument('--html', help='Generage the HTML page.', action='store_true', default=False)

args = parser.parse_args()

with open('./services.json') as f:
    SERVICES = json.load(f)

with open(args.gpx_filename, 'r') as gpx_file:
    gpx_parser = gpxpy_parser.GPXParser(gpx_file)
    gpx_parser.parse()

# Read all the data points and populates them with additional information:
# {
#   "distance": "Distance from start",
#   "total_elevation": "Elevation from start",
#   "elevation": "Elevation of that point in feet",
#   "grade": "Grade from last point",   
# }
points = []
last_point = None
total_elevation = 0
total_distance = 0
for track in gpx_parser.gpx.tracks:
    for segment in track.segments:
        for point in segment.points:
            point_info = {
                'grade': 0,
                'elevation': point.elevation * 3.28084
            }

            if last_point is not None:
                dist_diff = distance((last_point.latitude, last_point.longitude), (point.latitude, point.longitude))
                total_distance += dist_diff.miles
                elevation_diff = point.elevation - last_point.elevation
                total_elevation += (elevation_diff if elevation_diff > 0 else 0)
                point_info['grade'] = (elevation_diff / dist_diff.meters) * 100

            point_info['distance'] = total_distance
            point_info['total_elevation'] = total_elevation

            for poi, poi_info in SERVICES.items():
                (dist_to_route, dist_from_start, _) = poi_info.get('location', (sys.maxint, -1, -1))
                dist_to_point = distance((point.latitude, point.longitude), poi_info['coordinates'])
                if dist_to_point < dist_to_route:
                    poi_info['location'] = (dist_to_point, total_distance, total_elevation)

            last_point = point

            points.append(point_info)

dist_to_poi = {}
for poi, poi_info in SERVICES.items():
    (dist_to_route, dist_from_start, _) = poi_info.get('location', (sys.maxint, -1, -1))
    if dist_to_route.miles > 1:
        print '%s: %.1f off route' % (poi, dist_to_route.miles)

    if dist_to_route.miles > 6: 
        print 'IGNORED'
        continue

    dist_to_poi[dist_from_start] = (poi, poi_info)

sorted_pois = sorted(SERVICES.items(), key=lambda e: e[1]['location'][1])  # Sorted by distance.

if args.html:
    def render_from_template(directory, template_name, **kwargs):
        loader = FileSystemLoader(directory)
        env = Environment(loader=loader)
        template = env.get_template(template_name)
        return template.render(**kwargs)


    GRADES = [
        (-sys.maxint, 2, (0, 255, 0)),  # Green.
        (2, 4, (255, 255, 0)),  # Yellow.
        (4, 6, (255, 128, 0)),  # Orange.
        (6, 8, (255, 0, 0)),  # Red.
        (8, 10, (153, 51, 255)),  # Purple.
        (10, sys.maxint, (0, 0, 0))  # Black.
    ]

    cur_graph = None
    graphs = []
    for point in points:
        if cur_graph is None:
            cur_graph = dict(
                from_mile=int(point['distance'] / 100.0) * 100,
                data=[],
                pois=[],
            )

        grade = point['grade']
        for min_grade, max_grade, color in GRADES:
            if min_grade <= grade and grade <= max_grade:
                break

        cur_graph['data'].append(dict(
            distance=point['distance'],
            elevation=point['elevation'],
            color=color
        ))

        if point['distance'] - cur_graph['from_mile'] >= 100:
            cur_graph['to_mile'] = int(point['distance'] / 100.0) * 100
            graphs.append(cur_graph)
            cur_graph = None

    cur_graph['to_mile'] = int(point['distance'])
    graphs.append(cur_graph)

    prev_entry = None
    for poi, poi_info in sorted_pois:
        (_, distance, acc_elevation) = poi_info['location']
        graph = graphs[int(distance / 100)]

        entry = dict(
            name=str(poi),
            distance=distance,
            details=poi_info,
            acc_elevation=acc_elevation,
            to_next=None,
            to_next_elev=None
        )

        if prev_entry is not None:
            prev_entry['to_next'] = int(distance - prev_entry['distance'])
            prev_entry['to_next_elev'] = int((acc_elevation - prev_entry['acc_elevation']) * 3.28084)

        graph['pois'].append(entry)
        prev_entry = entry

    with open('www/profile.html', 'w') as output:
        output.write(render_from_template('.', 'template.js', graphs=graphs))
else:
    pois = []
    for poi, poi_info in sorted_pois:
        poi_info = dict(poi_info)
        poi_info['distance'] = poi_info['location'][1]
        poi_info['acc_elevation'] = int(poi_info['location'][2])
        del poi_info['location']
        poi_info['name'] = poi
        pois.append(poi_info)

    payload = {
        'points': points,
        'pois': pois
    }
    
    with open('www/course.json', 'w') as output:
        json.dump(payload, output)


