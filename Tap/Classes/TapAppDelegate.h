//
//  Created by Charles Moad <cmoad@imamuseum.org>.
//  Copyright Indianapolis Museum of Art 2009.
//  See LICENCE file included with source.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#import "Stop.h"
#import "StopFactory.h"
#import "GANTracker.h"

#define SPLASH_SLIDE_IMAGE_TOP_TAG	956
#define SPLASH_SLIDE_IMAGE_BTM_TAG	957

@interface TapAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {

    IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
    IBOutlet UIBarButtonItem *helpButton;
    
	NSBundle *tourBundle; // The bundle holding the tour
	xmlDocPtr tourDoc; // The parsed tour document
	
	CFURLRef clickFileURLRef;
    SystemSoundID clickFileObject;
	CFURLRef errorFileURLRef;
    SystemSoundID errorFileObject;
	//CFURLRef swooshFileURLRef;
    //SystemSoundID swooshFileObject;
    
    NSDictionary *tapConfig;
    NSMutableDictionary *tourBundles;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UIBarButtonItem *helpButton;

@property (nonatomic, retain) NSBundle *tourBundle;
@property xmlDocPtr tourDoc;
@property (nonatomic, retain) NSDictionary *tapConfig;
@property (nonatomic, retain) NSMutableDictionary *tourBundles;

@property(readwrite) CFURLRef clickFileURLRef;
@property(readonly) SystemSoundID clickFileObject;
@property(readwrite) CFURLRef errorFileURLRef;
@property(readonly) SystemSoundID errorFileObject;
//@property(readwrite) CFURLRef swooshFileURLRef;
//@property(readonly) SystemSoundID swooshFileObject;

- (IBAction)helpButtonClicked:(id)sender;

- (BOOL)loadStop:(id<Stop>)stop;

- (void)playClick;
- (void)playError;
//- (void)playSwoosh;

- (void)setActiveTour:(NSString *)tourBundleName;

- (void)animateSplashImage;
@end
