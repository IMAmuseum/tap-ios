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

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#define CELL_DISCLOSURE_WIDTH 40.0f
#define CELL_INDENTATION 44.0f

@implementation TourSelectionViewController

- (id)init
{
    self = [super init];
    if(self) {        
        // setup help button
        UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", @"")
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(helpButtonClicked:)];
        
        // set tour selection controller as root and add it to the stack
        UIViewController *tourSelectionController = [[TourSelectionViewController alloc] initWithStyle:UITableViewStylePlain];
        [[self navigationItem] setRightBarButtonItem:helpButton];
        [self.navigationController pushViewController:tourSelectionController animated:YES];
        
        // setup stop navigation controllers
        UIViewController *keypadViewController = [[KeypadViewController alloc] init];
        UIViewController *stopListViewController = [[StopListViewController alloc] init];
        // add help button
        [[keypadViewController navigationItem] setRightBarButtonItem:helpButton];
        [[stopListViewController navigationItem] setRightBarButtonItem:helpButton];
        
        
        // store the stop navigation controllers
        self.stopNavigationControllers = [NSArray arrayWithObjects:keypadViewController, stopListViewController, nil];
        // setup the segmented control
        _navigationSegmentControl = [[UISegmentedControl alloc] initWithItems:[self.stopNavigationControllers arrayByPerformingSelector:@selector(title)]];
        [_navigationSegmentControl setSegmentedControlStyle: UISegmentedControlStyleBar];
        [_navigationSegmentControl addTarget:self
                                      action:@selector(indexDidChangeForSegmentedControl:)
                            forControlEvents:UIControlEventValueChanged];
        
        // add the control the the view controllers
        [[keypadViewController navigationItem] setTitleView:_navigationSegmentControl];
        [[stopListViewController navigationItem] setTitleView:_navigationSegmentControl];
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
    
    self.title = NSLocalizedString(@"Tours", @"");
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.tourFetchedResultsController = nil;
}

- (void)loadTour:(TAPTour *)tour
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCurrentTour:tour];
    [_navigationSegmentControl setSelectedSegmentIndex:0];
    [_navigationSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
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

/**
 * Handle toggling between navigation stop controllers
 */
- (void)indexDidChangeForSegmentedControl:(UISegmentedControl *)segmentedControl {
    NSUInteger index = segmentedControl.selectedSegmentIndex;
    UIViewController *selectedViewController = [self.stopNavigationControllers objectAtIndex:index];
    if ([[self.navigationController viewControllers] count] > 1) {
        [self.navigationController popViewControllerAnimated:NO];
        [self.navigationController pushViewController:selectedViewController animated:NO];
    } else {
        [self.navigationController pushViewController:selectedViewController animated:YES];
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
    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    // set the current tour
    [self loadTour:tour];
    [self indexDidChangeForSegmentedControl:self.navigationSegmentControl];
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
