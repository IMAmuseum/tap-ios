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

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(propertySet, $ps, $ps.name = 'code' AND $ps.value != nil AND ($ps.language == %@ OR $ps.language == nil)).@count > 0", appDelegate.language];
    NSSet *filteredStops = [[NSSet alloc] initWithSet:[appDelegate.currentTour.stop filteredSetUsingPredicate:predicate]];
    NSArray *sortedArray = [[filteredStops allObjects] sortedArrayUsingSelector:@selector(compareByKeycode:)];
    _stops = [[NSArray alloc] initWithArray:sortedArray];
    [filteredStops release];
}

- (void)viewWillAppear:(BOOL)animated
{
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
        
		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
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
