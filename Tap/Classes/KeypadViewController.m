//
//  KeypadController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "KeypadViewController.h"
#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPStop.h"
#import <AudioToolbox/AudioToolbox.h>

#define MINIMUM_CODE_LENGTH	1
#define MAXIMUM_CODE_LENGTH	5

@interface KeypadViewController (Private)
// Event for down press to play a sound
- (IBAction)playKeyClick:(id)sender;
// Event for pushing any numeric button or the clear button
- (IBAction)pressKey:(id)sender;
// Event for pushing the GO button
- (IBAction)go:(id)sender;
// Clear the code from the text field
- (void)clearCode;
@end

@implementation KeypadViewController

-(id)init 
{
    self = [super init];
    if(self) {
        [self setTitle:NSLocalizedString(@"Keypad", @"")];
    }
    return self;
}

- (void)viewDidLoad{
 [btnClear setTitle:NSLocalizedString(@"Clear", nil) forState:UIControlStateNormal];
 [btnGo setTitle:NSLocalizedString(@"Go", nil) forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [self clearCode];
}

/**
 * Handles the numeric keypad and clear button input
 */
- (IBAction)pressKey:(id)sender 
{
    if (sender == btnClear) {
		[self clearCode];
		return;
	}
	
	// Don't allow code to exceed max length
	if ([lblCode.text length] >= MAXIMUM_CODE_LENGTH) {
		return;
	}
	
	// Append the corresponding number to the code
	if (sender == btn0) [lblCode setText:[lblCode.text stringByAppendingString:@"0"]];
	else if (sender == btn1) [lblCode setText:[lblCode.text stringByAppendingString:@"1"]];
	else if (sender == btn2) [lblCode setText:[lblCode.text stringByAppendingString:@"2"]];
	else if (sender == btn3) [lblCode setText:[lblCode.text stringByAppendingString:@"3"]];
	else if (sender == btn4) [lblCode setText:[lblCode.text stringByAppendingString:@"4"]];
	else if (sender == btn5) [lblCode setText:[lblCode.text stringByAppendingString:@"5"]];
	else if (sender == btn6) [lblCode setText:[lblCode.text stringByAppendingString:@"6"]];
	else if (sender == btn7) [lblCode setText:[lblCode.text stringByAppendingString:@"7"]];
	else if (sender == btn8) [lblCode setText:[lblCode.text stringByAppendingString:@"8"]];
	else if (sender == btn9) [lblCode setText:[lblCode.text stringByAppendingString:@"9"]];
	
	if ([lblCode.text length] >= MINIMUM_CODE_LENGTH) {
		btnGo.enabled = TRUE;
	}
	if ([lblCode.text length] > 0) {
		btnClear.enabled = TRUE;
	}
}

/**
 * Attempts to navigate to entered stop code
 */
- (IBAction)go:(id)sender 
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Grab the stop code
	NSString *stopCode = [lblCode text];
	if ([stopCode length] < MINIMUM_CODE_LENGTH) return;
	
    TAPStop *stop = [appDelegate.currentTour stopFromKeycode:stopCode];
	if (stop == nil) {
        [appDelegate playError];
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:nil
							  message:[NSString stringWithFormat:NSLocalizedString(@"Invalid code: %@", @"Invalid code message"), stopCode]
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
        [alert show];
		
		[self clearCode];
		return;
    } else {
        [appDelegate loadStop:stop];
    }
}

/**
 * Play key click
 */
- (IBAction)playKeyClick:(id)sender
{
	[(AppDelegate*)[[UIApplication sharedApplication] delegate] playClick];
}

/**
 * Clears out the label and disables the Go button
 */
- (void)clearCode 
{
	[lblCode setText:@""];
	btnGo.enabled = FALSE;
	btnClear.enabled = FALSE;
}

#pragma mark View controller rotation methods

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
