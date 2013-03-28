//
//  TourSelectionController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TourSelectionViewController.h"
#import "TourTabBarViewController.h"
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
@property (nonatomic, unsafe_unretained) IBOutlet UITableView *tourListTable;
@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *tourFetchedResultsController;

- (IBAction)selectLanguage:(id)sender;
- (IBAction)helpButtonClicked:(id)sender;
@end

@implementation TourSelectionViewController

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
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Select a Tour", @"")];
    
    // Enable language selection if in kiosk mode
    if ([[appDelegate.tapConfig objectForKey:@"KioskMode"] boolValue]) {
        // setup custom language button view
        UIButton *languageSelectionView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 25, 25)];
        [languageSelectionView addTarget:self action:@selector(selectLanguage:) forControlEvents:UIControlEventTouchUpInside];
        [languageSelectionView setBackgroundImage: [UIImage imageNamed:@"globe"] forState: UIControlStateNormal];

        UIBarButtonItem *languageButton = [[UIBarButtonItem alloc] initWithCustomView:languageSelectionView];
        [navigationItem setLeftBarButtonItem:languageButton];
    }
    
    // setup custom help button view
    UIButton *helpButtonView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 25, 25)];
    [helpButtonView addTarget:self action:@selector(helpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [helpButtonView setBackgroundImage: [UIImage imageNamed:@"question-mark"] forState: UIControlStateNormal];
    
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithCustomView:helpButtonView];
    [navigationItem setRightBarButtonItem:helpButton];
    
    [self.navigationBar pushNavigationItem:navigationItem animated:NO];    
}

- (void)viewWillAppear:(BOOL)animated
{  
    // reload the table with the correct tour data
    [self.tourListTable reloadData];
    
    // Deselect anything from the table
	[self.tourListTable deselectRowAtIndexPath:[self.tourListTable indexPathForSelectedRow] animated:animated];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.tourFetchedResultsController = nil;
}

- (IBAction)selectLanguage:(id)sender
{
    
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
    
    TourTabBarViewController *viewController = [[TourTabBarViewController alloc] init];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:viewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
