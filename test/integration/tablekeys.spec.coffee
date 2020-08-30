{parse, map} = require '../../streams/transformers'    # units under tests

describe 'tablekeys', ->

  {stream, mappers} = require '../../lib'              # helpers (therefore depends on)

  it 'works', ->
    @timeout 10000
    {stdout, stderr} = await exec 'head -200 ~/data/organizations/mint.com/transactions.csv | reduce group "Account Name" | map keys'
    expect stdout
    .contains "Checking"
