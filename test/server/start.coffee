{createServer} = require '../server'
request = require 'supertest'

app = createServer()

describe 'routes', ->
  it 'single id', ->
    request app
      .get '/android/results/5026457547'
      .expect 200
      .expect 'Content-Type',  /json/
      .then (response)->
        expect(response.body).property 'android_result_id', 5026457547
