//
//  NAPLedModel.m
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import "NAPLedModel.h"

#import "NAPLed.h"
#import "NAPLedConnection.h"

@interface NAPLedModel () <NAPLedConnectionDelegate>

@property(nonatomic, strong) NSMutableArray* leds;
@property(nonatomic, strong) NAPLedConnection* conn;

@end

@implementation NAPLedModel

- (instancetype)initWithDelegate:(id<NAPLedModelDelegate>)delegate {
    self = [super init];
    if (self) {
        self.leds = [[NSMutableArray alloc] init];
        self.delegate = delegate;
    }
    return self;
}

- (NSUInteger)ledCount {
    return [self.leds count];
}

- (NAPLed *)ledByIndex:(NSUInteger)num {
    return self.leds[num];
}

- (void)start {
    self.conn = [[NAPLedConnection alloc] initWithDelegate:self];
    [self.conn connectToHost:@"192.168.0.10" error:NULL];
}

- (void)connectionDidConnect:(NAPLedConnection*)conn {
    [conn fetchLedList];
}

- (void)toggleLedAtIndex:(NSUInteger)num {
    NAPLed* led = [self.leds objectAtIndex:num];
    [self.conn setLed:led.name shining:!led.isShining];
}

- (void)connection:(NAPLedConnection*)conn didGetLedList:(NSArray*)list {
    self.leds = [NSMutableArray arrayWithArray:list];
    [self.delegate ledListDidChange];
}

- (void)connection:(NAPLedConnection*)conn didSetLed:(NSString*)name toStatus:(BOOL)shining {
    //int index = [[self.leds indexesOfObjectsPassingTest: ^(id obj, NSUInteger idx, BOOL* stop) {
    //    return [obj.name isEqualTo:name];
    //}] firstIndex];
    NSUInteger index = NSNotFound;
    for (NSUInteger i=0; i<[self.leds count]; i++) {
        if ([self.leds[i].name isEqualToString:name]) {
            index = i;
            break;
        }
    }
    assert(index != NSNotFound);
    [self.leds[index] setIsShining:shining];
    [self.delegate ledDidChangeAtIndex:index];
}

@end
