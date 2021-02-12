describe 'bin/transform', ->
  @timeout 5000
  
  it 'suggests count', ->
    try
      {stdout, stderr, child} = await exec 'transform'
    catch e
      expect(e.child).property('exitCode', 1)
      expect(e.stderr).contains 'One of'
      expect(e.stderr).contains 'count'

  it 'count works', ->
    {stdout, stderr} = await exec '(echo a; echo b) | transform count'
    expect stdout
    .contains "1\n2\n"   # or equivalent
