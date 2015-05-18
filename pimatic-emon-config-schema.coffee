# #my-plugin configuration options
# Declare your config option for your plugin here. 
module.exports = {
  title: "Emon"
  type: "object"
  properties:
    ipu:
      description: "Instantaneous Power Usage"
      type: "number"
      default: 0
  }