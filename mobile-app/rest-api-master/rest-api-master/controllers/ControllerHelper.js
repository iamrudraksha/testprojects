/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Helper utility class for all the controllers
 * This class exports some common validation functions as well as filtering functions
 * @author      TCSCODER
 * @version     1.0
 */

/* Globals */
var _ = require('lodash'),
  httpStatus = require('http-status'),
  constants = require('../constants'),
  config = require('config'),
  errors = require('common-errors');

/**
 * Validate that given value is a valid String
 *
 * @param  {String}           val      String to validate
 * @param  {String}           name     name of the string property
 * @return {Error/Undefined}           Error if val is not a valid String otherwise undefined
 */
exports.checkString = function(val, name) {
  if(!_.isString(val)) {
    return new errors.ValidationError(name + ' should be a valid string', httpStatus.BAD_REQUEST);
  }
};

/**
 * Validate that given value is a valid String if defined
 *
 * @param  {String}           val      String to validate
 * @param  {String}           name     name of the string property
 * @return {Error/Undefined}           Error if val is not a valid String otherwise undefined
 */
var _checkOptionalString = function(val, name) {
  if(val && !_.isString(val)) {
    return new errors.ValidationError(name + ' should be a valid string', httpStatus.BAD_REQUEST);
  }
};

/**
 * Validate that the value is a valid sort direction if defined
 *
 * @param  {String}                val      Object to validate
 * @param  {String}                name     name of the object
 * @return {Error/Undefined}                Error if val is not a valid String otherwise undefined
 */
var _checkOptionalSortOrder = function(val, name) {
  var error = _checkOptionalString(val, name);
  var sortOrder = _.keys(constants.sortOrder);
  if(sortOrder.indexOf(val) === -1) {
    error = error || new errors.ValidationError(name + ' should either be desc or asc', httpStatus.BAD_REQUEST);
  }
  return error;
};

/**
 * Validate that given value is a valid positive number
 *
 * @param  {Number}                val      Number to validate
 * @param  {String}                name     name of the Number property
 * @return {Error/Undefined}                Error if val is not a valid String otherwise undefined
 */
var _checkPositiveNumber = exports.checkPositiveNumber = function(val, name) {
  val = parseInt(val);
  if(!_.isNumber(val) || isNaN(val)) {
    return new errors.ValidationError(name + ' should be a valid number', httpStatus.BAD_REQUEST);
  } else if(val < 0) {
    return new errors.ValidationError(name + ' should be a valid positive number', httpStatus.BAD_REQUEST);
  }
};

/**
 * Validate that given value is a valid positive number if defined
 *
 * @param  {Number}                val      Number to validate
 * @param  {String}                name     name of the Number property
 * @return {Error/Undefined}                Error if val is not a valid String otherwise undefined
 */
var _checkOptionalPositiveNumber = function(val, name) {
  if(val) {
    return _checkPositiveNumber(val, name);
  }
};

/**
 * Validate that given value is a valid duration parameter for balance history
 *
 * @param  {Number}                val      Number to validate
 * @param  {String}                name     name of the Number property
 * @return {Error/Undefined}                Error if val is not a valid String otherwise undefined
 */
exports.checkDuration = function(duration, name) {
  var valid = ['1_m', '3_m', '6_m', '1_y', '2_y'];
  if(duration && (!_.isString(duration) || valid.indexOf(duration) === -1)) {
    return new errors.ValidationError(name + ' is invalid duration. Valid values are ' + valid.toString(), httpStatus.BAD_REQUEST);
  }
};

/**
 * Parse the query criteria
 *
 * @param  {[type]}   req                 express request instance
 * @param  {[type]}   validSortColumns    valid sort columns
 * @param  {Function} callback            callback function
 */
exports.parseQueryCriteria = function(req, validSortColumns, callback) {
  var criteria = _.pick(req.query, 'offset', 'limit', 'sortType', 'sortOrder');
  criteria.limit = criteria.limit || config.DEFAULT_LIMIT;
  criteria.offset = criteria.offset || 0;
  criteria.sortType = criteria.sortType || config.DEFAULT_SORT_TYPE;
  criteria.sortOrder = criteria.sortOrder || config.DEFAULT_SORT_ORDER;
  var error = _checkOptionalPositiveNumber(criteria.offset, 'offset') || _checkOptionalPositiveNumber(criteria.limit, 'limit') ||
                _checkOptionalString(criteria.sortType, 'sortType') || _checkOptionalSortOrder(criteria.sortOrder, 'sortOrder');

  if(criteria.sortType && validSortColumns.indexOf(criteria.sortType) === -1) {
    error = error || new errors.ValidationError('invalid sort type ' + criteria.sortType + '. Valid sort types are ' + validSortColumns.toString(), httpStatus.BAD_REQUEST);
  }
  if(error) {
    return callback(error);
  }
  callback(null, criteria);
};

/**
 * Validate that the value is a valid sales type
 *
 * @param  {String}                val      Object to validate
 * @param  {String}                name     name of the object
 * @return {Error/Undefined}                Error if val is not a valid String otherwise undefined
 */
exports.checkSalesType = function(val, name) {
  if(_.values(constants.salesTypes).indexOf(val) === -1) {
    return new errors.ValidationError('invalid ' + name + ' ' + val + '. Valid sales types are ' + _.values(constants.salesTypes).toString(), httpStatus.BAD_REQUEST);
  }
};