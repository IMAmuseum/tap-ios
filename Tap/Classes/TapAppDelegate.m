#import "TapAppDelegate.h"
#import "KeypadController.h"
#import "StopGroupController.h"


@implementation TapAppDelegate

@synthesize window;
@synthesize navigationController;

@synthesize tourBundle;
@synthesize tourDoc;

@synthesize clickFileURLRef;
@synthesize clickFileObject;
@synthesize errorFileURLRef;
@synthesize errorFileObject;
//@synthesize swooshFileURLRef;
//@synthesize swooshFileObject;

- (IBAction)helpButtonClicked:(id)sender
{
	// Play the help video
	xmlNodePtr helpStopNode = [TourMLUtils getStopInDocument:tourDoc withCode:TAP_HELP_STOP];
	
	if (helpStopNode == NULL)
	{
		[self playError];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
														message:@"Unable to load the help screen!"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return; // failed
	}
	
	[self loadStop:[StopFactory newStopForStopNode:helpStopNode]];
}

- (BOOL)loadStop:(BaseStop*)stop
{
	if ([stop providesViewController]) {
		[navigationController pushViewController:[stop newViewController] animated:YES];		
		[Analytics trackAction:@"view" forStop:[stop getStopId]];
		return YES; // success

	} else {
		// This stop controls itself
		[Analytics trackAction:@"view" forStop:[stop getStopId]];
		return [stop loadStopView];
	}
}

- (void)playClick { AudioServicesPlaySystemSound(clickFileObject); }
- (void)playError { AudioServicesPlaySystemSound(errorFileObject); }
//- (void)playSwoosh { AudioServicesPlaySystemSound(swooshFileObject); }

- (void)dealloc {
	[navigationController release];
    [window release];
	
	[tourBundle release];
	xmlFreeDoc(tourDoc);
		
	AudioServicesDisposeSystemSoundID(clickFileObject);
    CFRelease(clickFileURLRef);
	AudioServicesDisposeSystemSoundID(errorFileObject);
    CFRelease(errorFileURLRef);
	//AudioServicesDisposeSystemSoundID(swooshFileObject);
    //CFRelease(swooshFileURLRef);
	
    [super dealloc];
}

#pragma mark UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    // Load the tour bundle so it is available by identifier
    NSString *tourBundlePath = [[NSBundle mainBundle] pathForResource:TAP_TOUR_BUNDLE_NAME ofType:@"bundle"];
    tourBundle = [NSBundle bundleWithPath:tourBundlePath];
    if (!tourBundle)
    {
        UIAlertView *alert = [[UIAlertView alloc]
            initWithTitle:nil
            message:[NSString stringWithFormat:@"Unable to find the tour bundle, %@!", TAP_TOUR_BUNDLE_NAME]
            delegate:nil
            cancelButtonTitle:@"OK"
            otherButtonTitles:nil];
        [alert show];
        [alert release];
		
		return;
    }
    else
    {
        // Load the bundle to register it
        [tourBundle load];
    }
	
	// Load the TourML file
	NSString *tourDataPath = [tourBundle pathForResource:TOUR_FILENAME ofType:@"xml"];
	if (!tourDataPath)
	{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:[NSString stringWithFormat:@"Unable to load the tour!"]
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
        [alert show];
        [alert release];
		
		return;
	}
	
	// Actually load the xml now
	tourDoc = xmlParseFile([tourDataPath UTF8String]);
	if (tourDoc == NULL)
	{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:[NSString stringWithFormat:@"Unable to load the tour!"]
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
        [alert show];
        [alert release];
		
		return;
	}
	
	// Allocate the sounds
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	clickFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("click"), CFSTR("aif"), NULL);
    AudioServicesCreateSystemSoundID(clickFileURLRef, &clickFileObject);
	errorFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("error"), CFSTR("aif"), NULL);
    AudioServicesCreateSystemSoundID(errorFileURLRef, &errorFileObject);
	//swooshFileURLRef = CFBundleCopyResourceURL(mainBundle, CFSTR("swoosh"), CFSTR("wav"), NULL);
    //AudioServicesCreateSystemSoundID(swooshFileURLRef, &swooshFileObject);
	
	// Add the navigation controller to the window
	[window addSubview:[navigationController view]];
	
	// Add overlay images of the splash to slide apart
	UIImageView *splashTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-title-screen-top.png"]];
	[splashTop setTag:SPLASH_SLIDE_IMAGE_TOP_TAG];
	UIImageView *splashBtm = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tap-title-screen-btm.png"]];
	[splashBtm setTag:SPLASH_SLIDE_IMAGE_BTM_TAG];

	[window addSubview:splashTop];
	[window addSubview:splashBtm];

	// Release extra ref
	[splashTop release];
	[splashBtm release];
	
	// Record the launch event
	[Analytics trackAction:NSLocalizedString(@"launch - en", @"App starting") forStop:@"tap"];
	
    [window makeKeyAndVisible];
}

#pragma mark UIView animation delegate

- (void)splashSlideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[[window viewWithTag:SPLASH_SLIDE_IMAGE_TOP_TAG] removeFromSuperview];
	[[window viewWithTag:SPLASH_SLIDE_IMAGE_BTM_TAG] removeFromSuperview];
	
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
	if (buttonIndex == 1)
	{
		// Play the help video
		xmlNodePtr helpVideoNode = [TourMLUtils getStopInDocument:tourDoc withCode:TAP_HELP_VIDEO_CODE];

		if (helpVideoNode == NULL)
		{
			[self playError];
				
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
															message:NSLocalizedString(@"Unable to load the help video!", @"Missing video error")
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];

			return; // failed
		}

		[self loadStop:[StopFactory newStopForStopNode:helpVideoNode]];
	}
}

#pragma mark UINavigationControllerDelegate

@end
