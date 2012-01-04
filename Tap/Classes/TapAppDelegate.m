#import "TapAppDelegate.h"
#import "KeypadController.h"
#import "StopGroupController.h"
#import "TourSelectionController.h"


@implementation TapAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize helpButton;

@synthesize tourBundle;
@synthesize tourDoc;
@synthesize tapConfig;
@synthesize tourBundles;

@synthesize clickFileURLRef;
@synthesize clickFileObject;
@synthesize errorFileURLRef;
@synthesize errorFileObject;
//@synthesize swooshFileURLRef;
//@synthesize swooshFileObject;

- (void)setActiveTour:(NSString *)tourBundleName
{
    tourBundle = [tourBundles objectForKey:tourBundleName];
    
    // Load the TourML file
    NSString *tourDataPath = [tourBundle pathForResource:[tapConfig objectForKey:@"TapTourFilename"] ofType:@"xml"];
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
}

- (IBAction)helpButtonClicked:(id)sender
{
	// Play the help video
	xmlNodePtr helpStopNode = [TourMLUtils getStopInDocument:tourDoc withCode:[tapConfig objectForKey:@"TapHelpStopCode"]];
	
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

- (BOOL)loadStop:(id<Stop>)stop
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
		
    [tapConfig release];
    [tourBundles release];
    
	AudioServicesDisposeSystemSoundID(clickFileObject);
    CFRelease(clickFileURLRef);
	AudioServicesDisposeSystemSoundID(errorFileObject);
    CFRelease(errorFileURLRef);
	//AudioServicesDisposeSystemSoundID(swooshFileObject);
    //CFRelease(swooshFileURLRef);
	
    [super dealloc];
}
                               
- (void)animateSplashImage
{
    // See if we need to slide apart the splash image
    UIView *splashTop = [window viewWithTag:SPLASH_SLIDE_IMAGE_TOP_TAG];
    UIView *splashBtm = [window viewWithTag:SPLASH_SLIDE_IMAGE_BTM_TAG];
    
    if (splashTop != nil && splashBtm != nil)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDelegate:(TapAppDelegate*)[[UIApplication sharedApplication] delegate]];
        [UIView setAnimationDidStopSelector:@selector(splashSlideAnimationDidStop:finished:context:)];
        
        [splashTop setFrame:CGRectMake(0.0f, -480.0f, CGRectGetWidth([splashTop frame]), CGRectGetHeight([splashTop frame]))];
        [splashBtm setFrame:CGRectMake(0.0f, 480.0f, CGRectGetWidth([splashBtm frame]), CGRectGetHeight([splashBtm frame]))];
        
        [UIView commitAnimations];
    }
}

#pragma mark UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
   
    //Load the config data
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"TapConfig" ofType:@"plist"];
    tapConfig = [[NSDictionary dictionaryWithContentsOfFile:plistPath] retain];

    tourBundles = [[NSMutableDictionary alloc] init];

    for (NSString *bundleName in [tapConfig objectForKey:@"TapTourBundleNames"]) {
        // Load the tour bundle so it is available by identifier
        NSString *tourBundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
       
        NSBundle *bundle = [NSBundle bundleWithPath:tourBundlePath];
        if (!bundle)
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:[NSString stringWithFormat:@"Unable to find the tour bundle, %@!", bundleName]
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
            [bundle load];
            [tourBundles setValue:bundle forKey:bundleName];
        }
    }

    //Load the first tour so that the help video will work
    [self setActiveTour:[[tapConfig objectForKey:@"TapTourBundleNames"] objectAtIndex:0]];

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

    UIViewController *startController;
    if ([tourBundles count] > 1) {
        startController = [[TourSelectionController alloc] init];
    } else {
        startController = [[KeypadController alloc] init];
    }

    [[self navigationController] pushViewController:startController animated:YES];

    helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleDone target:self action:@selector(helpButtonClicked:)];

    [[startController navigationItem] setRightBarButtonItem:helpButton];
    [startController release];

    [window makeKeyAndVisible];
    
    [self animateSplashImage];
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
		xmlNodePtr helpVideoNode = [TourMLUtils getStopInDocument:tourDoc withCode:[tapConfig objectForKey:@"TapHelpStopVideoCode"]];

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
