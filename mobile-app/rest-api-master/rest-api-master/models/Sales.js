/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Sales in the system
 *
 * @author      TCSCODER
 * @version     1.0
 */
var mongoose = require('../datasource').getMongoose(),
  _ = require('lodash'),
  constants = require('../constants'),
  Schema = mongoose.Schema,
  config = require('config'),
  autoIncrement = require('mongoose-auto-increment');

var db = require('../datasource').getDb(config.MONGODB_URL, config.POOL_SIZE);
// initialize the auto intcrement module
autoIncrement.initialize(db);

var SalesSchema = new Schema({
  type: { type: String, required: true, enum: _.values(constants.salesTypes) },
  name: { type: String, required: true },
  accountId: { type: Number, required: true, ref: 'Account' },
  managerName: { type: String, required: false },
  methodOfContact: { type: String, required: true },
  productOfInterest: { type: String, required: true },
  fundLevel: { type: String, required: false },
  details: { type: String, required: false }
});

SalesSchema.plugin(autoIncrement.plugin, 'Sales');

// module exports
module.exports = {
  SalesSchema: SalesSchema
};