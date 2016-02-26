// Ionic Starter App

// angular.module is a global place for creating, registering and retrieving Angular modules
// 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
// the 2nd parameter is an array of 'requires'
// 'starter.services' is found in services.js
// 'starter.controllers' is found in controllers.js
angular.module('starter', ['ionic', 'starter.controllers', 'starter.services','googlechart','appFilters'])

    //constants
    .constant("constantService",{
        splashDuration: 30,
        sliderDuration: 10000,
    })

    .run(function ($ionicPlatform) {
        $ionicPlatform.ready(function () {
            // Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
            // for form inputs)
            if (window.cordova && window.cordova.plugins.Keyboard) {
                cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true);
            }
            if (window.StatusBar) {
                StatusBar.styleDefault();
            }
        });
    })

    .directive('ngEnter', function () {
        return function (scope, element, attrs) {
            element.bind("keydown keypress", function (event) {
                if(event.which === 13) {
                    scope.$apply(function (){
                        scope.$eval(attrs.ngEnter);
                    });

                    event.preventDefault();
                }
            });
        };
    })



    .factory('profileSlideService', function() {
        var service = {};
        service.index = 0;
        return service;
    })
    .directive('focusMe', function($timeout, $parse) {
        return {
            //scope: true,   // optionally create a child scope
            link: function(scope, element, attrs) {
                var model = $parse(attrs.focusMe);
                scope.$watch(model, function(value) {
                    if(value === true) {
                        $timeout(function() {
                            element[0].focus();
                        },100);
                    }
                });
            }
        };
    })

    .config(function ($stateProvider, $urlRouterProvider) {

        // Ionic uses AngularUI Router which uses the concept of states
        // Learn more here: https://github.com/angular-ui/ui-router
        // Set up the various states which the app can be in.
        // Each state's controller can be found in controllers.js
        $stateProvider

            // setup an abstract state for the tabs directive
            .state('intro', {
                url: '/intro',
                templateUrl: 'templates/intro.html',
                controller: 'introCtrl'
            })
            .state('login', {
                url: '/login',
                templateUrl: 'templates/login.html',
                controller: 'loginCtrl'
            })
            .state('app', {
                url: "/app",
                templateUrl: "templates/app.html",
                controller : "appCtrl"
            })
            .state('app.findCustomers', {
                url: "/findCustomers",
                views: {
                    'appContent' :{
                        templateUrl: "templates/findCustomers.html",
                        controller : "findCustomersCtrl"
                    }
                }
            })
            .state('app.search', {
                url: "/search",
                views: {
                    'appContent' :{
                        templateUrl: "templates/search.html",
                        controller : "searchCtrl"
                    }
                }
            })
            .state('app.profile', {
                url: "/profile",
                views: {
                    'appContent' :{
                        templateUrl: "templates/profile.html",
                        controller : "profileCtrl"
                    }
                }
            })
            .state('app.createService', {
                url: "/createService",
                views: {
                    'appContent' :{
                        templateUrl: "templates/createService.html",
                        controller : "createServiceCtrl"
                    }
                }
            })
            .state('app.createReferral', {
                url: "/createReferral",
                views: {
                    'appContent' :{
                        templateUrl: "templates/createReferral.html",
                        controller : "createReferralCtrl"
                    }
                }
            })
            .state('app.referralDetails', {
                url: "/referralDetails",
                views: {
                    'appContent' :{
                        templateUrl: "templates/referralDetails.html",
                        controller : "referralDetailsCtrl"
                    }
                }
            })
            .state('app.history', {
                url: "/history",
                views: {
                    'appContent' :{
                        templateUrl: "templates/history.html",
                        controller : "historyCtrl"
                    }
                }
            });

        // if none of the above states are matched, use this as the fallback
        $urlRouterProvider.otherwise('/intro');

    });
