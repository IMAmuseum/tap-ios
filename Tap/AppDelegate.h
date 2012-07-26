//
//  AppDelegate.h
//  Tap
//
//  Created by Daniel Cervantes on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@class TAPTour, TAPStop, TAPAsset, TAPAssetRef, TAPConnection, TAPContent, TAPProperty, TAPSource;

@interface AppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UINavigationController *navigationController;
    IBOutlet UISegmentedControl *navigationSegmentControl;
    
    UIViewController *rootViewController;
    
    TAPTour *currentTour;
    NSDictionary *tapConfig;
    NSString *language;
    NSArray *stopNavigationControllers;
    
    CFURLRef clickFileURLRef;
    SystemSoundID clickFileObject;
	CFURLRef errorFileURLRef;
    SystemSoundID errorFileObject;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UIViewController *rootViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) TAPTour *currentTour;
@property (nonatomic, retain) NSDictionary *tapConfig;
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSArray *stopNavigationControllers;
@property (nonatomic, retain) UISegmentedControl *navigationSegmentControl;

@property (readwrite) CFURLRef clickFileURLRef;
@property (readonly) SystemSoundID clickFileObject;
@property (readwrite) CFURLRef errorFileURLRef;
@property (readonly) SystemSoundID errorFileObject;

- (void)indexDidChangeForSegmentedControl:(UISegmentedControl *)segmentedControl;
- (void)loadTour:(TAPTour *)tour;
- (void)loadStop:(TAPStop *)stop;
- (IBAction)helpButtonClicked:(id)sender;
- (void)animateSplashImage;
- (void)playHelpVideo;
- (void)playClick;
- (void)playError;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

@interface NSArray (PerformSelector)
- (NSArray *)arrayByPerformingSelector:(SEL)selector;
@end