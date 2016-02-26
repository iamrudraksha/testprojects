/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Simple authentication middleware
 * This middleware will only be added to authenticated endpoints
 * The module has role based authentication support
 *
 * @author      TCSCODER
 * @version     1.0
 */

var jwt = require('jwt-simple'),
  config = require('config'),
  errors = require('common-errors'),
  moment = require('moment');

var authorizationTypes = {
  bearer: 'Bearer'
};


// module export a function
module.exports = function() {
  /**
   * The middleware function
   *
   * @param  {Object}       req         express request instance
   * @param  {Object}       res         express response instance
   * @param  {Function}     next        next middleware function in the chain
   */
  return function(req, res, next) {
    var authorizationHeader = req.get('Authorization');
    // authenticaiton logic
    if(authorizationHeader) {
      var splitted = authorizationHeader.split(' ');
      if(splitted.length !== 2 || splitted[0] !== authorizationTypes.bearer) {
        return next(new errors.AuthenticationRequiredError('Invalid authorization header'));
      }
      var token = splitted[1];
      req.auth = jwt.decode(token, config.JWT_SECRET);
      if(req.auth.expiration > moment().valueOf()) {
        return next();
      }
      next(new errors.AuthenticationRequiredError('Authorization token is expired'));
    } else {
      next(new errors.AuthenticationRequiredError('Missing authorization header'));
    }
  };
};