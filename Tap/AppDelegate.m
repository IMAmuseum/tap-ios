//
//  AppDelegate.m
//  Tap
//
//  Created by Daniel Cervantes on 5/19/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "AppDelegate.h"
#import "TourMLParser.h"
#import "TourSelectionController.h"
#import "KeypadController.h"
#import "StopListController.h"
#import "StopGroupController.h"
#import "AudioStopController.h"
#import "VideoStopController.h"
#import "ImageGalleryViewController.h"
#import "TAPTour.h"
#import "TAPStop.h"
#import "TAPAssetRef.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"
#import "TAPProperty.h"
#import "TAPConnection.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SPLASH_SLIDE_IMAGE_TOP_TAG	956
#define SPLASH_SLIDE_IMAGE_BTM_TAG	957

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize rootViewController = _rootViewController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize currentTour = _currentTour;
@synthesize tapConfig = _tapConfig;
@synthesize language = _language;
@synthesize stopNavigationControllers = _stopNavigationControllers;
@synthesize navigationSegmentControl = _navigationSegmentControl;
@synthesize clickFileURLRef;
@synthesize clickFileObject;
@synthesize errorFileURLRef;
@synthesize errorFileObject;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    // Add the navigation controller to the window
    [self.window addSubview:[self.navigationController view]];
    
    // Allocate the sounds
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    clickFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("click"), CFSTR("aif"), NULL);
    AudioServicesCreateSystemSoundID(clickFileURLRef, &clickFileObject);
    errorFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("error"), CFSTR("aif"), NULL);
    AudioServicesCreateSystemSoundID(errorFileURLRef, &errorFileObject);
    
    CFRelease(clickFileURLRef);
    CFRelease(errorFileURLRef);
    
    // get tap configurations
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"TapConfig" ofType:@"plist"];
    self.tapConfig = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // set default language
    [self setLanguage:@"en"];
    
    // load tour data
    [TourMLParser loadTours];
    
    // setup fetch request for tour entity
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tour" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error;
    // retrieve tours
    NSArray *tours = [self.managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    // setup help button
    UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" 
                                                                   style:UIBarButtonItemStyleDone 
                                                                  target:self 
                                                                  action:@selector(helpButtonClicked:)];    
    
    // set tour selection controller as root and add it to the stack
    UIViewController *tourSelectionController = [[TourSelectionController alloc] initWithStyle:UITableViewStylePlain];
    [self setRootViewController:tourSelectionController];
    [[self.rootViewController navigationItem] setRightBarButtonItem:helpButton];
    [self.navigationController pushViewController:tourSelectionController animated:YES];
    [tourSelectionController release];

    // setup stop navigation controllers
    UIViewController *keypadController = [[KeypadController alloc] init];
    UIViewController *stopListController = [[StopListController alloc] init];
    // add help button
    [[keypadController navigationItem] setRightBarButtonItem:helpButton];
    [[stopListController navigationItem] setRightBarButtonItem:helpButton];
    
    [helpButton release];
    
    // store the stop navigation controllers 
    self.stopNavigationControllers = [NSArray arrayWithObjects:keypadController, stopListController, nil];
    // setup the segmented control
    _navigationSegmentControl = [[UISegmentedControl alloc] initWithItems:[self.stopNavigationControllers arrayByPerformingSelector:@selector(title)]];
    [_navigationSegmentControl setSegmentedControlStyle: UISegmentedControlStyleBar];
    [_navigationSegmentControl addTarget:self 
                                action:@selector(indexDidChangeForSegmentedControl:) 
                                forControlEvents:UIControlEventValueChanged];
    
    // add the control the the view controllers
    [[keypadController navigationItem] setTitleView:_navigationSegmentControl];
    [[stopListController navigationItem] setTitleView:_navigationSegmentControl];
    
    [keypadController release];
    [stopListController release];
    
    // Add overlay images of the splash to slide apart
    UIImageView *splashTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-title-screen-top.png"]];
    [splashTop setTag:SPLASH_SLIDE_IMAGE_TOP_TAG];
    UIImageView *splashBtm = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-title-screen-btm.png"]];
    [splashBtm setTag:SPLASH_SLIDE_IMAGE_BTM_TAG];
    
    [self.window addSubview:splashTop];
    [self.window addSubview:splashBtm];
    
    // Release extra ref
    [splashTop release];
    [splashBtm release];
    
    // initialize only if we're not coming from a url
    if (![launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        // if only one tour exists initialize it and add it to the stack
        if ([tours count] == 1) {
            // set the current tour
            [self loadTour:[tours objectAtIndex:0]];
        }
        [self animateSplashImage];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSError *error;
    
    if (url == nil) {
        [self animateSplashImage];
        return NO;
    }
    
    NSString *tourId = [url host];
    NSString *stopId = nil;
    
    if ([[url pathComponents] count] == 2) {
        stopId = [[url pathComponents] objectAtIndex:1];
    }
    
    // setup fetch request for tour entity
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Tour" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", tourId];
    [request setPredicate:predicate];
    

    // retrieve tours
    NSArray *tours = [self.managedObjectContext executeFetchRequest:request error:&error];
    [request release];
    
    if (![tours count]) {
        [self animateSplashImage];
        return NO;
    }
    [self loadTour:[tours objectAtIndex:0]];
    
    if (stopId != nil) {
        TAPStop *stop = [_currentTour stopFromId:stopId];
        if (stop != nil) {
            [self loadStop:stop];
        }
    }
    
    [self animateSplashImage];
    return YES;
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

- (void)loadTour:(TAPTour *)tour
{
    [self setCurrentTour:tour];
    // set the default controller
    [_navigationSegmentControl setSelectedSegmentIndex:0];
    // starting in ios5 setSelectedSegmentIndex no longer triggers an event so we must do this explicitly for ios5 and greater
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        [_navigationSegmentControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

/**
 * Handle loading a selected stop
 */
- (void)loadStop:(TAPStop *)stop
{ 
    // Initialize the appropriate view controller
    if ([stop.view isEqualToString:@"tour_image_stop"]) {
        ImageGalleryViewController *viewController = [[ImageGalleryViewController alloc] initWithStop:stop];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    } else if ([stop.view isEqualToString:@"tour_stop_group"]) {
        StopGroupController *viewController = [[StopGroupController alloc] initWithStop:stop];
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
    } else if ([stop.view isEqualToString:@"tour_video_stop"]) {
        VideoStopController *viewController = [[VideoStopController alloc] initWithStop:stop];
        [self.navigationController presentMoviePlayerViewControllerAnimated:viewController];
        [viewController release];
    } else if ([stop.view isEqualToString:@"tour_audio_stop"]) {
        AudioStopController *viewController = [[AudioStopController alloc] initWithStop:stop];
        [self.navigationController presentMoviePlayerViewControllerAnimated:viewController];
        [viewController release];
    } else {
        NSLog(@"Stop type doesn't exist.");
    }
}

/**
 * Action method that is fired when the help button is selected
 */
- (IBAction)helpButtonClicked:(id)sender
{    
	// Play the help video
	[self playHelpVideo];
}

/**
 * Handles the applications introduction animation
 */
- (void)animateSplashImage 
{
    // See if we need to slide apart the splash image
    UIView *splashTop = [self.window viewWithTag:SPLASH_SLIDE_IMAGE_TOP_TAG];
    UIView *splashBtm = [self.window viewWithTag:SPLASH_SLIDE_IMAGE_BTM_TAG];
    
    if (splashTop != nil && splashBtm != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDelegate:(AppDelegate *)[[UIApplication sharedApplication] delegate]];
        [UIView setAnimationDidStopSelector:@selector(splashSlideAnimationDidStop:finished:context:)];
        
        [splashTop setFrame:CGRectMake(0.0f, -480.0f, CGRectGetWidth([splashTop frame]), CGRectGetHeight([splashTop frame]))];
        [splashBtm setFrame:CGRectMake(0.0f, 480.0f, CGRectGetWidth([splashBtm frame]), CGRectGetHeight([splashBtm frame]))];
        
        [UIView commitAnimations];
    }
}

/**
 * Plays help video
 */
- (void)playHelpVideo 
{
    NSString *videoSrc = [self.tapConfig objectForKey:@"TapHelpVideo"];
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:[[videoSrc lastPathComponent] stringByDeletingPathExtension]
                                                          ofType:[[videoSrc lastPathComponent] pathExtension] inDirectory:nil];
	if (!videoPath) return;
	
	NSURL *videoURL = [NSURL fileURLWithPath:videoPath];	
	MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
	[[movieController moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
	[[[self navigationController] visibleViewController] presentMoviePlayerViewControllerAnimated:movieController];
    
    [movieController release];
}

#pragma mark Global system sounds

- (void)playClick { AudioServicesPlaySystemSound(clickFileObject); }
- (void)playError { AudioServicesPlaySystemSound(errorFileObject); }

#pragma mark UIView animation delegate

- (void)splashSlideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[[self.window viewWithTag:SPLASH_SLIDE_IMAGE_TOP_TAG] removeFromSuperview];
	[[self.window viewWithTag:SPLASH_SLIDE_IMAGE_BTM_TAG] removeFromSuperview];
	
	// Show a prompt for the help video
	UIAlertView *helpPrompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Watch help video?", @"Prompt header")
														 message:NSLocalizedString(@"Get an overview of how to use and make the most of TAP.", @"Prompt message")
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Skip", @"Skip the video")
											   otherButtonTitles:nil];
	[helpPrompt addButtonWithTitle:NSLocalizedString(@"Yes", @"Confirm to watch video")];
	
	[helpPrompt show];
	[helpPrompt release];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == 1) {
        [self playHelpVideo];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext 
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext 
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel 
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tap" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tap.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory 
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)dealloc 
{
    [_window release];
    [_navigationController release];
    [_rootViewController release];
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [_currentTour release];
    [_tapConfig release];
    [_language release];
    [_stopNavigationControllers release];
    [_navigationSegmentControl release];
    
	AudioServicesDisposeSystemSoundID(clickFileObject);
	AudioServicesDisposeSystemSoundID(errorFileObject);
    
    [super dealloc];
}

@end

#pragma mark - PerformSelector Category
@implementation NSArray (PerformSelector)
/**
 * Create a new array based on a selector
 */
- (NSArray *)arrayByPerformingSelector:(SEL)selector {
    NSMutableArray * results = [NSMutableArray array];
    
    for (id object in self) {
        id result = [object performSelector:selector];
        [results addObject:result];
    }
    
    return results;
}
@end
