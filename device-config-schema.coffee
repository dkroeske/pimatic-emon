module.exports = {
  title: "pimatic-emon device config schemas"
  EmonDevice: {
    title: "EmonDevice config options"
    type: "object"
    properties:
      ip:
        description: "E-monitor server IP address"
        format: String
        default: "127.0.0.1"
      port:
        description: "E-monitor server port number"
        format: String
        default: "12345"
      username:
        description: "username for the emon RESTful service"
        format: String
        default: ""
      password:
        description: "username for the emon RESTful service"
        format: String
        default: ""
      interval:
        description: "Request interval"
        format: Number
        default: "100000" 
      meterid:
        description: "E meter identification"
        format: Number
        default: ""     
  }
} 