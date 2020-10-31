require 'test/server.spec'

describe 'bin/map', ->
  @timeout 5000
  
  it 'suggests mappers', ->
    try
      {stdout, stderr, child} = await exec 'map'
    catch e
      expect(e.child).property('exitCode', 1)
      expect(e.stderr).contains 'cannot find mapper'
      expect(e.stdout).contains 'Available mappers'
      expect(e.stdout).contains 'isLiteral'

  it 'keys work', ->
    {stdout, stderr} = await exec '(echo 1; echo {}) | map isLiteral'
    expect stdout
    .contains "true\nfalse\n"   # or equivalent
