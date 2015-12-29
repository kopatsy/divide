<html>
    <body>
        <div id="container" style="width:100%; height:400px;"></div>
    </body>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
    <script src="http://code.highcharts.com/highcharts.js"></script>
    <script src="./multicolor_series.js"></script>
    <script>
        $(function () {
            var chart = new Highcharts.Chart({
                chart: {
                    renderTo: 'container',
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
                    }
                },
                title: {
                    style: {
                        'fontSize': '1em'
                    },
                    useHTML: true,
                    x: -27,
                    y: 8,
                    text: 'Tour Divide'
                },
                series: [{
                    type: 'coloredarea',
                    data: [
                        {% for item in data %}
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
</html>
