#!/usr/bin/python

# Licensed under the GPLv2 or later version.
# See LICENSE for more information.

import sys

from twisted.internet import protocol, reactor, endpoints
from twisted.protocols import basic

testmode=False
if len(sys.argv) > 1 and sys.argv[1] == '--testmode':
    testmode=True

if not testmode:
    import RPi.GPIO as GPIO
    GPIO.setmode(GPIO.BCM)

def has_duplicates(lst):
    lst = list(lst)
    return len(lst) > len(set(lst))

class LED:
    def __init__(self, name, gpio):
        self.name = name
        self.gpio = gpio
        self.shining = False
        if not testmode:
            GPIO.setup(self.gpio, GPIO.OUT)

    def on(self):
        if not testmode:
            GPIO.output(self.gpio, GPIO.HIGH)
        self.shining = True

    def off(self):
        if not testmode:
            GPIO.output(self.gpio, GPIO.LOW)
        self.shining = False

class LedProtocol(basic.LineReceiver):
    def __init__(self):
        self.delimiter = '\n'

    def connectionMade(self):
        print("Got connection from %s" % self.transport.getHost())

    def connectionLost(self, reason):
        print("End of stream for %s" % self.transport.getHost())

    def lineReceived(self, line):
        # remove whitespace
        line = line.strip()
        # if empty here, we got an empty or whitespace-only line
        if line == '': return

        params = line.split(" ")

        if params[0] == 'status':
            self.got_status()
        elif params[0] == 'on':
            self.got_on(params[1])
        elif params[0] == 'off':
            self.got_off(params[1])
        else:
            self.sendLine("400 no such command")

    def got_status(self):
        for led in leds:
            self.sendLine("201 %s %s" % (led.name, "on" if led.shining else "off"))
        self.sendLine("202 that's all")

    def got_on(self, ledname):
        for led in leds:
            if led.name == ledname:
                led.on()
                self.sendLine("203 %s on" % ledname)
                print("Turning LED %s on" % ledname)
                break
        else:
            self.sendLine("301 no such LED '%s'" % ledname)

    def got_off(self, ledname):
        for led in leds:
            if led.name == ledname:
                led.off()
                self.sendLine("203 %s off" % ledname)
                print("Turning LED %s off" % ledname)
                break
        else:
            self.sendLine("301 no such LED '%s'" % ledname)


class LedFactory(protocol.Factory):
    def buildProtocol(self, addr):
        return LedProtocol()

leds = [LED("Rojo", 18), LED("Amarillo", 24), LED("Verde", 23)]

# check that LED names are unique
assert(not has_duplicates(led.name for led in leds))

endpoints.serverFromString(reactor, "tcp:9997").listen(LedFactory())
reactor.run()
