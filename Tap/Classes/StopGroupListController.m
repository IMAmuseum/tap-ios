//
//  StopGroupListController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StopGroupListController.h"

@implementation StopGroupListController

@synthesize stopGroupTable;
@synthesize stopGroups;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    TapAppDelegate *appDelegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
    stopGroups = [[NSArray alloc] initWithArray:PerformXPathQuery([appDelegate tourDoc], @"/tourml:Tour/tourml:Stop[@tourml:view='tour_stop_group']/.")];
    
    [[self navigationItem] setTitle:@"Stop Groups"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [stopGroupTable deselectRowAtIndexPath:[stopGroupTable indexPathForSelectedRow] animated:animated];
    
	[self willRotateToInterfaceOrientation:[self interfaceOrientation] duration:0.0];
    
	[super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stopGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tour-cell"];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tour-cell"] autorelease];
        
		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}

    for (NSDictionary *element in [[stopGroups objectAtIndex:indexPath.row] objectForKey:@"nodeChildArray"]) {
        if([[element objectForKey:@"nodeName"] isEqualToString:@"Title"]) {
            [[cell textLabel] setText:[element objectForKey:@"nodeContent"]];
            break;
        }
    }
    
	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    TapAppDelegate *appDelegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *stopId;
    for(NSDictionary *attribute in [[stopGroups objectAtIndex:indexPath.row] objectForKey:@"nodeAttributeArray"]) {
        if([[attribute objectForKey:@"attributeName"] isEqualToString:@"id"]) {
            stopId = [attribute objectForKey:@"nodeContent"];
        }
    }
    
    xmlNodePtr stopNode = [TourMLUtils getStopInDocument:[appDelegate tourDoc] withIdentifier:stopId];

	[appDelegate loadStop:[StopFactory newStopForStopNode:stopNode]];
}

#pragma mark Helper methods


@end
