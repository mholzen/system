require 'test/server.spec'

describe 'bin/generate', ->
  @timeout 5000
  
  it 'suggests time', ->
    try
      {stdout, stderr, child} = await exec 'generate'
    catch e
      expect(e.child).property('exitCode', 1)
      expect(e.stderr).contains 'One of'
      expect(e.stderr).contains 'time'

  # it 'keys work', ->
  #   {stdout, stderr} = await exec '(echo 1; echo {}) | map isLiteral'
  #   expect stdout
  #   .contains "true\nfalse\n"   # or equivalent
