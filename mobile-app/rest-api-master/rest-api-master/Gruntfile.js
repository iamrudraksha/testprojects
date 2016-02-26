/**
 * Copyright (c) 2015, Topcoder Inc. All rights reserved.
 */
'use strict';

/**
 * Gruntfile.js
 * This file defines the grunt tasks
 *
 * @author      TCSCODER
 * @version     1.0
 */

var paths = {
  js: ['*.js','**/*.js', '!node_modules/**']
};

module.exports = function(grunt) {
  // Project Configuration
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    jshint: {
      all: {
        src: paths.js,
        options: {
          jshintrc: true
        }
      }
    }
  });

  //Load NPM tasks
  require('load-grunt-tasks')(grunt);

  grunt.registerTask('default', ['jshint']);
};