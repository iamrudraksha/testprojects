/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Profile in the system
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

var ProfileSchema = new Schema({
  totalAccountBalance: { type: String, required: true },
  accountId: { type: Number, required: true, ref: 'Account' },
  totalHistoryDuration: { type: String, required: true },
  balanceHistory: { type: [Schema.Types.Mixed], required: false },
  totalSavings: { type: String, required: true },
  totalChecking: { type: String, required: true },
  totalLoans: { type: String, required: true },
  totalCreditCard: { type: String, required: true }
});

ProfileSchema.plugin(autoIncrement.plugin, 'Profile');

// module exports
module.exports = {
  ProfileSchema: ProfileSchema
};