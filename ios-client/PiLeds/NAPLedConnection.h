//
//  NAPLedConnection.h
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NAPLedConnectionDelegate;


@interface NAPLedConnection : NSObject

@property(weak) id<NAPLedConnectionDelegate> delegate;

- (BOOL)connectToHost:(NSString*)hostname error:(NSError **)errPtr;
- (BOOL)fetchLedList;
- (BOOL)setLed:(NSString*)ledName shining:(BOOL)shining;

@end

@protocol NAPLedConnectionDelegate

- (void)connectionDidConnect:(NAPLedConnection*)conn;
- (void)connectionDidFail:(NAPLedConnection*)conn;
- (void)connectionDidDisconnect:(NAPLedConnection*)conn;
- (void)connection:(NAPLedConnection*)conn didGetLedList:(NSArray*)list;
- (void)connection:(NAPLedConnection*)conn didSetLed:(NSString*)name toStatus:(BOOL)shining;

@end
