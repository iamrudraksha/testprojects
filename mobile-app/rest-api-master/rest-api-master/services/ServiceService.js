/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Exposes method on top of Service, ServiceType collection in mongo db
 * @author      TCSCODER
 * @version     1.0
 */

var config = require('config');
var db = require('../datasource').getDb(config.MONGODB_URL, config.POOL_SIZE);
var ServiceSchema = require('../models/Service').ServiceSchema,
  ServiceTypeSchema = require('../models/ServiceType').ServiceTypeSchema,
  Service = db.model('Service', ServiceSchema),
  ServiceType = db.model('ServiceType', ServiceTypeSchema);

/**
 * Create a new service record in database
 * @param   {entity}      entity          entity to create
 * @param   {Function}    callback        callback function
 */
exports.create = function(entity, callback) {
  Service.create(entity, callback);
};

/**
 * Get all the product of interests
 * @param   {Function}    callback        callback function
 */
exports.getServiceTypes = function(callback) {
  ServiceType.find({}, callback);
};