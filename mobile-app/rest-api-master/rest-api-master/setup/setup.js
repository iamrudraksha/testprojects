/**
 * Copyright(c) 2015, Topcoder Inc, All rights reserved.
 */
'use strict';

/**
 * Set up the application database and insert some dummy test data
 *
 * @author      TCSCODER
 * @version     1.0
 */
var config = require('config');
var db = require('../datasource').getDb(config.MONGODB_URL, config.POOL_SIZE);
var async = require('async');
var AccountSchema = require('../models/Account').AccountSchema,
  AddressSchema = require('../models/Address').AddressSchema,
  BalanceHistorySchema = require('../models/BalanceHistory').BalanceHistorySchema,
  BankAccountSchema = require('../models/BankAccount').BankAccountSchema,
  CustomerRelationSchema = require('../models/CustomerRelation').CustomerRelationSchema,
  ProductOfInterestSchema = require('../models/ProductOfInterest').ProductOfInterestSchema,
  ProfileSchema = require('../models/Profile').ProfileSchema,
  SalesSchema = require('../models/Sales').SalesSchema,
  ServiceSchema = require('../models/Service').ServiceSchema,
  ServiceTypeSchema = require('../models/ServiceType').ServiceTypeSchema,
  Account = db.model('Account', AccountSchema),
  Address = db.model('Address', AddressSchema),
  BalanceHistory = db.model('BalanceHistory', BalanceHistorySchema),
  BankAccount = db.model('BankAccount', BankAccountSchema),
  CustomerRelation = db.model('CustomerRelation', CustomerRelationSchema),
  ProductOfInterest = db.model('ProductOfInterest', ProductOfInterestSchema),
  Profile = db.model('Profile', ProfileSchema),
  Sales = db.model('Sales', SalesSchema),
  Service = db.model('Service', ServiceSchema),
  ServiceType = db.model('ServiceType', ServiceTypeSchema);

var data = require('./data');
var logger = require('../logger').getLogger();

var _insertAccount = function(entity, callback) {
  Account.create(entity, callback);
};

var _insertAddress = function(entity, callback) {
  Address.create(entity, callback);
};

var _insertBalanceHistory = function(entity, callback) {
  BalanceHistory.create(entity, callback);
};

var _insertBankAccount = function(entity, callback) {
  BankAccount.create(entity, callback);
};

var _insertCustomerRelation = function(entity, callback) {
  CustomerRelation.create(entity, callback);
};

var _insertProductOfInterest = function(entity, callback) {
  ProductOfInterest.create(entity, callback);
};

var _insertProfile = function(entity, callback) {
  Profile.create(entity, callback);
};

var _insertSales = function(entity, callback) {
  Sales.create(entity, callback);
};

var _insertService = function(entity, callback) {
  Service.create(entity, callback);
};

var _insertServiceType = function(entity, callback) {
  ServiceType.create(entity, callback);
};

async.waterfall([
  function(cb) {
    Account.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.accounts, _insertAccount, cb);
  },
  function(_ignore, cb) {
    Address.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.addresses, _insertAddress, cb);
  },
  function(_ignore, cb) {
    BalanceHistory.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.balanceHistories, _insertBalanceHistory, cb);
  },
  function(_ignore, cb) {
    BankAccount.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.bankAccounts, _insertBankAccount, cb);
  },
  function(_ignore, cb) {
    CustomerRelation.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.customerRelations, _insertCustomerRelation, cb);
  },
  function(_ignore, cb) {
    ProductOfInterest.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.productOfInterests, _insertProductOfInterest, cb);
  },
  function(_ignore, cb) {
    Profile.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.profiles, _insertProfile, cb);
  },
  function(_ignore, cb) {
    Sales.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.sales, _insertSales, cb);
  },
  function(_ignore, cb) {
    Service.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.services, _insertService, cb);
  },
  function(_ignore, cb) {
    ServiceType.remove({}, cb);
  },
  function(_ignore, cb) {
    async.map(data.serviceTypes, _insertServiceType, cb);
  }
], function(err) {
  if(err) {
    logger.error('Error inserting database sample data', err);
  } else {
    logger.info('All data inserted Successfully');
    process.exit(0);
  }
});