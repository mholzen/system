handlebars = require 'handlebars'
{fileContentSync} = require '../content'
{Template} = require '../template'

module.exports = {
  graph: new Template fileContentSync( __dirname+'/graph.html').toString()
}
