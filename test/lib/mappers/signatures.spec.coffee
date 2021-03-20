# templates are mappers that accept a dictionary
templates = require 'lib/mappers/templates'

it 'finds templates with substitutions containing a string', ->
  expect Object.keys templates.reference 'graph'
  .include 'graph'
  .include 'graph2'

it 'given data a dictionary, find templates that reference one or more of the keys', ->
  data =
    nodeList: 'foo'
    edges: 1
  
  expect Object.keys templates.reference data
  .include 'graph'
  .include 'graph2'

