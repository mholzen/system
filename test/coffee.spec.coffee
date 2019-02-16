a = 1
f = ->
  a = a + 1

describe 'coffee', ()->
  it 'inner variable', ->
    expect a == 1
    f()
    expect a == 2

  it 'for over non object', ->
    a = 1
    for k, v of a
      console.log k, v
