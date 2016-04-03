<html>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="http://code.highcharts.com/highcharts.js"></script>
    <script src="./multicolor_series.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
    <body>
        {% for graph in graphs %}
            <div id="container{{graph.from_mile}}" style="width:100%; height:200px;"></div>
                <table style="width:100%" class="table table-condensed">
                    <tr>
                    {% for poi in graph.pois %}
                        {% if poi.details.places|length > 0 %}
                        <td>{{ poi.name }}</td>
                        {% endif %}
                    {% endfor %}
                    </tr>
                    <tr>
                    {% for poi in graph.pois %}
                        {% if poi.details.places|length > 0 %}
                        <td>
                            {% for place_name in poi.details.places %}
                                <p>{{ place_name }} - {{ poi.details.places[place_name]['address'] }} - {{ poi.details.places[place_name]['hours'] }} - {{ poi.details.places[place_name]['phone'] }}</p>
                            {% endfor %}
                        {% endif %}
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
                                            text: {% if poi.to_next %} "{{ poi.name }}<br>{{ poi.to_next }}<br>{{ poi.to_next_elev }}ft" {% else %} "{{ poi.name }}" {% endif %},
                                            useHTML: true,
                                            fontSize: "0.3em",
                                            rotation: 0,
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
