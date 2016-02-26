/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * This module exposes route handlers for '/sales/*' endpoints
 *
 * @author      TCSCODER
 * @version     1.0
 */

var salesService = require('../services/SalesService');
var _ = require('lodash');
var controllerHelper = require('./ControllerHelper');
var errors = require('common-errors');
var httpStatus = require('http-status');
var constants = require('../constants');

/**
 * Validate the given entity
 * @param  {Object}   entity    the entity to validate
 */
var _validate = function(entity) {
  var error = controllerHelper.checkString(entity.type, 'type') || controllerHelper.checkString(entity.name, 'name') || controllerHelper.checkPositiveNumber(entity.accountId, 'accountId') ||
                controllerHelper.checkString(entity.methodOfContact, 'methodOfContact') || controllerHelper.checkPositiveNumber(entity.productOfInterest, 'productOfInterest');
  if(_.values(constants.salesTypes).indexOf(entity.type) === -1) {
    error = error || new errors.ValidationError('type should be a valid sales type', httpStatus.BAD_REQUEST);
  }
  return error;
};

/**
 * New sales request
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.create = function(req, res, next) {
  var entity = _.pick(req.body, 'type', 'name', 'accountId', 'managerName', 'methodOfContact', 'productOfInterest', 'fundLevel', 'details');
  var error = _validate(entity);
  if(error) {
    return next(error);
  }
  salesService.create(entity, function(err, result) {
    if(err) {
      return next(err);
    }
    req.data = {
      statusCode: httpStatus.CREATED,
      content: result
    };
    next();
  });
};

/**
 * Sales product of interest
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.productsOfInterest = function(req, res, next) {
  salesService.getProductsOfInterest(function(err, result) {
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