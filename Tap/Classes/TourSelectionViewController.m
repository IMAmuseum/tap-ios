//
//  TourSelectionController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TourSelectionViewController.h"
#import "AppDelegate.h"
#import "TAPTour.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@implementation TourSelectionViewController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize tourFetchedResultsController = _tourFetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style 
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
    
    self.title = NSLocalizedString(@"Tours", @"");
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.tourFetchedResultsController = nil;
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
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    [[cell textLabel] setText:(NSString *)tour.title];
    [[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
    [[cell textLabel] setNumberOfLines:0];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height;
    CGSize constraint;
    
    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    
    constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - CELL_DISCLOSURE_WIDTH - CELL_INDENTATION, 20000.0f);
    
    NSString *title = (NSString *)tour.title;
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    
    height = MAX(titleSize.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
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

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc 
{
    [_managedObjectContext release];
    [_tourFetchedResultsController release];
    [super dealloc];
}

@end
