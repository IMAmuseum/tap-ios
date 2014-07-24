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
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TourCell.h"

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

- (id)init
{
    self = [super init];
    if(self) {
        // add timeout observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:@"ApplicationDidFinishStartAnimation" object:nil];
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
    
    [appDelegate setTourCount:[self.tourFetchedResultsController.fetchedObjects count]];
    
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    TourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TourCell"];

    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TourCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[TourCell class]]) {
                cell = (TourCell *)currentObject;
                break;
            }
        }
    }
    
    // temporarily set the current tour in order to load tour assets
    [appDelegate setCurrentTour:tour];
    
    // set tour title
    [cell.tourTitle setText:(NSString *)tour.title];

    // set tour image
    TAPAsset *tourImageAsset = [[tour getAppResourcesByUsage:@"image"] objectAtIndex:0];
    if (tourImageAsset != nil) {
        NSString *tourImage = [[[tourImageAsset source] anyObject] uri];
        [cell.tourImage setImage:[UIImage imageWithContentsOfFile:tourImage]];
    }
    
    // reset current selected tour to nil
    [appDelegate setCurrentTour:nil];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{    
    return 150.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TAPTour *tour = [self.tourFetchedResultsController objectAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self loadTour:tour];
}

- (void)loadTour:(TAPTour *)tour {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // set the current tour
    [appDelegate setCurrentTour:tour];
    
    TourTabBarViewController *viewController = [[TourTabBarViewController alloc] init];
    [viewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:viewController animated:YES completion:nil];
    
    // Log view event
    // TODO: add new tracking code (selected tour)
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Notification handler

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL helpVideoHasPlayed = (BOOL)[defaults objectForKey:@"helpVideoHasPlayed"];
    
    if (!helpVideoHasPlayed || [[appDelegate.tapConfig objectForKey:@"KioskMode"] boolValue]) {
        // Show a prompt for the help video
        UIAlertView *helpPrompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HelpVideoQuestion", @"Prompt header")
                                                             message:NSLocalizedString(@"HelpVideoExplanation", @"Prompt message")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Skip", @"Skip the video")
                                                   otherButtonTitles:nil];
        [helpPrompt addButtonWithTitle:NSLocalizedString(@"Yes", @"Confirm to watch video")];
        
        [helpPrompt show];
    }
    
    NSUInteger numTours = [self.tourFetchedResultsController.fetchedObjects count];
    if (numTours == 1) {
        TAPTour *tour = [self.tourFetchedResultsController.fetchedObjects objectAtIndex:0];
        [self loadTour:tour];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        [self playHelpVideo];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL helpVideoHasPlayed = (BOOL)[defaults objectForKey:@"helpVideoHasPlayed"];
    
    if (!helpVideoHasPlayed) {
        [defaults setBool:YES forKey:@"helpVideoHasPlayed"];
    }
}

/**
 * Plays help video
 */
- (void)playHelpVideo
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
    
    // Log view event
    // TODO: add new tracking code
}

#pragma mark - Action Methods

- (IBAction)helpButtonClicked:(id)sender
{
    [self playHelpVideo];
}

- (IBAction)selectLanguage:(id)sender
{
    
}

@end
