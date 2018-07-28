a = 1
f = ->
  a = a + 1

describe 'coffee', ()->
  it 'inner variable', ->
    expect a == 1
    f()
    expect a == 2
