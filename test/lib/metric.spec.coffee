{Schedule} = require 'lib/metric'

describe 'metrics', ->
  it 'works', ->
    s = new Schedule period:10
    expect s.nextAfter 19
    .eql 20

  # describe 'scheduler', ->
  # describe 'timeseries', ->
  #   ts = new Timeseries()
  #   ts.respondsTo 'valuesBetween'
  #   expect ts.valuesBetween 0, 1
  #   .eql []

  # describe 'timeseries', ->
  #   ts = new TimeseriesDb()
  #   ts.respondsTo 'valuesBetween'
  #   expect ts.valuesBetween 0, 1
  #   .eql []
