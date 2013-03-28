//
//  AppDelegate.m
//  Tap
//
//  Created by Daniel Cervantes on 5/19/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPStop.h"
#import "TAPAssetRef.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"
#import "TAPProperty.h"
#import "TAPConnection.h"
#import "StopFactory.h"
#import "TourMLParser.h"
#import "TourSelectionViewController.h"
#import "StopNavigationViewController.h"

#define SPLASH_SLIDE_IMAGE_TOP_TAG	956
#define SPLASH_SLIDE_IMAGE_BTM_TAG	957

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize clickFileURLRef;
@synthesize clickFileObject;
@synthesize errorFileURLRef;
@synthesize errorFileObject;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
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
    [self setLanguage: [[NSLocale preferredLanguages] objectAtIndex:0]];
    
    // load tour data
    [TourMLParser loadTours];
    
    // retrieve tracker id
    
    TourSelectionViewController *viewController = [[TourSelectionViewController alloc] init];
    [self setRootViewController:viewController];
    [self.window setRootViewController:viewController];
    
    // Add overlay images of the splash to slide apart
    UIImageView *splashTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-title-screen-top.png"]];
    [splashTop setTag:SPLASH_SLIDE_IMAGE_TOP_TAG];
    UIImageView *splashBtm = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-title-screen-btm.png"]];
    [splashBtm setTag:SPLASH_SLIDE_IMAGE_BTM_TAG];
    
    [self.window addSubview:splashTop];
    [self.window addSubview:splashBtm];
    
    // initialize only if we're not coming from a url
    if (![launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
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
    
    if (![tours count]) {
        [self animateSplashImage];
        return NO;
    }
//    [(TourSelectionViewController *)self.rootViewController loadTour:[tours objectAtIndex:0]];
//    
//    // if a stop was specified attempt to load the stop
//    if (stopId != nil) {
//        TAPStop *stop = [_currentTour stopFromId:stopId];
//        if (stop != nil) {
//            [(TourSelectionViewController *)self.rootViewController loadStop:stop];
//        }
//    }
    
    [self animateSplashImage];
    return YES;
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

#pragma mark Global system sounds

- (void)playClick { AudioServicesPlaySystemSound(self.clickFileObject); }
- (void)playError { AudioServicesPlaySystemSound(self.errorFileObject); }

#pragma mark UIView animation delegate

- (void)splashSlideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[[self.window viewWithTag:SPLASH_SLIDE_IMAGE_TOP_TAG] removeFromSuperview];
	[[self.window viewWithTag:SPLASH_SLIDE_IMAGE_BTM_TAG] removeFromSuperview];
	
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ApplicationDidFinishStartAnimation" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

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

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel 
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tap" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tap.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory 
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)dealloc 
{
	AudioServicesDisposeSystemSoundID(clickFileObject);
	AudioServicesDisposeSystemSoundID(errorFileObject);
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
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id result = [object performSelector:selector];
        #pragma clang diagnostic pop
        [results addObject:result];
    }
    
    return results;
}
@end
