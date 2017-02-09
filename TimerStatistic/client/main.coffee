import angular from 'angular'
import angularMeteor from 'angular-meteor'
import {chart} from './chart.coffee'
import {Meteor} from 'meteor/meteor'

onReady = () =>
  angular.bootstrap document, [
    chart
    angularMeteor
  ]

angular.element document
    .ready onReady




Meteor._reload.onMigrate ()->[false]