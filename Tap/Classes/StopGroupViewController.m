//
//  StopGroupController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "StopGroupViewController.h"
#import "AppDelegate.h"
#import "StopGroup.h"
#import "StopFactory.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPConnection.h"
#import "StopNavigationViewController.h"

#define HEADER_IMAGE_VIEW_TAG 8637
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@implementation StopGroupViewController

- (id)initWithStop:(StopGroup *)stop
{
    self = [super init];
    if(self) {
        [self setStopGroup:stop];
        [self setTitle: [self.stopGroup getTitle]];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *connections = [[self.stopGroup.model.sourceConnection allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        
        self.stops = [[NSMutableArray alloc] init];
        for (TAPConnection *connection in connections) {
            TAPStop *childStopModel = connection.destinationStop;
            BaseStop *childStop = [StopFactory newStopForStopNode:childStopModel];
            [self.stops addObject:childStop];
        }
    }
	
	return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Set the table background image
	[self.stopGroupTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main-tile.png"]]];
	
    // TODO: clean me up
    UIImageView *headerImage = [self.stopGroup getHeaderImage];
    if (headerImage) {
        [headerImage setTag:HEADER_IMAGE_VIEW_TAG];
        [_stopGroupTable setTableHeaderView:headerImage];
    }
    
    // determine whether or not the stop group has a description in order to layout the table correctly
    if ((NSString *)[self.stopGroup getDescription] != nil) {
        sectionsEnabled = true;
    } else {
        sectionsEnabled = false;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // Deselect anything from the table
	[_stopGroupTable deselectRowAtIndexPath:[_stopGroupTable indexPathForSelectedRow] animated:animated];
}

#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (sectionsEnabled) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1 || !sectionsEnabled) {
        return [self.stops count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 1 || !sectionsEnabled) {
        BaseStop *stop = [self.stops objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-cell"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"];
            
            [[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
            [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        // Set the title
        [[cell textLabel] setText:[stop getTitle]];
        [[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
        [[cell textLabel] setNumberOfLines:0];
        
        // Set the description if available
        [[cell detailTextLabel] setText:[stop getDescription]];
        [[cell detailTextLabel] setLineBreakMode:UILineBreakModeWordWrap];
        [[cell detailTextLabel] setNumberOfLines:0];
        
        // Set the associated icon
        [[cell imageView] setImage:[UIImage imageWithContentsOfFile:[stop getIconPath]]];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-group-description"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-group-description"];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:13]];
        }
        
        // Set the stop group description
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [[cell textLabel] setText:(NSString *)[self.stopGroup getDescription]];
        [[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
        [[cell textLabel] setNumberOfLines:0];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height;
    CGSize constraint;
    
    if (indexPath.section == 1 || !sectionsEnabled) {
        BaseStop *stop = [self.stops objectAtIndex:indexPath.row];
        
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - CELL_DISCLOSURE_WIDTH - CELL_INDENTATION, 20000.0f);
        
        NSString *title = [stop getTitle];
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        NSString *description = [stop getDescription];
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(titleSize.height + descriptionSize.height, 44.0f);
    } else {
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        NSString *description = (NSString *)[self.stopGroup getDescription];
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        height = MAX(descriptionSize.height, 44.0f);
    }
    
    return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if (indexPath.section == 1 || !sectionsEnabled) {
        BaseStop *stop = [_stops objectAtIndex:indexPath.row];
        StopNavigationViewController *controller = (StopNavigationViewController *)[self.navigationController.viewControllers objectAtIndex:0];
        [controller loadStop:stop.model];
    }
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end