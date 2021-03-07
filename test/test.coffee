s = 0
f = ->
    if false
        await 1
    console.log s
    2

# f1 = require '../lib/mappers/request'
# r = f1().catch (e)->{}

r = f()
console.log r, s
s++
