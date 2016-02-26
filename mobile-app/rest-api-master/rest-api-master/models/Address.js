/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Address in the system
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

var AddressSchema = new Schema({
  streetAddress: { type: String, required: true },
  city: { type: String, required: true },
  province: { type: String, required: true },
  postalCode: { type: String, required: true }
});

AddressSchema.plugin(autoIncrement.plugin, 'Address');

// module exports
module.exports = {
  AddressSchema: AddressSchema
};