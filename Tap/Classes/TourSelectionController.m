//
//  TourSelectionController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 IMA Labs. All rights reserved.
//

#import "TourSelectionController.h"
#import "AboutViewController.h"
#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPAsset.h"
#import "TAPSource.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@interface TourSelectionController ()
- (IBAction)aboutButtonClicked:(id)sender;
@end

@implementation TourSelectionController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tourFetchedResultsController = _tourFetchedResultsController;

- (void)viewDidLoad 
{
    [super viewDidLoad];

    // setup help button
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"About"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(aboutButtonClicked:)];
    // add about button
    [[self navigationItem] setLeftBarButtonItem:aboutButton];
    [aboutButton release];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    if (self.tourFetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tour" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController *fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                            managedObjectContext:self.managedObjectContext 
                                            sectionNameKeyPath:@"id" 
                                            cacheName:@"Tours"];
        self.tourFetchedResultsController = fetchResultsController;
        self.tourFetchedResultsController.delegate = self;

        [fetchResultsController release];
        [fetchRequest release];
        [sort release];
    }
    
    NSError *error;
    if (![self.tourFetchedResultsController performFetch:&error]) {
        NSLog(@"Error: %@", error);
    }
    
    self.title = @"Tours";
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.tourFetchedResultsController = nil;
}

/**
 * Action method that is fired when the about button is selected
 */
- (IBAction)aboutButtonClicked:(id)sender
{
    AboutViewController *aboutView = [[[AboutViewController alloc] init] autorelease];
    [self presentModalViewController:aboutView animated:YES];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [[self.tourFetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tour-cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tour-cell"] autorelease];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:14]];
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    [appDelegate setCurrentTour:tour];
    
    TAPAsset *image = [[tour getAssetsByUsage:@"asset-image-banner"] objectAtIndex:0];
    
    cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[image source] anyObject] uri]]] autorelease];
    cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[[image source] anyObject] uri]]] autorelease];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    // set the current tour
    [appDelegate loadTour:tour];

    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [appDelegate indexDidChangeForSegmentedControl:appDelegate.navigationSegmentControl];
    }
}

- (void)dealloc 
{
    [_managedObjectContext release];
    [_tourFetchedResultsController release];
    [super dealloc];
}

@end
