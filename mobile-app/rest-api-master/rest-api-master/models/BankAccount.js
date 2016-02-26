/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Bank Account in the system
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

var BankAccountSchema = new Schema({
  accountId: { type: Number, required: true, ref: 'Account' },
  type: { type: String, required: true, enum: _.values(constants.bankAccountTypes) },
  balance: { type: String, required: true },
  name: { type: String, required: true },
  status: { type: String, required: true, enum: _.values(constants.bankAccountStatus) }
});

BankAccountSchema.plugin(autoIncrement.plugin, 'BankAccount');

// module exports
module.exports = {
  BankAccountSchema: BankAccountSchema
};