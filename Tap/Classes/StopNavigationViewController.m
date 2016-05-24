//
//  StopSelectionViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 3/21/13.
//
//

#import "StopNavigationViewController.h"
#import "StopFactory.h"
#import "AppDelegate.h"

@interface StopNavigationViewController ()
- (IBAction)navigateToTourSelection:(id)sender;
- (IBAction)helpButtonClicked:(id)sender;
@end

@implementation StopNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // setup tours back button
    if ([appDelegate tourCount] > 1) {
        UIBarButtonItem *toursButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Tours", nil)
                                                            style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(navigateToTourSelection:)];
        [self.navigationItem setLeftBarButtonItem:toursButton];
    }
    // setup custom background button view for help button
//    UIButton *helpButtonView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 25, 25)];
//    [helpButtonView addTarget:self action:@selector(helpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [helpButtonView setBackgroundImage: [UIImage imageNamed:@"question-mark"] forState: UIControlStateNormal];
//    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithCustomView:helpButtonView];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
//    [self.navigationItem setRightBarButtonItem:helpButton];
}

/**
 * Handle loading a selected stop
 */
- (void)loadStop:(TAPStop *)stopModel
{
    BaseStop *stop = [StopFactory newStopForStopNode:stopModel];
    
    // Log view event
    // TODO: Add new tracking code
    
    if ([stop providesViewController]) {
        UIViewController *viewController = [stop newViewController];
        [self.navigationController pushViewController:viewController animated:YES];
	} else {
		[stop loadStopViewForViewController:self];
	}
}

- (IBAction)navigateToTourSelection:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
    
    // Log view event
    // TODO: Add new tracking code
}

@end
