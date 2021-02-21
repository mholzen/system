get = require 'lib/mappers/get'

describe 'get', ->
  it 'basic', ->
    expect get [1,2,3], '0'
    .eql 1

    expect get [1,2,3], '1'
    .eql 2

    expect get {a:1,b:2}, 'a'
    .eql 1
