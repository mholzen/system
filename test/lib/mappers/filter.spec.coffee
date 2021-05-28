{filter} = require 'lib/mappers'

describe 'filter', ->
  it 'works', ->
   expect(filter(['a'])).eql []
   a = ['# TODO: use options to: customize filter']
   expect(filter a).eql a