handlebars = require 'handlebars'
{fileContentSync} = require '../content'
{Template} = require '../template'
pug = require 'pug'

module.exports = {
  graph: new Template fileContentSync( __dirname+'/graph.html').toString()
}
