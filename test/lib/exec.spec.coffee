describe 'exec', ->
  it 'works', ->
    {stdout, stderr, child} = await exec "echo a | wc -l"
    expect(stdout).contains '1'
    expect(child.exitCode).eql 0

  it 'fails noticeably', ->
    # expect ->
    #   {stdout, stderr} = await exec "echo a | foobar -l"    # NOTE: the function returns a promise, that eventually throws
    # .throw 'foobar: comamnd not found'
    try
      {stdout, stderr} = await exec "echo a | foobar -l"
      # {stdout, stderr} = await exec "echo a"
      expect.fail()
    catch e
      expect(e.toString()).contains 'Command failed'
