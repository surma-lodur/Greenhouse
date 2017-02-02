
angular.module('apiService', ['ngResource']).
factory('Measurement', ['$resource', function($resource) {
  return $resource('/measurements', {}, {
    query: {  method: 'GET',  isArray: false }
  })
}]).factory('DateRange', ['$resource', function($resource) {
  return $resource('/date-range', {}, {
    query: {  method: 'GET',  isArray: false }
  })
}]);

var Greenhouse = angular.module('Greenhouse', ['chart.js', 'apiService']);

Greenhouse.directive('ngSlider', function () {
    return {
        restrict: 'A', //E = element, A = attribute, C = class, M = comment         
        //@ reads the attribute value, = provides two-way binding, & works with functions
        scope: {title: '@'},
        //DOM manipulation
        link: function ($scope, element, attrs) { 
          $(element).slider({
            //ticks: [0, 100, 200, 300, 400],
            //ticks_labels: ['$0', '$100', '$200', '$300', '$400'],
            ticks_snap_bounds: 30,
            range: true
          });
        } 
    }
}); 

Greenhouse.directive('ngDatePicker', function () {
    return {
        restrict: 'A', //E = element, A = attribute, C = class, M = comment         
        //@ reads the attribute value, = provides two-way binding, & works with functions
        //scope: {title: '@'},
        //DOM manipulation
        link: function ($scope, element, attrs) { 
        } 
    }
}); 

Greenhouse.controller("HistogramCtrl", function($scope, Measurement, DateRange) {
  $scope.histogram      = false;
  $scope.daysToWatch    = 7;
  $scope.locale         = 'de';
  $scope.dateFormatApi  = 'YYYY-MM-DDTHH:mm:ss.sssZ';

  $scope.startDate = moment(moment().subtract($scope.daysToWatch, 'days')).format('L');
  $scope.endDate   = moment().format('L');

  $scope.dateRange = DateRange.query({}, function() {
    console.log($scope.dateRange);
    console.log($scope.startDate);

    $scope.measurementData = Measurement.query({
        start_date: moment($scope.startDate).format($scope.dateFormatApi),
        end_date:   moment($scope.endDate).format($scope.dateFormatApi)
      }, function() {
      $scope.enableHistogram();
    });
  });

  $scope.measurementToChartData = function(query) {
    $scope.luxChart       = {series: 'Lux',       data: [[]]};
    $scope.drewpointChart = {series: 'Drewpoint', data: [[]]};
    $scope.humidityChart  = {series: 'Humidity',  data: [[]]};
    $scope.tempChart      = {series: 'Temp',      data: [[]]};
    $scope.soilChart      = {series: 'Soil',      data: [[]]};
    $scope.barChart       = {series: 'Bar',       data: [[]]};

    jQuery.each(query.measurements, function(index, measurement) {
      $scope.luxChart.data[0].push({
        x: measurement.created_at,
        y: measurement.lux
      });
      $scope.drewpointChart.data[0].push({
        x: measurement.created_at,
        y: measurement.drewpoint
      });
      $scope.humidityChart.data[0].push({
        x: measurement.created_at,
        y: measurement.humidity
      });
      $scope.tempChart.data[0].push({
        x: measurement.created_at,
        y: measurement.temp
      });
      $scope.soilChart.data[0].push({
        x: measurement.created_at,
        y: measurement.soil
      });
      $scope.barChart.data[0].push({
        x: measurement.created_at,
        y: measurement.bar
      });
    });

    return
  };

  $scope.enableHistogram = function() {
    $scope.measurementToChartData($scope.measurementData);
    $scope.onClick = function(points, evt) {
      console.log(points, evt);
    };
    $scope.luxDatasetOverride = [{
      yAxisID: 'y-axis-1',
        borderColor: '#e3a21a',
        pointBackgroundColor: "#ffc40d",
        pointBorderColor: "#e3a21a",
        backgroundColor: "rgba(255,196,13, 0.4)"
    }];
    $scope.tempDatasetOverride = [{
      yAxisID: 'y-axis-1',
        borderColor: '#b91d47',
        pointBackgroundColor: "#ee1111",
        pointBorderColor: "#b91d47",
        backgroundColor: "rgba(238,17,17, 0.4)"
    }];
    $scope.drewpointDatasetOverride = [{
      yAxisID: 'y-axis-1',
        borderColor: '#2b5797',
        pointBorderColor: "#2b5797",
        pointBackgroundColor: "#2d89ef",
        backgroundColor: "rgba(45,137,239, 0.4)"
    }];
    $scope.soilDatasetOverride = [{
      yAxisID: 'y-axis-1',
        borderColor: '#7e3878',
        pointBorderColor: "#7e3878",
        pointBackgroundColor: "rgb(159,0,167)",
        backgroundColor: "rgba(159,0,167, 0.4)"
    }];
    $scope.humidityDatasetOverride = [{
      yAxisID: 'y-axis-1',
        borderColor: '#00a300',
        pointBorderColor: "#00a300",
        pointBackgroundColor: "rgb(153,180,51)",
        backgroundColor: "rgba(153,180,51, 0.4)"
    }];
    $scope.barDatasetOverride = [{
      yAxisID: 'y-axis-1',
        borderColor: '#603cba',
        pointBorderColor: "#603cba",
        pointBackgroundColor: "rgb(126,56,120)",
        backgroundColor: "rgba(126,56,120, 0.4)"
    }];
    $scope.options = {
      scales: {
        xAxes: [{
          type: 'time',
          time: {
            displayFormats: {
              quarter: 'MMM YYYY'
            }
          }
        }],
        yAxes: [{
          id: 'y-axis-1',
          type: 'linear',
          display: true,
          position: 'left'
        }]
      }
    };
    $scope.histogram = true;
    return
  };

});
