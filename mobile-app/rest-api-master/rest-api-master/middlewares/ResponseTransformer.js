/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Response transformer middleware
 * This middleware is added before sending the response to the client.
 * This will transform the response in following way
 * 1. Delete _id property and instead expose it on id property
 *
 * @author      TCSCODER
 * @version     1.0
 */

var _ = require('lodash'),
  async = require('async');

/**
 * Helper method to transform the object
 * @param  {Object}     obj     the object to transform
 * @return {Object}             the callback function
 */
var _transform = function(obj) {
  var transformed;
  if(obj.toObject) {
    transformed = obj.toObject();
  } else {
    transformed = obj;
  }
  if(obj._id) {
    transformed.id = obj._id;
  }
  return _.omit(transformed, '_id', '__v', 'password');
};

/**
 * Filter a object
 *
 * @param  {Object}     obj           the object to filter
 * @param  {Function}   callback      the callback function
 */
var _doFilter = function(obj, callback) {
  var transformed = _transform(obj);
  callback(null, transformed);
};

/**
 * The middleware function
 *
 * @param  {Object}       req         express request instance
 * @param  {Object}       res         express response instance
 * @param  {Function}     next        next middleware function in the chain
 */
var _middleware = function(req, res, next) {
  if(req.data && req.data.content) {
    // check for the paginated rows
    if(_.isArray(req.data.content.items)) {
      async.map(req.data.content.items, _doFilter, function(err, transformed) {
        delete req.data.content.items;
        req.data.content.items = transformed;
        next();
      });
    } else if(_.isArray(req.data.content)) {
      async.map(req.data.content, _doFilter, function(err, transformed) {
        delete req.data.content;
        req.data.content = transformed;
        next();
      });
    } else if(_.isObject(req.data.content)) {
      var transformed = _transform(req.data.content);
      delete req.data.content;
      req.data.content = transformed;
      next();
    } else {
      next();
    }
  } else {
    next();
  }
};

// module export a function
module.exports = function() {
  return _middleware;
};