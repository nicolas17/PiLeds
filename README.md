PiLeds
======

Experimenting with the Raspberry Pi and iOS development.

`server` contains a simple TCP server written in Python 3
that receives commands and turns LEDs on and off via GPIO,
to be run on the Raspberry Pi.
The list of LED names and corresponding GPIO port numbers
is currently hardcoded in the server script.

`ios-client` contains a native iOS application
that connects to the above server.
It displays the list of LEDs
and lets you turn them on and off
by tapping the list items.
It currently has the IP address of the server hardcoded
(in `NAPLedModel.m`),
so you need to adjust that if you want to run it.

To test the iOS application without a Raspberry Pi,
run the server with `--testmode`.
