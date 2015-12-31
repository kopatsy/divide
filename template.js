<html>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="http://code.highcharts.com/highcharts.js"></script>
    <script src="./multicolor_series.js"></script>
    <body>
        {% for graph in graphs %}
            <div id="container{{graph.from_mile}}" style="width:100%; height:400px;"></div>
                <table style="width:100%">
                <tr>
                {% for poi in graph.pois %}
                    <td>{{ poi.name }}</td>
                {% endfor %}
                </tr>
                <tr>
                {% for poi in graph.pois %}
                    <td>
                    <ul>
                    {% for place_name in poi.details.places %}
                        <li>{{ place_name }} - {{ poi.details.places[place_name]['address'] }} - {{ poi.details.places[place_name]['hours'] }} - {{ poi.details.places[place_name]['phone'] }}</li>
                    {% endfor %}
                    </ul>
                    </td>
                {% endfor %}
                </tr>
                </table>
            <script>
                $(function () {
                    var chart = new Highcharts.Chart({
                        chart: {
                            renderTo: 'container{{graph.from_mile}}',
                            type: 'coloredarea',
                            zoomType: 'xy',
                            borderWidth: 5,
                            borderColor: '#e8eaeb',
                            borderRadius: 0,
                            backgroundColor: '#f7f7f7'
                        },
                        legend: {
                            enabled: false
                        },
                        yAxis: {
                            title: {
                                text: 'Elevation (feet)'
                            }
                        },
                        xAxis: {
                            title: {
                                text: 'Distance (miles)'
                            },
                            plotLines: [
                                {% for poi in graph.pois %}
                                    {
                                        value: {{ poi.distance }},
                                        width: 3,
                                        color: {% if poi.details.services == 'all' %} 'red' {% else %} 'black' {% endif %},
                                        label: {
                                            text: "{{ poi.name }} ({{ poi.to_next }})",
                                            fontSize: "1em",
                                            rotation: 90,
                                            {% if poi.details.services == 'all' %}
                                            style: {
                                                fontWeight: 'bold'
                                            }
                                            {% endif %} 
                                        }
                                    },
                                {% endfor %}
                            ]
                        },
                        title: {
                            style: {
                                'fontSize': '1em'
                            },
                            useHTML: true,
                            x: -27,
                            y: 8,
                            text: 'Mile {{graph.from_mile}} to {{graph.to_mile}}'
                        },
                        series: [{
                            type: 'coloredarea',
                            name: 'route',
                            data: [
                                {% for item in graph.data %}
                                    {
                                        x: {{ item.distance }},
                                        y: {{ item.elevation }},
                                        segmentColor: 'rgba({{ item.color[0] }}, {{ item.color[1] }}, {{ item.color[2] }}, 0.5)'
                                    },
                                {% endfor %}
                            ]
                        }]
                    });
                });
            </script>
        {% endfor %}
    </body>
</html>
