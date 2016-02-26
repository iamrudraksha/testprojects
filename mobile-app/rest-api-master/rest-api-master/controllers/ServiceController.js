/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * This module exposes route handlers for '/services/*' endpoints
 *
 * @author      TCSCODER
 * @version     1.0
 */

var _ = require('lodash');
var controllerHelper = require('./ControllerHelper');
var httpStatus = require('http-status');
var serviceService = require('../services/ServiceService');

/**
 * Validate the given entity
 * @param  {Object}   entity    the entity to validate
 */
var _validate = function(entity) {
  var error = controllerHelper.checkString(entity.details, 'details') || controllerHelper.checkString(entity.name, 'title') || controllerHelper.checkPositiveNumber(entity.accountId, 'accountId') ||
                controllerHelper.checkPositiveNumber(entity.serviceType, 'serviceType');
  return error;
};

/**
 * New service request
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.create = function(req, res, next) {
  var entity = _.pick(req.body, 'accountId', 'bankAccount', 'details', 'date', 'amount', 'serviceType');
  entity.name = req.body.title;
  var error = _validate(entity);
  if(error) {
    return next(error);
  }
  serviceService.create(entity, function(err, result) {
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
 * Get service types
 *
 * @param  {Object}       req       express request instance
 * @param  {Object}       res       express response instance
 * @param  {Function}     next      the next function in the middleware chain
 */
exports.getServiceTypes = function(req, res, next) {
  serviceService.getServiceTypes(function(err, result) {
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