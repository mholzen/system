get = require 'lib/mappers/get'

describe 'get', ->
  it 'basic', ->
    expect (get.create '0') [1,2,3]
    .eql 1

    expect (get.create '1') [1,2,3]
    .eql 2

    expect (get.create 'a') {a:1,b:2}
    .eql 1

    expect (get.create 0) new Map [['a', 1]]
    . eql ['a',1]
