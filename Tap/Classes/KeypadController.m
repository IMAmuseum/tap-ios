#import "KeypadController.h"

@implementation KeypadController


#pragma mark NIB Actions

- (IBAction)buttonDown:(id)sender
{
	[(TapAppDelegate*)[[UIApplication sharedApplication] delegate] playClick];
}

- (IBAction)buttonUpInside:(id)sender
{
	if (sender == buttonClear)
	{
		[self clearCode];
		return;
	}
	
	// Don't allow code to exceed max length
	if ([lblCode.text length] >= MAXIMUM_CODE_LENGTH)
	{
		return;
	}
	
	// Append the corresponding number to the code
	if (sender == button0) [lblCode setText:[lblCode.text stringByAppendingString:@"0"]];
	else if (sender == button1) [lblCode setText:[lblCode.text stringByAppendingString:@"1"]];
	else if (sender == button2) [lblCode setText:[lblCode.text stringByAppendingString:@"2"]];
	else if (sender == button3) [lblCode setText:[lblCode.text stringByAppendingString:@"3"]];
	else if (sender == button4) [lblCode setText:[lblCode.text stringByAppendingString:@"4"]];
	else if (sender == button5) [lblCode setText:[lblCode.text stringByAppendingString:@"5"]];
	else if (sender == button6) [lblCode setText:[lblCode.text stringByAppendingString:@"6"]];
	else if (sender == button7) [lblCode setText:[lblCode.text stringByAppendingString:@"7"]];
	else if (sender == button8) [lblCode setText:[lblCode.text stringByAppendingString:@"8"]];
	else if (sender == button9) [lblCode setText:[lblCode.text stringByAppendingString:@"9"]];
	
	if ([lblCode.text length] >= MINIMUM_CODE_LENGTH)
	{
		buttonGo.enabled = TRUE;
	}
}

/**
 * The active GO button was pressed
 */
- (IBAction)goUpInside:(id)sender
{
	// Grab the stop code
	NSString *stopCode = [lblCode text];
	if ([stopCode length] < MINIMUM_CODE_LENGTH) return;
	
	// Check for the kill code
	if ([stopCode isEqualToString:@"99999"]) {
		exit(0); // NOTE: This is not allowed for AppStore apps
	}
	
    // Load the StopNavigation view
    TapAppDelegate *appDelegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
	
	xmlNodePtr stopNode = [TourMLUtils getStopInDocument:[appDelegate tourDoc] withCode:stopCode];
	if (stopNode == NULL)
	{
		[appDelegate playError];
        
        NSError *error;
        if (![[GANTracker sharedTracker]
              setCustomVariableAtIndex:1 
              name:@"Bundle" 
              value:[[appDelegate tourBundle] bundleIdentifier]
              withError:&error]) {
            NSLog(@"GANTracker error: %@", error);
        }
        
        if (![[GANTracker sharedTracker] 
              trackEvent:@"Keypad" 
              action:@"entered code" 
              label:@"Invalid code" 
              value: 1
              withError: &error]){
            NSLog(@"GANTracker error: %@", error);
        }
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:[NSString stringWithFormat:NSLocalizedString(@"Invalid code: %@", @"Invalid code message"), stopCode]
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
        [alert show];
        [alert release];
		
		[self clearCode];
		return; // failed
	}
	if ([appDelegate loadStop:[StopFactory newStopForStopNode:stopNode]]) {
		// stop loaded successfully
	} else {
		// failed to load stop
		[self clearCode];
	}
}

- (void)clearCode
{
	[lblCode setText:@""];
	buttonGo.enabled = FALSE;
}

#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad
{
    [[self navigationItem] setTitle:@"Keypad"];
    
    [self clearCode];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main.png"]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self clearCode];
	[self willRotateToInterfaceOrientation:[self interfaceOrientation] duration:0.0];
}

-(void)dealloc
{	
	[super dealloc];
}

@end
