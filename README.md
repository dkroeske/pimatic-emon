pimatic emon plugin
=======================

Reading the diy Energy Monitoring service called [**emon**](https://github.com/dkroeske/emon-server) and showing values in pimatic. [**emon**](https://github.com/dkroeske/emon-server) is a cheap diy '555 timer chip based circuit' taped to the flashing light of your energy meter (electricity and/or gas), a little bit of Python and a node.js RESTful service. More on [**emon**](https://github.com/dkroeske/emon-server) can be found [here](https://github.com/dkroeske/emon-server)

![alt tag](https://github.com/dkroeske/pimatic-emon/blob/master/images/ipu-pimatic.png)

v0.1

Configuration
-------------

Make sure the files are installed in the *node_modules/pimatic-emon* folder

Add the plugin to the plugin section of your config.json:

```json
{
  "plugin": "emon"
}
```

Add a device to the devices section:

```json
{
  "id": "emon",
  "class": "EmonDevice",
  "name": "Electric Energy",
  "ip": "192.168.2.50",
  "port": "12345",
  "username": "testuser",
  "password": "testpassword",
  "interval": 5000
}
```

ip = IP-address of the emon server (can be on the same Pi but can also be located elsewhere on the W3)

interval = time between readings in milliseconds

have fun!

* 0.2.0 Initial release
