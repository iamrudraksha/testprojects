/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * This module exposes route handlers for '/accounts/*', '/login' endpoints
 *
 * @author      TCSCODER
 * @version     1.0
 */
var accountService = require('../services/AccountService');
var controllerHelper = require('./ControllerHelper');
var httpStatus = require('http-status');
var async = require('async');
var _ = require('lodash');

/**
 * Log in a user into the application
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.login = function(req, res, next) {
  var credentials = _.pick(req.body, 'username', 'password');
  var error = controllerHelper.checkString(credentials.username, 'username') || controllerHelper.checkString(credentials.password, 'password');
  if(error) {
    return next(error);
  }
  accountService.login(credentials, function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * [_getWhereClause description]
 * @param  {Object}     query   express req.query object
 * @return {Object}             mongoose where clause object
 */
var _getWhereClause = function(query) {
  var where = {};
  if(query.query) {
    var likeParam = new RegExp(query.query, 'i');
    _.extend(where, {
      $or: [
        {
          firstName: { $regex: likeParam }
        },
        {
          lastName: { $regex: likeParam }
        },
        {
          email: { $regex: likeParam }
        },
        {
          type: { $regex: likeParam }
        },
        {
          'address.streetAddress': { $regex: likeParam }
        }
      ]
    });
  }
  if(query.distance) {
    _.extend(where, {
      distance: query.distance
    });
  }
  if(query.clientType) {
    _.extend(where, {
      type: query.clientType
    });
  }
  return where;
};

/**
 * Search user accounts
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.search = function(req, res, next) {
  async.waterfall([
    function(cb) {
      var validSortColumns = ['_id', 'firstName', 'lastName', 'email', 'type', 'distance'];
      controllerHelper.parseQueryCriteria(req, validSortColumns, cb);
    },
    function(criteria, cb) {
      criteria.where = _getWhereClause(req.query);
      accountService.search(criteria, cb);
    }
  ], function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * Get user account details
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getSingle = function(req, res, next) {
  // this is a find by ID
  var error = controllerHelper.checkPositiveNumber(req.params.id, 'id');
  if(error) {
    return next(error);
  }
  accountService.getSingle(req.params.id, function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * Get user profile
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getProfile = function(req, res, next) {
  var error = controllerHelper.checkPositiveNumber(req.params.id, 'id') || controllerHelper.checkDuration(req.query.duration, 'duration');
  if(error) {
    return next(error);
  }
  accountService.getProfile(req.params.id, req.query.duration || null, function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * Get customer relationship information
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getRelations = function(req, res, next) {
  var error = controllerHelper.checkPositiveNumber(req.params.id, 'id');
  if(error) {
    return next(error);
  }
  accountService.getRelations(req.params.id, function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * Get user bank accounts
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getBankAccounts = function(req, res, next) {
  var error = controllerHelper.checkPositiveNumber(req.params.id, 'id');
  if(error) {
    return next(error);
  }
  async.waterfall([
    function(cb) {
      var validSortColumns = ['_id', 'accountId', 'balance', 'name', 'status', 'type'];
      controllerHelper.parseQueryCriteria(req, validSortColumns, cb);
    },
    function(criteria, cb) {
      accountService.getBankAccounts(req.params.id, criteria, cb);
    }
  ], function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * Get account services
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getAccountServices = function(req, res, next) {
  var error = controllerHelper.checkPositiveNumber(req.params.id, 'id');
  if(error) {
    return next(error);
  }
  async.waterfall([
    function(cb) {
      var validSortColumns = ['_id', 'name', 'serviceType', 'accountId', 'date', 'amount'];
      controllerHelper.parseQueryCriteria(req, validSortColumns, cb);
    },
    function(criteria, cb) {
      if(req.query.filterBy) {
        criteria.where = {
          serviceType: req.query.filterBy
        };
      }
      accountService.getAccountServices(req.params.id, criteria, cb);
    }
  ], function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * Get user related sale's resources
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getSales = function(req, res, next) {
  var error = controllerHelper.checkPositiveNumber(req.params.id, 'id');
  if(error) {
    return next(error);
  }
  async.waterfall([
    function(cb) {
      var validSortColumns = ['_id', 'type', 'name', 'accountId', 'managerName', 'fundLevel'];
      controllerHelper.parseQueryCriteria(req, validSortColumns, cb);
    },
    function(criteria, cb) {
      if(req.query.type) {
        var typeError = controllerHelper.checkSalesType(req.query.type, 'type');
        if(typeError) {
          return next(typeError);
        }
        criteria.where = {
          type: req.query.type
        };
      }
      accountService.getSales(req.params.id, criteria, cb);
    }
  ], function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

/**
 * Get sales resource details
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getSingleSales = function(req, res, next) {
  // saleId is the UUID and account reference id is integer
  var error = controllerHelper.checkPositiveNumber(req.params.id, 'id') || controllerHelper.checkString(req.params.saleId, 'saleId') || controllerHelper.checkString(req.params.type, 'type');
  if(error) {
    return next(error);
  }
  accountService.getSingleSales(req.params.id, req.params.saleId, req.params.type, function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.OK,
      content: result
    };
    next();
  });
};

exports.me = function(req, res, next) {
    console.log(req.auth);    
        accountService.getSingle(req.auth.userId, function(err, result) {
          if(err) {
            return next(err);
          }
          req.data = {
            statusCode: httpStatus.OK,
            content: result
          };
          next();
        });
};