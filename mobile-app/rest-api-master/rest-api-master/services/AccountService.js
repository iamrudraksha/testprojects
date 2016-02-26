/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Exposes method on top of Account collection in mongo db
 * @author      TCSCODER
 * @version     1.0
 */

var errors = require('common-errors'),
  config = require('config'),
  moment = require('moment'),
  _ = require('lodash'),
  bcrypt = require('bcryptjs'),
  config = require('config'),
  jwt = require('jwt-simple'),
  httpStatus = require('http-status'),
  constants = require('../constants');

var db = require('../datasource').getDb(config.MONGODB_URL, config.POOL_SIZE);
var async = require('async');
var AccountSchema = require('../models/Account').AccountSchema,
  ProfileSchema = require('../models/Profile').ProfileSchema,
  BankAccountSchema = require('../models/BankAccount').BankAccountSchema,
  CustomerRelationSchema = require('../models/CustomerRelation').CustomerRelationSchema,
  CustomerRelation = db.model('CustomerRelation', CustomerRelationSchema),
  ServiceSchema = require('../models/Service').ServiceSchema,
  SalesSchema = require('../models/Sales').SalesSchema,
  Service = db.model('Service', ServiceSchema),
  Sales = db.model('Sales', SalesSchema),
  Profile = db.model('Profile', ProfileSchema),
  BankAccount = db.model('BankAccount', BankAccountSchema),
  Account = db.model('Account', AccountSchema);

/**
 * Get a single Account
 * @param   {UUID}        id              id of the account to fetch
 * @param   {Function}    callback        callback function
 */
exports.getSingle = function(id, callback) {
  Account.findById(id, function(err, found) {
    if(err) {
      return callback(err);
    } else if(!found) {
      return callback(new errors.NotFoundError('Account doesn\'t exist with given ID'));
    }
    callback(null, found);
  });
};

/**
 * Perform authentication.
 * @param  {Object}       credentials         credentials for login, must have username and password
 * @param  {Function}     callback            callback function
 */
exports.login = function(credentials, callback) {
  async.waterfall([
    function(cb) {
      Account.findOne({ username: credentials.username }, cb);
    },
    function(user, cb) {
      if(!user) {
        return cb(new errors.NotFoundError('Account not found for given username'));
      }
      cb(null, user);
    },
    function(user, cb) {
      var valid = bcrypt.compareSync(credentials.password, user.password);
      if(valid) {
        var millis = moment().valueOf() + config.TOKEN_EXPIRATION_IN_MILLIS;
        user.password = undefined; 
        var token = jwt.encode({
          expiration: millis,
          userId: user._id
        }, config.JWT_SECRET);
        cb(null, {token: token, user: user});
      } else {
        cb(new errors.HttpStatusError(httpStatus.UNAUTHORIZED, 'Invalid username or password'));
      }
    }
  ], callback);
};

/**
 * Get the previous timestamp value, to filter out the balance history
 * @param   {String}      duration        the duration, valid values are 1_m, 3_m, 6_m, 1_y, 2_y
 * @param   {Function}    callback        callback function
 */
var _getPrevious = function(duration) {
  var previous;
  switch(duration) {
    case '1_m':
      previous = moment().subtract(1, 'month').valueOf();
      break;
    case '3_m':
      previous = moment().subtract(3, 'month').valueOf();
      break;
    case '6_m':
      previous = moment().subtract(6, 'month').valueOf();
      break;
    case '1_y':
      previous = moment().subtract(1, 'year').valueOf();
      break;
    case '2_y':
      previous = moment().subtract(2, 'year').valueOf();
      break;
  }
  return previous;
};

/**
 * Get a user profile
 * @param   {UUID}        id              id of the account to get user profile for
 * @param   {Function}    callback        callback function
 */
exports.getProfile = function(id, duration, callback) {
  async.waterfall([
    function(cb) {
      var where = {
        accountId: id
      };
      Profile.findOne(where, function(err, found) {
        if(err) {
          return cb(err);
        } else if(!found) {
          return cb(new errors.NotFoundError('Profile doesn\'t exist with given account ID'));
        } else {
          if(duration) {
            var transformed = found.toObject();
            delete transformed.balanceHistory;
            transformed.balanceHistory = [];
            var now = moment().valueOf();
            var previous = _getPrevious(duration);
            _.forEach(found.balanceHistory, function(history) {
              var historyDate = moment(history.date);
              if(historyDate.isAfter(previous) && historyDate.isBefore(now)) {
                transformed.balanceHistory.push(history);
              }
            });
            cb(null, transformed);
          } else {
            cb(null, found);
          }
        }
      });
    }
  ], callback);
};

/**
 * Get bank accounts for a user
 * @param   {UUID}        id              id of the account to get user bank accounts for
 * @param   {Object}      criteria        the search criteria
 * @param   {Function}    callback        callback function
 */
exports.getBankAccounts = function(id, criteria, callback) {
  var sort = { };
  sort[criteria.sortType] = constants.sortOrder[criteria.sortOrder];
  criteria.where = {
    accountId: id
  };
  async.waterfall([
    function(cb) {
      BankAccount.count(criteria.where, cb);
    },
    function(count, cb) {
      BankAccount.find(criteria.where).limit(criteria.limit).skip(criteria.offset).sort(sort).exec(function(err, items) {
        cb(err, count, items);
      });
    },
    function(count, items, cb) {
      cb(null, {
        offset: criteria.offset,
        limit: criteria.limit,
        count: count,
        items: items
      });
    }
  ], callback);
};

/**
 * Get account services for a user
 * @param   {UUID}        id              id of the account to get account services for
 * @param   {Object}      criteria        the search criteria
 * @param   {Function}    callback        callback function
 */
exports.getAccountServices = function(id, criteria, callback) {
  var sort = { };
  sort[criteria.sortType] = constants.sortOrder[criteria.sortOrder];
  criteria.where = criteria.where || {};
  _.extend(criteria.where, {
    accountId: id
  });
  async.waterfall([
    function(cb) {
      Service.count(criteria.where, cb);
    },
    function(count, cb) {
      Service.find(criteria.where).limit(criteria.limit).skip(criteria.offset).sort(sort).exec(function(err, items) {
        cb(err, count, items);
      });
    },
    function(count, items, cb) {
      cb(null, {
        offset: criteria.offset,
        limit: criteria.limit,
        count: count,
        items: items
      });
    }
  ], callback);
};

/**
 * Get user sales
 * @param   {UUID}        id              id of the account to get user sales for
 * @param   {Object}      criteria        the search criteria
 * @param   {Function}    callback        callback function
 */
exports.getSales = function(id, criteria, callback) {
  criteria.where = criteria.where || {};
  var sort = { };
  sort[criteria.sortType] = constants.sortOrder[criteria.sortOrder];
  _.extend(criteria.where, {
    accountId: id
  });
  async.waterfall([
    function(cb) {
      Sales.count(criteria.where, cb);
    },
    function(count, cb) {
      Sales.find(criteria.where).limit(criteria.limit).skip(criteria.offset).sort(sort).exec(function(err, items) {
        cb(err, count, items);
      });
    },
    function(count, items, cb) {
      cb(null, {
        offset: criteria.offset,
        limit: criteria.limit,
        count: count,
        items: items
      });
    }
  ], callback);
};

/**
 * Get the sales resource details
 * @param   {UUID}        id              id of the account to get user sales for
 * @param   {UUID}        saleId          id of the sale resource to fetch
 * @param   {Function}    callback        callback function
 */
exports.getSingleSales = function(id, saleId, type, callback) {
  Sales.findOne({ _id: saleId, accountId: id, type: type }, function(err, found) {
    if(err) {
      return callback(err);
    } else if(!found) {
      return callback(new errors.NotFoundError('Sales resource doesn\'t exist with given criteria'));
    }
    callback(null, found);
  });
};

/**
 * Get customer relations
 * @param   {UUID}        id              id of the account to customer relations for
 * @param   {Function}    callback        callback function
 */
exports.getRelations = function(id, callback) {
  CustomerRelation.find({ accountId: id }, callback);
};

/**
 * Search the accounts
 * @param   {Object}      criteria        the search criteria
 * @param   {Function}    callback        callback function
 */
exports.search = function(criteria, callback) {
  var sort = { };
  sort[criteria.sortType] = constants.sortOrder[criteria.sortOrder];
  async.waterfall([
    function(cb) {
      Account.count(criteria.where, cb);
    },
    function(count, cb) {
      Account.find(criteria.where).limit(criteria.limit).skip(criteria.offset).sort(sort).exec(function(err, items) {
        cb(err, count, items);
      });
    },
    function(count, items, cb) {
      cb(null, {
        offset: criteria.offset,
        limit: criteria.limit,
        count: count,
        items: items
      });
    }
  ], callback);
};