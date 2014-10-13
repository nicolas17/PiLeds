//
//  NAPTableViewController.m
//  PiLeds
//
//  Created by Nicolás Alvarez on 12/10/14.
//  Copyright (c) 2014 Nicolás Alvarez. All rights reserved.
//

#import "NAPTableViewController.h"
#import "NAPLedModel.h"
#import "NAPLed.h"

@interface NAPTableViewController ()

@end

@implementation NAPTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leds = [[NAPLedModel alloc] init];
    [self.leds connect];
    [self.leds getStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.leds ledCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LED" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.leds ledByIndex:indexPath.row].name;
    
    return cell;
}


@end
