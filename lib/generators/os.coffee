os = require 'os'

homedir = Object.assign os.homedir,
  parameters: []
  responses:
    200:
      description: "the home directory of the current process"
      content:
        "text/plain": {}
        "application/json":
          type: 'string'

functions =
  homedir: homedir

module.exports = functions
