<html>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="http://code.highcharts.com/highcharts.js"></script>
    <script src="./multicolor_series.js"></script>
    <body>
        {% for graph in graphs %}
            <div id="container{{graph.from_mile}}" style="width:100%; height:400px;"></div>
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
                                        width: 2,
                                        color: 'red',
                                        label: {
                                           text: "{{ poi.name }}",
                                           rotation: 0,
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
                            data: [
                                {% for item in graph.data %}
                                    {
                                        x: {{ item.distance }},
                                        y: {{ item.elevation }},
                                        segmentColor: 'rgba({{ item.color[0] }}, {{ item.color[1] }}, {{ item.color[2] }}, 0.9)'
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
