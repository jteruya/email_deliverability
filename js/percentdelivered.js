// Categorical X-Axis Highcharts Chart
// Parameters are ${CHART}, ${TITLE}, ${ALIAS}

$(document).ready(function() {

percent_delivered_options = {
  chart: {
    renderTo: 'percent_delivered',
    type: 'spline',
    zoomType: 'x',
    height: 350,
    borderWidth: 1
  },
  title: {
    text: 'Percentage Delivered'
  },
  tooltip: {
    formatter: function () {
    var s = '<b>' + Highcharts.dateFormat('%b %e, %Y', this.x) + '</b>: <br>Percent Delivered Rate - ' + this.y + '%';

    return s;
    }
  },
  legend: {
    align: 'right',
    verticalAlign: 'middle',
    layout: 'vertical'
  },
  xAxis: {
    title: {
      title: ''
    },
    type: 'datetime',
    dateTimeLabelFormats: {
      day: '%b %e' // I.e. Nov 1, Nov 2
    }
    // tickInterval: 24*3600*1000 // 1 day intervals on x-axis
  },
  yAxis: {
    title: {
      text: '% Delivered'
    },
    max: 100 
  },
  plotOptions: {
    series: {
      groupPadding: 0.1, // Spacing between x-axis categories
      marker: {
        enabled: true,
        radius: 2 // Size of markers
      }
    }
  },
  series: []
};


$.get('csv/percentemaileddelivered.csv', function(data) {
  var lines = data.split('\n')
  var linecnt = data.split('\n').length - 1;
  //console.error(linecnt)

  var columns = lines[0].split(',')
  //percent_delivered_options.xAxis.title.text = columns[0]
  $.each(lines, function(lineNo, line) {
    if (lineNo == linecnt) {
      dummy = 1;
    }    
    else if (lineNo > 0) {
      var items = line.split(',')
      var series = {
        name: '',
        data: []
      }
      series.name = items[0]
      $.each(items, function(itemNo, item) {
        if (itemNo > 0) {
          var year = parseInt(columns[itemNo].split('-')[0])
          var month = parseInt(columns[itemNo].split('-')[1]) - 1 // offset months in JS
          var day = parseInt(columns[itemNo].split('-')[2])
          var value = parseFloat(items[itemNo]) 
          series.data.push([Date.UTC(year,month,day),value])
        }
      })
      percent_delivered_options.series.push(series)
    }
  })

percent_delivered = new Highcharts.Chart(percent_delivered_options);

});

});

