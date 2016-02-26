/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Exposes method on top of Sales, ProductOfInterest collection in mongo db
 * @author      TCSCODER
 * @version     1.0
 */

var config = require('config');
var db = require('../datasource').getDb(config.MONGODB_URL, config.POOL_SIZE);
var SalesSchema = require('../models/Sales').SalesSchema,
  ProductOfInterestSchema = require('../models/ProductOfInterest').ProductOfInterestSchema,
  Sales = db.model('Sales', SalesSchema),
  ProductOfInterest = db.model('ProductOfInterest', ProductOfInterestSchema);

/**
 * Create a sales record in database
 * @param   {entity}      entity          entity to create
 * @param   {Function}    callback        callback function
 */
exports.create = function(entity, callback) {
  Sales.create(entity, callback);
};

/**
 * Get all the product of interests
 * @param   {Function}    callback        callback function
 */
exports.getProductsOfInterest = function(callback) {
  ProductOfInterest.find({}, callback);
};