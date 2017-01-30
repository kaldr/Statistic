import angular from 'angular'
import angularMeteor from 'angular-meteor'
import {chart} from './chart.coffee'


onReady = () =>
  angular.bootstrap document, [
    chart
    angularMeteor
  ]

angular.element document
    .ready onReady
