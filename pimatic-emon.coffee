# #Plugin pimatic-emon

# This is an plugin template and mini tutorial for creating pimatic plugins. It will explain the 
# basics of how the plugin system works and how a plugin should look like.

# ##The plugin code

# Your plugin must export a single function, that takes one argument and returns a instance of
# your plugin class. The parameter is an envirement object containing all pimatic related functions
# and classes. See the [startup.coffee](http://sweetpi.de/pimatic/docs/startup.html) for details.
module.exports = (env) ->

  # ###require modules included in pimatic
  # To require modules that are included in pimatic use `env.require`. For available packages take 
  # a look at the dependencies section in pimatics package.json

  # Require the  bluebird promise library
  Promise = env.require 'bluebird'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  # Include you own depencies with nodes global require function:
  #  
  #     someThing = require 'someThing'
  #  

  # ###MyPlugin class
  # Create a class that extends the Plugin class and implements the following functions:
  class Emon extends env.plugins.Plugin

    # ####init()
    # The `init` function is called by the framework to ask your plugin to initialise.
    #  
    # #####params:
    #  * `app` is the [express] instance the framework is using.
    #  * `framework` the framework itself
    #  * `config` the properties the user specified as config for your plugin in the `plugins` 
    #     section of the config.json file 
    #     
    # 
    init: (app, @framework, @config) =>
      
      deviceConfigDef = require("./device-config-schema")

      @framework.deviceManager.registerDeviceClass("EmonDevice", {
        configDef: deviceConfigDef.EmonDevice,
        createCallback: (config) => new EmonDevice(config)
      })    

    class EmonDevice extends env.devices.Device

      attributes:
        ipu:
          description: "Actual power usage"
          type: "number"
          unit: ' Watt'
        counter:
          description: "Total power used today"
          type: "number"
          unit: ' kWh'

      data = 
        ipu : 0.0
        counter : 0.0
        token : ""

      constructor: (@config) ->
        @id = config.id
        @name = config.name
        @ip = config.ip
        @port = config.port
        @username = config.username
        @password = config.password
        @interval = config.interval

        super()

        setInterval( =>
          @requestData()
        , @interval
        )

      http = require "http"
      
      # Grab token from emon server.
      fetchToken: (host, port, path, username, password, cb) ->
        options = 
          host: host
          port: port
          path: path
          headers:{
            'Content-Type':'application/json'
          }
          method: 'POST'

        user = 
          username: username
          password: password

        req = http.request options, (res) ->
          content = ""
          res.on 'data', (data) ->
            content += "#{data}"
          res.on 'end', () ->
            cb null, res, content
          res.on 'error', (err) ->
            cb err, null, null
        req.on 'error', (err) ->
          cb err, null, null
        req.write JSON.stringify(user)
        req.end()

      # Fetch E monitoring data. Valid token is mandatory
      fetchData: (host, port, path, cb) ->
        options = 
          host: host
          port: port
          path: path
          headers:{
            'Content-Type':'application/json',
            'X-Access-Token': data.token
          }
        
        req = http.get options, (res) ->
          content = ""        
          res.on 'data', (data) ->
            content += "#{data}"
          res.on 'end', () ->
            cb null, res, content
          res.on 'error', (err) ->
            cb err, null, null
        req.on 'error', (err) ->
          cb err, null, null
     
      requestData : () ->
         @fetchData @ip, @port, "/api/ipu", (err, res, body) =>
          if(!err)
            if(res.statusCode == 401 )
              @fetchToken @ip, @port, "/api/login", @username, @password, (err, res, body) ->
                try 
                  data.token = (JSON.parse body).token; 
                catch e 
                  env.logger.error("fetchToken: Error parsing JSON")
            else
            # Decode data
              try 
                data.ipu = (JSON.parse body)[0].ipu
                
                @emit "ipu", Number data.ipu
                @emit "counter", Number data.counter
              
              catch e
                env.logger.error("fetchData: Error parsing JSON")
          else
            env.logger.error(err)

      getIpu: -> Promise.resolve @ipu
      getCounter: -> Promise.resolve @counter

  # ###Finally
  # Create a instance of my plugin
  plugin = new Emon
  # and return it to the framework.
  return plugin