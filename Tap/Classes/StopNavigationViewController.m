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
@end

@implementation StopNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *toursButton = [[UIBarButtonItem alloc] initWithTitle:@"Tours"
                                                        style:UIBarButtonItemStyleBordered
                                                        target:self
                                                        action:@selector(navigateToTourSelection:)];
    // setup navigation bar
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", @"")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(helpButtonClicked:)];
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationItem setLeftBarButtonItem:toursButton];
    [self.navigationItem setRightBarButtonItem:helpButton];
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
}

@end
