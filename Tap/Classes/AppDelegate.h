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

@class TAPTour, TAPStop;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) TAPTour *currentTour;
@property (nonatomic, strong) NSDictionary *tapConfig;
@property (nonatomic, strong) NSString *language;

@property (readwrite) CFURLRef clickFileURLRef;
@property (readonly) SystemSoundID clickFileObject;
@property (readwrite) CFURLRef errorFileURLRef;
@property (readonly) SystemSoundID errorFileObject;

- (void)animateSplashImage;
- (void)playClick;
- (void)playError;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

@interface NSArray (PerformSelector)
- (NSArray *)arrayByPerformingSelector:(SEL)selector;
@end