//
//  NAPLedModel.m
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import "NAPLedModel.h"

@interface NAPLedModel ()

@property(nonatomic, strong) NSMutableArray* leds;
@property(nonatomic, strong) NSInputStream*  inputStream;
@property(nonatomic, strong) NSOutputStream* outputStream;


@end

@implementation NAPLedModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)ledCount {
    return [self.leds count];
}
- (void)connect {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, CFSTR("localhost"), 9997, &readStream, &writeStream);
    self.inputStream = (__bridge_transfer NSInputStream*)readStream;
    self.outputStream = (__bridge_transfer NSOutputStream*)writeStream;
    
    [self.inputStream open];
    [self.outputStream open];
}
- (void)getStatus {
    NSString* command = @"status\n";
    const uint8_t* rawcommand = (const uint8_t*)[command UTF8String];
    [self.outputStream write:rawcommand maxLength:strlen(rawcommand)];
    
}

@end
