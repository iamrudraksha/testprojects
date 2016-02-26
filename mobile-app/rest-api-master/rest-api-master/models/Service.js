/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Service in the system
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

var ServiceSchema = new Schema({
  name: { type: String, required: true },
  serviceType: { type: String, required: true },
  accountId: { type: Number, required: true, ref: 'Account' },
  bankAccount: { type: Schema.Types.Mixed, required: false },
  details: { type: String, required: true },
  date: { type: Date, required: false },
  amount: { type: String, required: false }
});
ServiceSchema.plugin(autoIncrement.plugin, 'Service');
// module exports
module.exports = {
  ServiceSchema: ServiceSchema
};