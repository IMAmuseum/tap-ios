//
//  TourSelectionController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TourSelectionViewController.h"
#import "AppDelegate.h"
#import "UINavigationController+Rotation.h"
#import "KeypadViewController.h"
#import "StopListViewController.h"
#import "BaseStop.h"
#import "StopFactory.h"
#import "TAPTour.h"

#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@interface TourSelectionViewController()
@property (nonatomic, unsafe_unretained) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, unsafe_unretained) IBOutlet UITableView *stopListTable;
@property (nonatomic, strong) NSArray *stopNavigationControllers;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *tourFetchedResultsController;
@end

@implementation TourSelectionViewController

- (id)init
{
    self = [super init];
    if(self) {

        // setup stop navigation controllers
        UIViewController *keypadViewController = [[KeypadViewController alloc] init];
        UIViewController *stopListViewController = [[StopListViewController alloc] init];

        
        // store the stop navigation controllers
        self.stopNavigationControllers = [NSArray arrayWithObjects:keypadViewController, stopListViewController, nil];
   
    }
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
    }
    
    NSError *error;
    if (![self.tourFetchedResultsController performFetch:&error]) {
        NSLog(@"Error: %@", error);
    }
    
    // setup navigation bar
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", @"")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(helpButtonClicked:)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Tours", @"")];
    [navigationItem setRightBarButtonItem:helpButton];
    [self.navigationBar pushNavigationItem:navigationItem animated:NO];    
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.tourFetchedResultsController = nil;
}

/**
 * Action method that is fired when the help button is selected
 */
- (IBAction)helpButtonClicked:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *videoSrc = [appDelegate.tapConfig objectForKey:@"HelpVideo"];
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:[[videoSrc lastPathComponent] stringByDeletingPathExtension]
                                                          ofType:[[videoSrc lastPathComponent] pathExtension] inDirectory:nil];
	if (!videoPath) return;
	
	NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
	MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
	[[movieController moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
    [self presentMoviePlayerViewControllerAnimated:movieController];
}

/**
 * Handle loading a selected stop
 */
- (void)loadStop:(TAPStop *)stopModel
{
    BaseStop *stop = [StopFactory newStopForStopNode:stopModel];
    
    if ([stop providesViewController]) {
        UIViewController *viewController = [stop newViewController];
        [self.navigationController pushViewController:viewController animated:YES];
	} else {
		[stop loadStopView];
	}
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tour-cell"];
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    // set the current tour
    [appDelegate setCurrentTour:tour];
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
