/*
 * Copyright (C) 2015 TopCoder Inc., All Rights Reserved.
 */
'use strict';

/**
 * Exports the application level constants
 *
 * @author      TCSCODER
 * @version     1.0
 */

/**
 * Account types
 * @type {Object}
 */
exports.accountTypes = {
  consumer: 'consumer',
  commercial: 'commercial'
};

/**
 * Bank account statuses
 * @type {Object}
 */
exports.bankAccountStatus = {
  closed: 'closed',
  open: 'open'
};

/**
 * Bank account types
 * @type {Object}
 */
exports.bankAccountTypes = {
  current: 'current',
  savings: 'savings'
};

/**
 * Sales types
 * @type {Object}
 */
exports.salesTypes = {
  referral: 'referral',
  opportunity: 'opportunity'
};

/**
 * Valid sort types
 * @type {Object}
 */
exports.sortOrder = {
  asc: 1,
  desc: -1
};