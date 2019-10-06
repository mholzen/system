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
    c = 0
    for k, v of a
      c++
    # can be 0 or greater
    expect(c).above -1

  foo = ->
    throw new Error()
    await 1

  it 'async functions that throw before await', (done)->
    try
      r = foo()
      expect(r).instanceof Promise
      r.catch (e)->
        expect(e).instanceof Error
        done()
    catch e
      expect.fail()
    return # dont return a promise
