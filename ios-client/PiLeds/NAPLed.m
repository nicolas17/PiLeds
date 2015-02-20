//
//  NAPLed.m
//  PiLeds
//
//  Created by Nicolás Alvarez on 13/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import "NAPLed.h"

@implementation NAPLed

- (instancetype)initWithName:(NSString *)name shining:(BOOL)shining {
    _name = name;
    _isShining = shining;
    return self;
}

@end
