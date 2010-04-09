//
//  Created by Charles Moad <cmoad@imamuseum.org>.
//  Copyright Indianapolis Museum of Art 2009.
//  See LICENCE file included with source.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#import "TourMLUtils.h"
#import "StopFactory.h"
#import "Analytics.h"

#define TAP_TOUR_BUNDLE_NAME        @"<fill_me_in>" // ex. SacredSpain
#define TAP_TOUR_BUNDLE_IDENTIFIER  @"<fill_me_in>" // ex. org.imamuseum.tap.SacredSpain
#define TAP_HELP_STOP				@"411"
#define TAP_HELP_VIDEO_CODE			@"41111"

#define TOUR_FILENAME				@"tour"

#define SPLASH_SLIDE_IMAGE_TOP_TAG	956
#define SPLASH_SLIDE_IMAGE_BTM_TAG	957

@interface TapAppDelegate : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {

    IBOutlet UIWindow *window;
	IBOutlet UINavigationController *navigationController;
    
	NSBundle *tourBundle; // The bundle holding the tour
	xmlDocPtr tourDoc; // The parsed tour document
	
	CFURLRef clickFileURLRef;
    SystemSoundID clickFileObject;
	CFURLRef errorFileURLRef;
    SystemSoundID errorFileObject;
	//CFURLRef swooshFileURLRef;
    //SystemSoundID swooshFileObject;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

@property (nonatomic, retain) NSBundle *tourBundle;
@property xmlDocPtr tourDoc;

@property(readwrite) CFURLRef clickFileURLRef;
@property(readonly) SystemSoundID clickFileObject;
@property(readwrite) CFURLRef errorFileURLRef;
@property(readonly) SystemSoundID errorFileObject;
//@property(readwrite) CFURLRef swooshFileURLRef;
//@property(readonly) SystemSoundID swooshFileObject;

- (IBAction)helpButtonClicked:(id)sender;

- (BOOL)loadStop:(BaseStop*)stop;

- (void)playClick;
- (void)playError;
//- (void)playSwoosh;

@end
