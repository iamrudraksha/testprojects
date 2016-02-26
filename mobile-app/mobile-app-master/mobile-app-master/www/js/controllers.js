angular.module('starter.controllers', [])

    .controller('bankCtrl', function ($scope, $timeout,constantService,$state) {
        //show splash screen
        $scope.splash = true;

        //hide splash screen
        $timeout(function(){
            $scope.splash = false;
        },constantService.splashDuration);

        $timeout(function(){
            //$state.go('intro');
        },200)

    })

    .controller('introCtrl', function ($scope,constantService,IntroSlider,$timeout) {
        //slider duration
        $scope.loadComplete = false;
        $scope.sliderDuration = constantService.sliderDuration;
        IntroSlider.query(function(data){
            $scope.introSlider = data;
            $timeout(function(){
                $scope.loadComplete = true;
            })
        });

    })

    .controller('loginCtrl', function ($scope,$state) {
        $scope.data = {
            username:{
                val:'',
                valid:true
            },
            password:{
                val:'',
                valid:true
            }
        };

        //login function
        $scope.login = function() {
            $scope.data.username.valid = $scope.data.username.val !== '';
            $scope.data.password.valid = $scope.data.password.val !== '';

            if($scope.data.username.valid && $scope.data.password.valid){
                $state.go('app.findCustomers')
            }

        }

    })

    .controller('appCtrl', function ($scope, LeftMenu,$state,$timeout,User) {
        $scope.leftMenu = LeftMenu.query();
        $scope.showSpeeh = false;
        $scope.showResults = false;
        $scope.showEdit = false;
        $scope.searchText = "John Doe";
        $scope.user = {};
        $scope.shouldBeOpen = true;

        var user = User.query(function(data){
            $scope.user = data[0];
        }, function(err){
            console.log('request failed');
        });

        //showSpeech
        $scope.openSpeech = function(){
            $scope.showSpeeh = true;
            $scope.showResults = false;
        };
        //hideSpeech
        $scope.hideSpeech = function(){
            $scope.showSpeeh = false;
            $scope.showEdit = false;
        };
        //showResults
        $scope.showResult = function(){
            $scope.showResults = true;
        };
        //editShow
        $scope.editShow = function(){
            $scope.showEdit = true;
        };
        //doSearch
        $scope.doSearch = function(){
            $scope.showSpeeh = false;
            document.getElementById("search-input").blur();
            $timeout(function(){
                $state.go('app.search');
            },100);
        };

        $scope.goBack = function(){
            history.back();
        }
    })

    .controller('findCustomersCtrl', function ($scope, RecentViews, $state) {
        $scope.recentView={};
        $scope.recentView.views = RecentViews.query();
        $scope.recentView.open = true;

        //toggleView
        $scope.toggleView = function(){
            $scope.recentView.open = !$scope.recentView.open;
        };
        //doSearch
        $scope.doSearch = function(){
            $state.go('app.search');
        };
        //openSpeach
        $scope.openSpeech = function(){
            $scope.$parent.openSpeech();
        };

    })

    .controller('searchCtrl', function ($scope, RecentViews, $state,$ionicPopover,SearchResults,$ionicPopup,$timeout) {
        $scope.recentView={};
        $scope.recentView.views = RecentViews.query();
        $scope.recentView.open = true;
        $scope.sortPopup = false;
        $scope.locaationPopup = false;
        $scope.searchResults=[];

        $scope.shouldShowDelete = false;
        $scope.shouldShowReorder = false;
        $scope.listCanSwipe = true;

        $scope.distance={
            volume:43
        };

        $scope.sortBy = {
            "by": [
                {
                    "name": "Name",
                    "checked": true
                }, {
                    "name": "Distance",
                    "checked": false
                }
            ],
            "option":[
                {
                    "name": "Ascending",
                    "checked": true
                }, {
                    "name": "Descending",
                    "checked": false
                }
            ],
            "include":[
                {
                    "name": "Commercial",
                    "checked": true
                }, {
                    "name": "Consumer",
                    "checked": true
                }
            ]
        };

        $scope.toggleView = function(){
            $scope.recentView.open = !$scope.recentView.open;
        };

        $scope.doSearch = function(){
            $state.go('app.search');
        };

        //popover
        $ionicPopover.fromTemplateUrl('templates/popup/sort-popover.html', {
            scope: $scope
        }).then(function(popover) {
            $scope.sortPopover = popover;
        });
        //popover
        $ionicPopover.fromTemplateUrl('templates/popup/location-popover.html', {
            scope: $scope
        }).then(function(popover) {
            $scope.locationPopover = popover;
        });

        //modal
        $scope.openEmailModal = function() {
            $ionicPopup.show({
                template: 'Would you like to email this user?',
                title: 'Email Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Email',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };

        $scope.openPhoneModal = function() {

            $ionicPopup.show({
                template: 'Would you like to call this user?',
                title: 'Phone Call Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Call',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };

        $scope.openSortPopover = function(event){
            $scope.sortPopup = true;
            $scope.sortPopover.show(event);
        };

        //openLocationPopover
        $scope.openLocationPopover = function(event){
            $scope.locaationPopup = true;
            $scope.locationPopover.show(event);
        };

        //closePopover
        $scope.closeLocationPopover = function() {
            $scope.locationPopover.hide();
        };

        // Execute action on hide popover
        $scope.$on('popover.hidden', function() {
            $scope.sortPopup = false;
            $scope.locaationPopup = false;
        });

        //toggleItem
        $scope.toggleItem = function(item,group){
            //item.checked !== item.checked
            angular.forEach($scope.sortBy[group],function(elem){
                if(item.name === elem.name ){
                    elem.checked = !elem.checked;
                }else if(group==='option'){
                    elem.checked = false;
                }
            });
        };

        //doRefresh
        $scope.doRefresh = function(){
            SearchResults.query(function(data){
                $scope.searchResults = data;
                $scope.$broadcast('scroll.refreshComplete');
            }, function(err){
                console.log('request failed');
            });

        };

        $scope.loadMore = function() {

            //get search results
            SearchResults.query(function(data){
                angular.forEach(data,function(item){
                    $scope.searchResults.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function(err){
                console.log('request failed');
            });
        };

        $scope.$on('$stateChangeSuccess', function() {
            $scope.loadMore();
        });

        $scope.onSwipeLeft = function(item){
            $timeout(function(){
                item;
            },100)
        }
    })

    .controller('profileCtrl', function ($scope, ChartData,$ionicPopup,Accounts,
                                         $ionicSlideBoxDelegate,profileSlideService,
                                         $ionicPopover,Servicing,$timeout,Referrals,Opportunity) {

        var pageTiltes = [
            "<div class='with-sub-header'>Profile<span>Page 1 of 4</span></div>",
            "<div class='with-sub-header'>Accounts<span>Page 2 of 4</span></div>",
            "<div class='with-sub-header'>Servicing<span>Page 3 of 4</span></div>",
            "<div class='with-sub-header'>Sales<span>Page 4 of 4</span></div>"];
        $scope.pageTitle = pageTiltes[profileSlideService.index];
        $scope.accounts =[];
        $scope.currentSlide = profileSlideService.index;

        $scope.servicing = {
            sortBy : {
                label:"Newest to Oldest",
                val: true
            },
            sortOptions:[
                {
                    label:"Newest to Oldest",
                    val: true
                },
                {
                    label:"Oldest to Newest",
                    val: false
                }
            ]

        };
        $scope.filter = [
            {
                "label":"Call Center Events",
                "val": false
            },
            {
                "label":"Contact Events",
                "val": false
            },
            {
                "label":"Note Events",
                "val": false
            },
            {
                "label":"Service Requests",
                "val": false
            }
        ];
        $scope.serviceData = [];
        $scope.referrals = [];
        $scope.opportunity = [];


        $scope.slideHasChanged = function(index){
            $scope.pageTitle = pageTiltes[index];
        };

        // Properties
        $scope.chartObject = {};

        ChartData.query(function(data){
            $scope.chartObject.data = data[0];
            $scope.chartObject.details = data[1];
            init();
        }, function(err){
            console.log('request failed');
        });

        function init() {
            $scope.chartObject.type = "LineChart";
            //$scope.chartObject.displayed = false;
            $scope.chartObject.options = {
                "colors": ['#419ca5', '#009900', '#CC0000', '#DD9900'],
                "defaultColors": ['#419ca5', '#009900', '#CC0000', '#DD9900'],
                "isStacked": "true",
                "fill": 20,
                "displayExactValues": true,
                "vAxis": {
                    "title": "Sales unit",
                    "gridlines": {
                        "count": 10,
                        color: '#c1c1c1'
                    }, viewWindow: {
                        max: 450,
                        min: 150
                    }
                },
                lineWidth: .75,
                pointSize: 9,
                "hAxis": {textPosition: 'none'},
                'chartArea': {'width': '100%', 'height': '100%'},
                tooltip: {
                    'isHtml': true,
                    'trigger': 'selection',
                    'text': 'value'
                },
                'legend': false
            }

            $scope.chartObject.view = {
                columns: [0, 1]
            };
        }

        //modal
        $scope.openEmailModal = function() {
            $ionicPopup.show({
                template: 'Would you like to email this user?',
                title: 'Email Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Email',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };
        $scope.openPhoneModal = function() {

            $ionicPopup.show({
                template: 'Would you like to call this user?',
                title: 'Phone Call Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Call',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };


        //doRefresh
        $scope.doRefresh = function(){
            console.log('refreshing');
            if($ionicSlideBoxDelegate.currentIndex()===1){
                Accounts.query(function(data){
                    $scope.accounts = data;
                    $scope.$broadcast('scroll.refreshComplete');
                }, function(err){
                    console.log('request failed');
                });
            }else if($ionicSlideBoxDelegate.currentIndex()===2){
                Servicing.query(function(data){
                    $scope.serviceData = data;
                    $scope.$broadcast('scroll.refreshComplete');
                }, function(err){
                    console.log('request failed');
                });
            }else if($ionicSlideBoxDelegate.currentIndex()===3){
                Referrals.query(function(data){
                    $scope.referrals = data;
                    $scope.$broadcast('scroll.refreshComplete');
                }, function(err){
                    console.log('request failed');
                });
            }

        };

        $scope.loadMoreAccounts = function() {
            Accounts.query(function (data) {
                angular.forEach(data, function (item) {
                    $scope.accounts.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function (err) {
                console.log('request failed');
            });
        };

        $scope.loadMoreService = function() {
            Servicing.query(function (data) {
                angular.forEach(data, function (item) {
                    $scope.serviceData.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function (err) {
                console.log('request failed');
            });
        };

        $scope.loadMoreReferrals = function() {
            Referrals.query(function (data) {
                angular.forEach(data, function (item) {
                    $scope.referrals.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function (err) {
                console.log('request failed');
            });
        };

        $scope.loadMoreOpportunity = function() {
            Referrals.query(function (data) {
                angular.forEach(data, function (item) {
                    $scope.opportunity.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function (err) {
                console.log('request failed');
            });
        };

        //popover
        $ionicPopover.fromTemplateUrl('templates/popup/servicing-sort-popover.html', {
            scope: $scope
        }).then(function(popover) {
            $scope.sortPopover = popover;
        });

        //popover
        $ionicPopover.fromTemplateUrl('templates/popup/servicing-filter-popover.html', {
            scope: $scope
        }).then(function(popover) {
            $scope.filterPopover = popover;
        });


        $scope.openSortPopover = function(event){
            $scope.sortPopover.show(event);
        };


        $scope.openFilterPopover = function(event){
            $scope.filterPopover.show(event);
        };

        //$scope.doRefresh
        $timeout(function(){$scope.doRefresh();},300);

        $scope.activeTab ='referral';

        //load referrals
        Referrals.query(function(data){
            $scope.referrals = data;
        }, function(err){
            console.log('request failed');
        });

        //load opportunity
        Opportunity.query(function(data){
            $scope.opportunity = data;
        }, function(err){
            console.log('request failed');
        });

    })

    .controller('createServiceCtrl', function ($scope, $ionicPopup) {

        //modal
        $scope.openEmailModal = function() {
            $ionicPopup.show({
                template: 'Would you like to email this user?',
                title: 'Email Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Email',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };
        $scope.openPhoneModal = function() {

            $ionicPopup.show({
                template: 'Would you like to call this user?',
                title: 'Phone Call Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Call',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };
        $scope.saveService = function() {

            $ionicPopup.show({
                template: '<span>Are you sure you want<br/> to create service request?</span>',
                title: 'Add Service Request',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Save',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };


    })

    .controller('createReferralCtrl', function ($scope, $ionicPopup) {

        //modal
        $scope.openEmailModal = function() {
            $ionicPopup.show({
                template: 'Would you like to email this user?',
                title: 'Email Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Email',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };
        $scope.openPhoneModal = function() {

            $ionicPopup.show({
                template: 'Would you like to call this user?',
                title: 'Phone Call Service',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Call',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };
        $scope.saveService = function() {

            $ionicPopup.show({
                template: '<span>Would you like to save <br/> a service request or referral?</span>',
                title: 'Add Referral',
                scope: $scope,
                buttons: [
                    {
                        text: 'Not Now' ,
                        type: 'button-dark'
                    },
                    {
                        text: 'Save',
                        type: 'button-positive inactive'
                    }
                ],
                cssClass: 'customPopup'
            });
        };

    })

    .controller('referralDetailsCtrl', function ($scope, ReferralDetails) {
        $scope.referralDetails={};
        //load opportunity
        ReferralDetails.query(function(data){
            $scope.referralDetails = data[0];
        }, function(err){
            console.log('request failed');
        });
    })

    .controller('historyCtrl', function ($scope, HistoryResultsToday, HistoryResultsWeek, HistoryResultsMonth, HistoryResultsAll,$timeout) {

        $scope.activeTab = 'today';
        $scope.historyToday = [];
        $scope.historyWeek = [];
        $scope.historyMonth = [];
        $scope.historyAll = [];

        $scope.shouldShowDelete = false;
        $scope.shouldShowReorder = false;
        $scope.listCanSwipe = true;


        //doRefresh
        $scope.doRefresh = function(){
            if($scope.activeTab === 'today'){
                HistoryResultsToday.query(function(data){
                    $scope.historyToday = data;
                    $scope.$broadcast('scroll.refreshComplete');
                }, function(err){
                    console.log('request failed');
                });
            }else if($scope.activeTab === 'week'){
                HistoryResultsWeek.query(function(data){
                    $scope.historyWeek = data;
                    $scope.$broadcast('scroll.refreshComplete');
                }, function(err){
                    console.log('request failed');
                });
            }else if($scope.activeTab === 'month'){
                HistoryResultsMonth.query(function(data){
                    $scope.historyMonth = data;
                    $scope.$broadcast('scroll.refreshComplete');
                }, function(err){
                    console.log('request failed');
                });
            }else if($scope.activeTab === 'all'){
                HistoryResultsAll.query(function(data){
                    $scope.historyAll = data;
                    $scope.$broadcast('scroll.refreshComplete');
                }, function(err){
                    console.log('request failed');
                });
            }

        };

        $scope.loadMoreToday = function() {

            //get search results
            HistoryResultsToday.query(function(data){
                angular.forEach(data,function(item){
                    $scope.historyToday.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function(err){
                console.log('request failed');
            });
        };

        $scope.loadMoreWeek = function() {

            //get search results
            HistoryResultsWeek.query(function(data){
                angular.forEach(data,function(item){
                    $scope.historyWeek.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function(err){
                console.log('request failed');
            });
        };

        $scope.loadMoreMonth = function() {

            //get search results
            HistoryResultsMonth.query(function(data){
                angular.forEach(data,function(item){
                    $scope.historyMonth.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function(err){
                console.log('request failed');
            });
        };

        $scope.loadMoreAll = function() {

            //get search results
            HistoryResultsAll.query(function(data){
                angular.forEach(data,function(item){
                    $scope.historyAll.push(item);
                });
                $scope.$broadcast('scroll.infiniteScrollComplete');
            }, function(err){
                console.log('request failed');
            });
        };

        $scope.changeTab = function(tab){
            $scope.activeTab = tab;
            $timeout(function(){
                $scope.doRefresh();
            },100)
        };

        $scope.doRefresh();

    });
