//
//  StopGroupListController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StopListController.h"

@implementation StopListController

@synthesize stopListTable;
@synthesize stops;

- (void)viewDidLoad
{
    [super viewDidLoad];

    TapAppDelegate *appDelegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSArray *unsortedStops = [[NSArray alloc] initWithArray:PerformXPathQuery([appDelegate tourDoc], @"/tourml:Tour/tourml:Stop/tourml:PropertySet/tourml:Property[@tourml:name='code']/../..")];
    stops = [[NSArray alloc] initWithArray:[unsortedStops sortedArrayUsingFunction:compareByCode context:self]];
    [[self navigationItem] setTitle:@"Index"];
    [unsortedStops release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [stopListTable deselectRowAtIndexPath:[stopListTable indexPathForSelectedRow] animated:animated];
    
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

- (void)dealloc
{
	[stopListTable release];
	[stops release];
    
	[super dealloc];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [stops count];
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

    for (NSDictionary *element in [[stops objectAtIndex:indexPath.row] objectForKey:@"nodeChildArray"]) {
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
    for(NSDictionary *attribute in [[stops objectAtIndex:indexPath.row] objectForKey:@"nodeAttributeArray"]) {
        if([[attribute objectForKey:@"attributeName"] isEqualToString:@"id"]) {
            stopId = [attribute objectForKey:@"nodeContent"];
        }
    }
    
    xmlNodePtr stopNode = [TourMLUtils getStopInDocument:[appDelegate tourDoc] withIdentifier:stopId];

	[appDelegate loadStop:[StopFactory newStopForStopNode:stopNode]];
}

#pragma mark compare
NSInteger compareByCode(id id1, id id2, void *context) {
    NSInteger code1 = 0, code2 = 0;
    for (NSDictionary *attribute in [id1 objectForKey:@"nodeChildArray"]) {
        if ([[attribute objectForKey:@"nodeName"] isEqualToString:@"PropertySet"]) {
            for (NSDictionary *property in [attribute objectForKey:@"nodeChildArray"]) {
                if ([[[[property objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"] isEqualToString:@"code"]) {
                    code1 = [[property objectForKey:@"nodeContent"] intValue];
                }
            }
        }
    }
    
    for (NSDictionary *attribute in [id2 objectForKey:@"nodeChildArray"]) {
        if ([[attribute objectForKey:@"nodeName"] isEqualToString:@"PropertySet"]) {
            for (NSDictionary *property in [attribute objectForKey:@"nodeChildArray"]) {
                if ([[[[property objectForKey:@"nodeAttributeArray"] objectAtIndex:0] objectForKey:@"nodeContent"] isEqualToString:@"code"]) {
                    code2 = [[property objectForKey:@"nodeContent"] intValue];
                }
            }
        }
    }
    
    if(code1 < code2) {
        return -1;
    } else if (code1 == code2) {
        return 0;
    } else {
        return 1;
    }
}

@end
