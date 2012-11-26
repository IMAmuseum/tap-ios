//
//  StopListController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StopListController.h"
#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"

@implementation StopListController

@synthesize stopListTable = _stopListTable;
@synthesize stops = _stops;

-(id)init 
{
    self = [super init];
    if(self) {
        [self setTitle:@"Index"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAPTour *tour = appDelegate.currentTour;
    TAPAsset *image = [[tour getAssetsByUsage:@"asset-image-banner"] objectAtIndex:0];
    [bannerImage setImage:[UIImage imageWithContentsOfFile:[[[image source] anyObject] uri]]];
    
    // retrieve the current tour's stops
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(propertySet, $ps, $ps.name = 'code' AND $ps.value != nil AND ($ps.language == %@ OR $ps.language == nil)).@count > 0", appDelegate.language];
    NSSet *filteredStops = [[NSSet alloc] initWithSet:[appDelegate.currentTour.stop filteredSetUsingPredicate:predicate]];
    NSArray *sortedArray = [[filteredStops allObjects] sortedArrayUsingSelector:@selector(compareByKeycode:)];
    _stops = [[NSArray alloc] initWithArray:sortedArray];
    [filteredStops release];
    
    // reload the table with the correct tour data
    [_stopListTable reloadData];
    
    // Deselect anything from the table
	[_stopListTable deselectRowAtIndexPath:[_stopListTable indexPathForSelectedRow] animated:animated];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_stops count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tour-cell"];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"stop-cell"] autorelease];
	}

    TAPStop *stop = [_stops objectAtIndex:indexPath.row];
    [[cell textLabel] setText:(NSString *)stop.title];
    
	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadStop:[_stops objectAtIndex:indexPath.row]];
}

- (void)dealloc 
{
    [_stopListTable release];
    [_stops release];
    [super dealloc];
}

@end
