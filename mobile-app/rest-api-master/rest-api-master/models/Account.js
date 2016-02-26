/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent an Account in the system
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

var AccountSchema = new Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true },
  phone: String,
  photoUrl: String,
  type: { type: String, required: true, enum: _.values(constants.accountTypes) },
  distance: String,
  address: { type: Schema.Types.Mixed, required: true },
  username: { type: String, required: true },
  password: { type: String, required: true }
});
AccountSchema.plugin(autoIncrement.plugin, 'Account');

// module exports
module.exports = {
  AccountSchema: AccountSchema
};