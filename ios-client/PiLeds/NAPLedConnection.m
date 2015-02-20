//
//  NAPLedConnection.m
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import "NAPLedConnection.h"
#import "NAPLed.h"
#import "CocoaAsyncSocket/RunLoop/AsyncSocket.h"

@interface NAPLedConnection ()

@property(nonatomic, strong) AsyncSocket* socket;
@property(nonatomic, strong) NSMutableArray* tempLeds;

@end

@implementation NAPLedConnection : NSObject

- (instancetype)initWithDelegate:(id<NAPLedConnectionDelegate>)delegate {
    self.delegate = delegate;
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    return [super init];
}

- (BOOL)connectToHost:(NSString*)hostname error:(NSError **)errPtr {
    // TODO wrap the NSError
    return [self.socket connectToHost:hostname onPort:9997 error:errPtr];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
    [self.delegate connectionDidFail:self];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    [self.delegate connectionDidConnect:self];
}

- (BOOL)fetchLedList {
    if (![self.socket isConnected]) {
        return NO;
    }
    self.tempLeds = [[NSMutableArray alloc] init];
    [self.socket writeData:[@"status\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:1];
    [self.socket readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:1];
    return YES;
}

- (BOOL)setLed:(NSString*)ledName shining:(BOOL)shining {
    if (![self.socket isConnected]) {
        return NO;
    }
    NSString* cmd = [NSString stringWithFormat:@"%s %@\n", shining?"on":"off", ledName];
    [self.socket writeData:[cmd dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:2];
    [self.socket readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:2];
    return YES;
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

    assert(data.length >= 1);// the data should have at least one byte (the LF terminator)
    assert(((const char*)data.bytes)[data.length-1] == '\n'); // the last byte should be a LF terminator
    data = [data subdataWithRange:NSMakeRange(0, data.length-1)]; // chop off the LF terminator

    NSString* line = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* components = [line componentsSeparatedByString:@" "];

    if (tag == 1) { // 'status' reply
        assert(self.tempLeds); //tempLeds should be initialized by now

        if ([components[0] isEqualToString:@"201"]) {
            BOOL ledOn = [components[2] isEqualToString:@"on"];
            NAPLed* led = [[NAPLed alloc] initWithName:components[1]
                                               shining:ledOn];
            [self.tempLeds addObject:led];
            [self.socket readDataToData:[AsyncSocket LFData] withTimeout:-1 tag:1];
        } else if ([components[0] isEqualToString:@"202"]) {
            [self.delegate connection:self didGetLedList:self.tempLeds];
        } else {
            NSLog(@"Got unexpected code %@", components[0]);
            assert(0); //TODO this shouldn't really be an assert, it's a protocol error
        }
    } else if (tag == 2) { // 'on'/'off' reply
        if ([components[0] isEqualToString:@"203"]) {
            NSString* ledName = components[1];
            BOOL ledOn = [components[2] isEqualToString:@"on"];

            [self.delegate connection:self didSetLed:ledName toStatus:ledOn];
        } else {
            NSLog(@"Got unexpected code %@", components[0]);
            assert(0);
        }
    }
}

@end
