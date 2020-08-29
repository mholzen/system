child_process = require "child_process"

exec = (args)->
  new Promise (resolve, reject)->
    child = child_process.exec args, (err, stdout, stderr)->
      if err?
        e = new Error err.toString() + "\nstdout:" + stdout + "\nstderr:" + stderr
        e.stdout = stdout
        e.stderr = stderr
        e.child = child
        reject e
      resolve {stdout, stderr, child}

module.exports = exec
