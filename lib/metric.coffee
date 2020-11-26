class Schedule
  constructor: (options)->
    @period = options?.period ? 1
    if @options?.frequency?
      if @period?
        throw new Error "overspecified"
      @period = 1.0 / options?.frequency

    @start = options?.start ? 0
  
  nextAfter: (number)->
    n = Math.floor (number - @start)/@period
    (n+1)*@period

  next: (after=null, limit=10)->

module.exports = {Schedule}
