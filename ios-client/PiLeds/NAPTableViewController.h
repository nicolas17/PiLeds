//
//  NAPTableViewController.h
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NAPLedModel;

@interface NAPTableViewController : UITableViewController

@property (strong, nonatomic) NAPLedModel* ledModel;

@end
