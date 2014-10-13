#!/usr/bin/python3

# Licensed under the GPLv2 or later version.
# See LICENSE for more information.

import socketserver

def has_duplicates(lst):
    lst = list(lst)
    return len(lst) > len(set(lst))

class LED:
    def __init__(self, name):
        self.name = name
        self.shining = False

    def on(self):
        self.shining = True

    def off(self):
        self.shining = False

class MyTCPHandler(socketserver.StreamRequestHandler):
    def handle(self):
        print("Got connection from %s:%d" % self.client_address)
        while True:
            data = self.rfile.readline()
            # completely empty = lost connection
            if data == b'': break

            # remove whitespace, including trailing newline
            data = data.strip()
            # if empty here, we got an empty or whitespace-only line
            if data == b'': continue

            params = data.split(b" ")

            if params[0] == b'status':
                self.got_status()
            elif params[0] == b'on':
                self.got_on(params[1].decode("utf8"))
            elif params[0] == b'off':
                self.got_off(params[1].decode("utf8"))
            else:
                self.wfile.write(b"400 no such command\n")

        print("End of stream for %s:%d" % self.client_address)

    def send(self, message):
        self.wfile.write(message.encode("utf8"))

    def got_status(self):
        for led in leds:
            self.send("201 %s %s\n" % (led.name, "on" if led.shining else "off"))
        self.send("202 that's all\n")

    def got_on(self, ledname):
        for led in leds:
            if led.name == ledname:
                led.on()
                self.send("202 %s on\n" % ledname)
                break
        else:
            self.send("301 no such LED '%s'\n" % ledname)

    def got_off(self, ledname):
        for led in leds:
            if led.name == ledname:
                led.off()
                self.send("202 %s off\n" % ledname)
                break
        else:
            self.send("301 no such LED '%s'\n" % ledname)

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True

leds = [LED("A"), LED("B"), LED("C")]

# check that LED names are unique
assert(not has_duplicates(led.name for led in leds))

HOST, PORT = "0.0.0.0", 9997

server = ThreadedTCPServer((HOST, PORT), MyTCPHandler)

server.serve_forever()
