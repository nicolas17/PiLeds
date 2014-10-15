//
//  NAPLedModel.m
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import "NAPLedModel.h"

#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#import "NAPLed.h"

@interface NAPLedModel ()

@property(nonatomic, strong) NSMutableArray* leds;
@property(nonatomic) int conn;
@property(nonatomic,strong) NSMutableData* inputBuffer;

@end

void sendAll(int sock, const char* data) {
    size_t remaining = strlen(data);
    size_t totalSent = 0;
    size_t sent;
    while (remaining > 0) {
        sent = send(sock, data+totalSent, remaining, 0);
        if (sent > 0) {
            totalSent += sent;
            remaining -= sent;
        }
    }
}

@implementation NAPLedModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leds = [[NSMutableArray alloc] init];
        self.inputBuffer = [[NSMutableData alloc] init];
    }
    return self;
}

- (NSUInteger)ledCount {
    return [self.leds count];
}

- (NAPLed *)ledByIndex:(NSUInteger)num {
    return [self.leds objectAtIndex:num];
}

- (void)connect {
    self.conn = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in sockaddr;
    memset(&sockaddr, 0, sizeof(sockaddr));
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_port = htons(9997);
    inet_aton("192.168.0.104", &sockaddr.sin_addr.s_addr);

    connect(self.conn, (struct sockaddr*)&sockaddr, sizeof(sockaddr));
}

- (NSData*)readLine {
    const void* newlinePos = memchr(self.inputBuffer.bytes, '\n', self.inputBuffer.length);
    while (newlinePos == NULL) {
        char buf[256];
        size_t bytesRead = read(self.conn, buf, 256);
        [self.inputBuffer appendBytes:buf length:bytesRead];
        newlinePos = memchr(self.inputBuffer.bytes, '\n', self.inputBuffer.length);
    }
    NSRange lineRange = {0, newlinePos-self.inputBuffer.bytes};
    NSData* retval = [self.inputBuffer subdataWithRange:lineRange];
    lineRange.length += 1; // remove the newline too
    [self.inputBuffer replaceBytesInRange:lineRange withBytes:nil length:0];
    return retval;
}

- (void)getStatus {
    sendAll(self.conn, "status\n");
    while (true) {
        NSData* rawLine = [self readLine];
        NSString* line = [[NSString alloc] initWithData:rawLine encoding:NSUTF8StringEncoding];
        NSLog(@"Got line: %@", line);
        NSArray* components = [line componentsSeparatedByString:@" "];
        if ([[components objectAtIndex:0] isEqualToString:@"201"]) {
            BOOL ledOn = [[components objectAtIndex:2] isEqualToString:@"on"];
            NAPLed* led = [[NAPLed alloc] initWithName:[components objectAtIndex:1]
                                               shining:ledOn];
            [self.leds addObject:led];
        } else if ([[components objectAtIndex:0] isEqualToString:@"202"]) {
            break;
        } else {
            NSLog(@"Got unexpected code %@", [components objectAtIndex:0]);
            assert(0);
        }
    }
}
- (void)toggleLedAtIndex:(NSUInteger)num {
    NAPLed* led = [self.leds objectAtIndex:num];
    NSString* command = [NSString stringWithFormat:@"%s %@\n", led.isShining ? "off" : "on", led.name];
    sendAll(self.conn, command.UTF8String);
    NSData* rawLine = [self readLine];
    NSString* line = [[NSString alloc] initWithData:rawLine encoding:NSUTF8StringEncoding];
    NSLog(@"Got line: %@", line);
    led.isShining = !led.isShining;
}

@end
