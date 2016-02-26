/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Main application init file.
 * This will spin up an HTTP SERVER which will listen on connections on default configured port
 *
 * @author      TCSCODER
 * @version     1.0
 */

var express = require('express'),
  app = express(),
  bodyParser = require('body-parser'),
  router = require('./router'),
  logger = require('./logger').getLogger(),
  responseTransformer = require('./middlewares/ResponseTransformer'),
  errorHandler = require('./middlewares/ErrorHandler'),
  cors = require('cors'),
  responser = require('./middlewares/Responser'),
  config = require('config');

var port = process.env.PORT || config.WEB_SERVER_PORT || 3100;
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));
app.use(router());
app.use(responseTransformer());
app.use(responser());
app.use(errorHandler());

app.listen(port, function() {
  logger.info('Application started successfully', port);
});