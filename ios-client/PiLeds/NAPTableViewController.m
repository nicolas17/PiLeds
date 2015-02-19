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

@interface NAPTableViewController () <NAPLedModelDelegate>

@end

@implementation NAPTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leds = [[NAPLedModel alloc] initWithDelegate:self];
    [self.leds start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NAPLedModelDelegate

- (void)ledListDidChange {
    [self.tableView reloadData];
}

- (void)ledDidChangeAtIndex:(NSUInteger)index {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
    
    NAPLed* led = [self.leds ledByIndex:indexPath.row];
    cell.textLabel.text = led.name;
    if (led.isShining) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.leds toggleLedAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


@end
