/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Service Type entity in the system
 *
 * @author      TCSCODER
 * @version     1.0
 */
var mongoose = require('../datasource').getMongoose(),
  Schema = mongoose.Schema,
  config = require('config'),
  autoIncrement = require('mongoose-auto-increment');

var db = require('../datasource').getDb(config.MONGODB_URL, config.POOL_SIZE);
// initialize the auto intcrement module
autoIncrement.initialize(db);

var ServiceTypeSchema = new Schema({
  display: { type: String, required: true }
});

ServiceTypeSchema.plugin(autoIncrement.plugin, 'ServiceType');

// module exports
module.exports = {
  ServiceTypeSchema: ServiceTypeSchema
};