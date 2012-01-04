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
		
		[Analytics trackAction:@"bad-code" forStop:[NSString stringWithFormat:@"<%@>", stopCode]];
		
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// Update the banner image
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
	{
		[bannerImage setImage:[UIImage imageNamed:@"bg-header.png"]];
		
		// Update button layout
		[button1 setFrame:CGRectMake(6, 142, 100, 66)];
		[button2 setFrame:CGRectMake(109, 142, 100, 66)];
		[button3 setFrame:CGRectMake(212, 142, 100, 66)];
		[button4 setFrame:CGRectMake(6, 209, 100, 66)];
		[button5 setFrame:CGRectMake(109, 209, 100, 66)];
		[button6 setFrame:CGRectMake(212, 209, 100, 66)];
		[button7 setFrame:CGRectMake(6, 276, 100, 66)];
		[button8 setFrame:CGRectMake(109, 276, 100, 66)];
		[button9 setFrame:CGRectMake(212, 276, 100, 66)];
		[button0 setFrame:CGRectMake(6, 344, 100, 66)];
		[buttonClear setFrame:CGRectMake(109, 344, 203, 66)];
		
		if (duration > 0) [Analytics trackAction:@"rotate-portrait" forStop:@"keypad"];
	}
	else
	{
		[bannerImage setImage:[UIImage imageNamed:@"bg-header-wide.png"]];
		
		// Update button layout
		[button1 setFrame:CGRectMake(6, 142, 92, 62)];
		[button2 setFrame:CGRectMake(100, 142, 92, 62)];
		[button3 setFrame:CGRectMake(194, 142, 92, 62)];
		[button4 setFrame:CGRectMake(288, 142, 92, 62)];
		[button5 setFrame:CGRectMake(382, 142, 92, 62)];
		[button6 setFrame:CGRectMake(6, 205, 92, 62)];
		[button7 setFrame:CGRectMake(100, 205, 92, 62)];
		[button8 setFrame:CGRectMake(194, 205, 92, 62)];
		[button9 setFrame:CGRectMake(288, 205, 92, 62)];
		[button0 setFrame:CGRectMake(382, 205, 92, 62)];
		[buttonClear setFrame:CGRectMake(315, 68, 159, 66)];
		
		if (duration > 0) [Analytics trackAction:@"rotate-landscape" forStop:@"keypad"];
	}
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
