angular.module('starter.services', ['ngResource'])

//load intro slider
.factory('IntroSlider', function ($resource) {
  return $resource('data/intro-slider.json');
})

//load left menu
.factory('LeftMenu', function ($resource) {
  return $resource('data/left-menu.json');
})
//load RecentViews
.factory('RecentViews', function ($resource) {
  return $resource('data/recent-views.json');
})
//load search results
.factory('SearchResults', function ($resource) {
  return $resource('data/search-results.json');
})

//load search results
.factory('User', function ($resource) {
  return $resource('data/user.json');
})

//load chart-data
.factory('ChartData', function ($resource) {
  return $resource('data/chart-data.json');
})

//load accounts
.factory('Accounts', function ($resource) {
  return $resource('data/accounts.json');
})

//load servicing
.factory('Servicing', function ($resource) {
  return $resource('data/servicing.json');
})

//load sales
.factory('Referrals', function ($resource) {
  return $resource('data/referrals.json');
})

//load opportunity
.factory('Opportunity', function ($resource) {
  return $resource('data/opportunity.json');
})

//load opportunity
.factory('ReferralDetails', function ($resource) {
  return $resource('http://54.208.218.30:4000/accounts/{id}/sales?type=opportunity');
})

//load HistoryResultsToday
.factory('HistoryResultsToday', function ($resource) {
  return $resource('data/history-today.json');
})

//load HistoryResultsToday
.factory('HistoryResultsWeek', function ($resource) {
  return $resource('data/history-week.json');
})

//load HistoryResultsToday
.factory('HistoryResultsMonth', function ($resource) {
  return $resource('data/history-month.json');
})

//load HistoryResultsToday
.factory('HistoryResultsAll', function ($resource) {
  return $resource('data/history-all.json');
});
