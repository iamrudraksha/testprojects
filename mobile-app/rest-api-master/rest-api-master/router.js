/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Router logic, this class will implement all the API routes login
 * i.e, mapping the routes to controller and add auth middleware if any route is secure.
 *
 * @author      TCSCODER
 * @version     1.0
 */

var express = require('express');
var accountController = require('./controllers/AccountController'),
  salesController = require('./controllers/SalesController'),
  serviceController = require('./controllers/ServiceController');

var auth = require('./middlewares/Auth');

module.exports = function() {
  var options = {
    caseSensitive: true
  };

  // Instantiate an isolated express Router instance
  var router = express.Router(options);
  // login
  router.post('/login', accountController.login);
  // accounts
  // /accounts/search will collide with accounts/:id, so using search/accounts
  router.get('/search/accounts', auth(), accountController.search);
  router.get('/accounts/:id/profile', auth(), accountController.getProfile);
  router.get('/accounts/:id/profile/relations', auth(), accountController.getRelations);
  router.get('/accounts/:id/bankAccounts', auth(), accountController.getBankAccounts);
  router.get('/accounts/:id/services', auth(), accountController.getAccountServices);
  router.get('/accounts/:id/sales', auth(), accountController.getSales);
  router.get('/accounts/:id/sales/:type/:saleId', auth(), accountController.getSingleSales);
  router.post('/services', auth(), serviceController.create);
  router.post('/sales', auth(), salesController.create);
  router.get('/services/types', auth(), serviceController.getServiceTypes);
  router.get('/sales/productsOfInterest', auth(), salesController.productsOfInterest);
  router.get('/accounts/:id', auth(), accountController.getSingle);
  router.get('/me', auth(), accountController.me);

  return router;
};