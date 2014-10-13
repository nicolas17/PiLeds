//
//  NAPLedModel.h
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NAPLed;

@interface NAPLedModel : NSObject

- (void)connect;
- (void)getStatus;
- (NAPLed*)ledByIndex:(NSUInteger)num;
- (NSUInteger)ledCount;

@end
