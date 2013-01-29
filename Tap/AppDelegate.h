//
//  AppDelegate.h
//  Tap
//
//  Created by Daniel Cervantes on 5/19/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>
#import "UINavigationController+Rotation.h"

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

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) TAPTour *currentTour;
@property (nonatomic, strong) NSDictionary *tapConfig;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSArray *stopNavigationControllers;
@property (nonatomic, strong) UISegmentedControl *navigationSegmentControl;

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