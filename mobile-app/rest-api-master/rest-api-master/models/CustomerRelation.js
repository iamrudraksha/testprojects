/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Represent a Customer Relation in the system
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

var CustomerRelationSchema = new Schema({
  accountId: { type: Number, required: true, ref: 'Account' },
  conversations: { type: [Schema.Types.Mixed], required: true }
});

CustomerRelationSchema.plugin(autoIncrement.plugin, 'CustomerRelation');

// module exports
module.exports = {
  CustomerRelationSchema: CustomerRelationSchema
};