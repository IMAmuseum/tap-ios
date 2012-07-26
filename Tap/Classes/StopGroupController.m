//
//  StopGroupController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StopGroupController.h"
#import "AppDelegate.h"
#import "AudioControlViewController.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPConnection.h"

#define HEADER_IMAGE_VIEW_TAG 8637
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@interface StopGroupController ()

@end

@implementation StopGroupController

@synthesize stopGroupTable = _stopGroupTable;
@synthesize bannerImage = _bannerImage;
@synthesize stopGroup = _stopGroup;
@synthesize stops = _stops;

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if(self) {
        [self setTitle:(NSString *)stop.title];
        [self setStopGroup:stop];
        
        NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES] autorelease];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *connections = [[stop.sourceConnection allObjects] sortedArrayUsingDescriptors:sortDescriptors];
        
        _stops = [[NSMutableArray alloc] init];
        for (TAPConnection *connection in connections) {
            [_stops addObject:connection.destinationStop];
        }
        
        AudioControlViewController *audioControl = [[AudioControlViewController alloc] init];
        [self.view addSubview:audioControl.view];
    }
	
	return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // Set the table background image
	[self.stopGroupTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main-tile.png"]]];

    TAPAsset *headerAsset = [[_stopGroup getAssetsByUsage:@"header_image"] objectAtIndex:0];
    if (headerAsset != nil) {
        NSString *headerImageSrc = [[[headerAsset source] anyObject] uri];
        UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:headerImageSrc]];
		[headerImage setTag:HEADER_IMAGE_VIEW_TAG];
		[_stopGroupTable setTableHeaderView:headerImage];
		[headerImage release];
    }
    
    // determine whether or not the stop group has a description in order to layout the table correctly
    if ((NSString *)_stopGroup.desc != nil) {
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
    
    if (!sectionsEnabled) return @"";
    
    if(section == 0) {
        return @"";
    } else {
        return @"Find Out More";
    }
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
        TAPStop *stop = [self.stops objectAtIndex:indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-cell"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"] autorelease];
            
            [[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
            [[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
        
        cell.indentationWidth = CELL_INDENTATION;
        cell.indentationLevel = 1;
        
        // Set the title
        [[cell textLabel] setText:(NSString *)stop.title];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        
        // Set the description if available
        [[cell detailTextLabel] setText:(NSString *)stop.desc];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;
        
        // Set the associated icon
        UIImage *icon = [[UIImage alloc] initWithContentsOfFile:[stop getIconPath]];
        UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
        [iconView setFrame:CGRectMake(20, 10, icon.size.width, icon.size.height)];
        [cell addSubview:iconView];
        
        [iconView release];
        [icon release];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"stop-group-description"];
        if (cell == nil) {
            // Create a new reusable table cell
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-group-description"] autorelease];
            [[cell textLabel] setFont:[UIFont systemFontOfSize:12]];
        }
        
        // Set the stop group description
        [[cell textLabel] setText:(NSString *)_stopGroup.desc];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height;
    CGSize constraint;
    
    if (indexPath.section == 1 || !sectionsEnabled) {
        TAPStop *stop = [stops objectAtIndex:indexPath.row];
        
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - CELL_DISCLOSURE_WIDTH - CELL_INDENTATION, 20000.0f);
        
        NSString *title = (NSString *)stop.title;
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        NSString *description = (NSString *)stop.desc;
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        
        height = MAX(titleSize.height + descriptionSize.height, 44.0f);
    } else {
        constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
        NSString *description = (NSString *)_stopGroup.desc;
        CGSize descriptionSize = [description sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        height = MAX(descriptionSize.height, 44.0f);
    }
    
    return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    if (indexPath.section == 1 || !sectionsEnabled) {
        TAPStop *stop = [_stops objectAtIndex:indexPath.row];
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] loadStop:stop];   
    }
}

- (void)dealloc 
{
    [_stopGroupTable release];
    [_bannerImage release];
    [_stopGroup release];
    [_stops release];
    [super dealloc];
}

@end
