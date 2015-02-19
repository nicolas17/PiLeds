//
//  NAPLedModel.h
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NAPLed;

@protocol NAPLedModelDelegate
- (void)ledListDidChange;
- (void)ledDidChangeAtIndex:(NSUInteger)index;
@end

@interface NAPLedModel : NSObject

@property(weak) id<NAPLedModelDelegate> delegate;

- (instancetype)initWithDelegate:(id<NAPLedModelDelegate>)delegate;
- (void)start;
- (NSUInteger)ledCount;
- (NAPLed*)ledByIndex:(NSUInteger)num;
- (void)toggleLedAtIndex:(NSUInteger)num;

@end
