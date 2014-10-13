//
//  NAPLed.h
//  PiLeds
//
//  Created by Nicolás Alvarez on 13/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NAPLed : NSObject

@property(nonatomic,strong,readonly) NSString* name;
@property(nonatomic,readonly) BOOL isShining;

- (id)initWithName:(NSString*)name shining:(BOOL)shining;

@end
