#import "TapAppDelegate.h"

@implementation TapAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize helpButton;
@synthesize toggleViewButton;

@synthesize currentViewController;

@synthesize tourBundle;
@synthesize tourDoc;
@synthesize tapConfig;
@synthesize tourBundles;
@synthesize availableTours;

@synthesize clickFileURLRef;
@synthesize clickFileObject;
@synthesize errorFileURLRef;
@synthesize errorFileObject;

// Google Analytic settings. TODO: Read from TourML Bundle
static const NSInteger ganDispatchPeriod = 10;

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
    NSError *error;
    if (![[GANTracker sharedTracker]
          setCustomVariableAtIndex:1 
          name: @"Bundle" 
          value: [tourBundle bundleIdentifier]
          withError: &error]) {
        NSLog(@"GANTracker error: %@", error);
    }
    
    if (![[GANTracker sharedTracker] 
          trackEvent:@"Help" 
          action:@"clicked" 
          label:@"Requested help" 
          value: 1
          withError: &error]){
        NSLog(@"GANTracker error: %@", error);
    }
    
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

- (IBAction)toggleView:(id)sender
{
    NSString *currentController = NSStringFromClass([currentViewController class]);
    UIViewController *newController;
    
    NSMutableArray *controllers = [[self.navigationController.viewControllers mutableCopy] autorelease];
    [controllers removeLastObject];
    
    self.navigationController.viewControllers = controllers;
    
    UIButton *button = (UIButton*)toggleViewButton.customView;
    
    if([currentController isEqualToString:@"StopGroupListController"]) {
        newController = [[KeypadController alloc] init];
        [button setBackgroundImage: [UIImage imageNamed:@"icon-list.png"] forState: UIControlStateNormal];
    } else {
        newController = [[StopGroupListController alloc] init];
        [button setBackgroundImage: [UIImage imageNamed:@"icon-numbers.png"] forState: UIControlStateNormal];
    }

    NSArray *buttonItems = [[NSArray alloc] initWithObjects:helpButton, toggleViewButton, nil];
    [[newController navigationItem] setRightBarButtonItems:buttonItems];
    
    [UIView transitionWithView:self.navigationController.view
        duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight
        animations:^{ 
            [self.navigationController 
            pushViewController:newController 
            animated:NO];
        } completion:NULL];
    
    currentViewController = newController;
    
    [buttonItems release];
    [newController release];
}

- (BOOL)loadStop:(id<Stop>)stop
{
    NSError *error;
    if (![[GANTracker sharedTracker]
          setCustomVariableAtIndex:1 
          name:@"Bundle" 
          value:[tourBundle bundleIdentifier]
          withError:&error]) {
        NSLog(@"GANTracker error: %@", error);
    }
    
    if (![[GANTracker sharedTracker] 
          trackPageview:[NSString stringWithFormat: @"{%@}/%@", [tourBundle bundleIdentifier], [stop getStopId]] 
          withError:&error]){
        NSLog(@"GANTracker error: %@", error);
        
    }
    
	if ([stop providesViewController]) {
        [navigationController pushViewController:[stop newViewController] animated:YES];        
		return YES; // success

	} else {
		// This stop controls itself
		return [stop loadStopView];
	}
}

- (void)initializeStopViewController
{
    currentViewController = [[KeypadController alloc] init];
    
    [[self navigationController] pushViewController:currentViewController animated:YES];
    
    UIButton *toggleView = [[UIButton alloc] initWithFrame: CGRectMake (0, 0, 30, 30)];
    [toggleView addTarget:self action:@selector(toggleView:) forControlEvents:UIControlEventTouchUpInside];
    [toggleView setBackgroundImage: [UIImage imageNamed:@"icon-list.png"] forState: UIControlStateNormal];
    toggleViewButton = [[UIBarButtonItem alloc] initWithCustomView:toggleView];
    
    NSArray *buttonItems = [[NSArray alloc] initWithObjects:helpButton, toggleViewButton, nil];
    [[currentViewController navigationItem] setRightBarButtonItems:buttonItems];
    
    [buttonItems release];
}

- (void)initializeGATracker
{
    NSString *gaTrackerCode = [TourMLUtils getGATrackerCode:tourDoc];
    // Initialize Google Analytics tracker
    [[GANTracker sharedTracker] startTrackerWithAccountID:gaTrackerCode 
                                           dispatchPeriod:ganDispatchPeriod delegate:nil];
}

- (void)playClick { AudioServicesPlaySystemSound(clickFileObject); }
- (void)playError { AudioServicesPlaySystemSound(errorFileObject); }

- (void)dealloc {
	[navigationController release];
    [window release];
	
    [toggleViewButton release];
	[tourBundle release];
	xmlFreeDoc(tourDoc);
		
    [tapConfig release];
    [tourBundles release];
    
	AudioServicesDisposeSystemSoundID(clickFileObject);
    CFRelease(clickFileURLRef);
	AudioServicesDisposeSystemSoundID(errorFileObject);
    CFRelease(errorFileURLRef);
    
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
    availableTours = [[NSMutableArray alloc] init];

    NSString *bundleDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Bundles"];
    NSDirectoryEnumerator *bundleEnum;
    bundleEnum = [[NSFileManager defaultManager] enumeratorAtPath:bundleDir];
    if(bundleEnum)
    {
        NSString *currBundlePath;
        while(currBundlePath = [bundleEnum nextObject])
        {
            if([[currBundlePath pathExtension] isEqualToString:@"bundle"])
            {                
                NSString *tourBundlePath = [bundleDir stringByAppendingPathComponent:currBundlePath];
                NSBundle *bundle = [NSBundle bundleWithPath:tourBundlePath];
                if (!bundle)
                {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:nil
                                          message:[NSString stringWithFormat:@"Unable to find the tour bundle, %@!", @"ENTER BUNDLE NAME"]
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    
                    return;
                }
                else
                {                    
                    NSString *bundleName = [[bundle infoDictionary] objectForKey:@"CFBundleName"];
                    [tourBundles setValue:bundle forKey:bundleName];
                 
                    // Load the bundle to register it
                    [bundle load];                    
                    
                    [self setActiveTour:bundleName];
                    
                    NSString *tourName = [TourMLUtils getTourTitle:tourDoc];
                    
                    NSDictionary *tour = [[NSMutableDictionary alloc] init];
                    [tour setValue:tourName forKey:@"Name"];
                    [tour setValue:bundleName forKey:@"BundleName"];
                    [availableTours addObject:tour];
                }
            }
        }
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

    // initialize Google Analytics tracker
    [self initializeGATracker];
    
    UIViewController *startController;
    
    helpButton = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleDone target:self action:@selector(helpButtonClicked:)];
    
    currentViewController = [[StopGroupListController alloc] init];
    
    if ([tourBundles count] > 1) {
        startController = [[TourSelectionController alloc] init];
        [[startController navigationItem] setRightBarButtonItem:helpButton];
        [[self navigationController] pushViewController:startController animated:YES];
        [startController release];        
    } else {
        [self initializeStopViewController];
    }

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
