//
//  TourSelectionController.m
//  Tap
//
//  Created by Kyle Jaebker on 6/28/11.
//  Copyright 2011 Indianapolis Museum of Art. All rights reserved.
//

#import "TourSelectionController.h"
#import "KeypadController.h"

@implementation TourSelectionController

@synthesize tourTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationItem] setTitle:@"Tours"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [tourTable deselectRowAtIndexPath:[tourTable indexPathForSelectedRow] animated:animated];
    
	[self willRotateToInterfaceOrientation:[self interfaceOrientation] duration:0.0];
    
	[super viewWillAppear:animated];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    TapAppDelegate *delegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [[delegate availableTours] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TapAppDelegate *delegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSDictionary *tour = [[delegate availableTours] objectAtIndex:indexPath.row];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tour-cell"];
	if (cell == nil) {
		// Create a new reusable table cell
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tour-cell"] autorelease];
        
		[[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
		[[cell detailTextLabel] setFont:[UIFont systemFontOfSize:12]];
		
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	
    // Set the title
    [[cell textLabel] setText:[tour objectForKey:@"Name"]];
    
	return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    TapAppDelegate *delegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *bundle = [[[delegate availableTours] objectAtIndex:indexPath.row] objectForKey:@"BundleName"];
    
    [(TapAppDelegate*)[[UIApplication sharedApplication] delegate] setActiveTour:bundle];
    
    // initialize Google Analytics tracker for selected tracker
    [delegate initializeGATracker];
    
    NSError *error;
    if (![[GANTracker sharedTracker]
          setCustomVariableAtIndex:1 
          name:@"Bundle" 
          value:[[delegate tourBundle] bundleIdentifier]
          withError:&error]) {
        NSLog(@"GANTracker error: %@", error);
    }
    
    if (![[GANTracker sharedTracker] 
          trackPageview:[NSString stringWithFormat: @"{%@}", [[delegate tourBundle] bundleIdentifier]] 
          withError:&error]){
        NSLog(@"GANTracker error: %@", error);
    }  
    
    [delegate initializeStopViewController];
}
@end
