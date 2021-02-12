require 'test/server.spec'

describe 'bin/map', ->
  @timeout 5000
  
  it 'suggests isLiteral', ->
    try
      {stdout, stderr, child} = await exec 'map'
    catch e
      expect(e.child).property('exitCode', 1)
      expect(e.stderr).contains 'One of'
      expect(e.stderr).contains 'isLiteral'

  it 'isLiteral works', ->
    {stdout, stderr} = await exec '(echo 1; echo {}) | map isLiteral'
    expect stdout
    .contains "true\nfalse\n"   # or equivalent
