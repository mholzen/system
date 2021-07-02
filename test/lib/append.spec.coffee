{append, request, isPromise} = require  'lib/mappers'

describe 'append', ->
  it 'append data with no destination', ->
    expect ->
      append 'foo'
    .throws 'NotMapped'


  it 'append request', ->
    incomingRequest =
      method: 'GET'
      path: '/foo'
      protocol: 'http'

    res = append incomingRequest
    expect isPromise res
    .true
    