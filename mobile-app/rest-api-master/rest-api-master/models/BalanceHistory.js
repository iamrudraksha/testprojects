/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Balance History in the system
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

var BalanceHistorySchema = new Schema({
  amount: { type: String, required: true },
  date: { type: Date, required: true }
});

BalanceHistorySchema.plugin(autoIncrement.plugin, 'BalanceHistory');

// module exports
module.exports = {
  BalanceHistorySchema: BalanceHistorySchema
};