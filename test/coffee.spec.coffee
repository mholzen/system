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

  it 'async functions that throw before await', (done)->
    foo = ->
      throw new Error()
      await 1

    try
      r = foo()
      expect(r).instanceof Promise
      r.catch (e)->
        expect(e).instanceof Error
        done()
    catch e
      expect.fail()
    return # dont return a promise

  it 'async functions that throw after await', ->
    foo = ->
      await 1
      throw new Error 'foo'

    try
      await foo()       # await makes the test function async (i.e. returns a promise), which makes the resolution overspecified
      expect.fail() 
    catch e
      # expect.fail() above will throw and get caught here, so you have to check that e is an exception of the right kind
      expect(e.toString()).include 'foo'
  

  it 'await in a function makes any caller implicitly async --- THIS IS TERRIBLE', ->
    f = ->
      return 1
      await 2

    expect f()
    .property 'then'
    .a 'function'

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

  it 'if', ->
    a = if false
      1
    else
      2

    expect(a).eql 2

  it 'value of a for loop', ->
    f = ->
      for i in [1..2]
        i+1
    
    expect f()
    .eql [2,3]

  it 'apply', ->
    f = (a,b,c)->
      return [a,b,c]

    a = [1,2,3]
    expect f.apply @, a
    .eql [1,2,3]

  it 'destructuring assignment on function call', ->
    f = ([a,b])->
      return a+b

    expect f [1,2]
    .eql 3

  it 'indent', ->
    data =
      if true
        1
      else
        2
    
    expect data
    .eql 1
