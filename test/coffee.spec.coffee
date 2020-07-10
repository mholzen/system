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

  it 'finally', ->
    count = 0
    f = ->
      try
      finally
        count++
    f()
    expect(count).eql 1

  it 'async', ->
    count = 0
    f = (x)->
      try
        if x == 1
          return await 1
        throw new Error()
      catch e
        return 2

    expect(await f(1)).eql 1
    expect(await f(2)).eql 2

  it 'promise rejection happens outside of try catch', ->
    c = 0
    f = new Promise (resolve, reject)-> setTimeout (-> reject 1), 500
    g = ->
      try
        await f
      catch e
        c++

        try
          await f
        catch e
          c++
    g()   # no await here means it goes right through
    expect(c).eql 0

  it 'await multiple times', ->
    f = new Promise (resolve, reject)-> resolve 1
    r = await f
    r = await f
    r = await f
    expect(r).eql 1