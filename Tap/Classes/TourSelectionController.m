//
//  TourSelectionController.m
//  Tap
//
//  Created by Kyle Jaebker on 6/28/11.
//  Copyright 2011 Indianapolis Museum of Art. All rights reserved.
//

#import "TourSelectionController.h"
#import "KeypadController.h"

@implementation TourSelectionController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationItem] setTitle:@"Tours"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-main.png"]]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
	[self willRotateToInterfaceOrientation:[self interfaceOrientation] duration:0.0];
}

#pragma mark NIB Actions

- (IBAction)buttonDown:(id)sender
{
	[(TapAppDelegate*)[[UIApplication sharedApplication] delegate] playClick];
}

- (IBAction)buttonUpInside:(id)sender
{
    TapAppDelegate *delegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *bundle = [[[delegate tapConfig] objectForKey:@"TapTourBundleNames"] objectAtIndex:[sender tag]];
        
    [(TapAppDelegate*)[[UIApplication sharedApplication] delegate] setActiveTour:bundle];
    
    // TODO: GANTracker
    //[Analytics trackAction:[NSString stringWithFormat:@"Selected Tour: %@",bundle] forStop:@"TourSelect"];
    
    KeypadController *keypad = [[KeypadController alloc] init];
    [[self navigationController] pushViewController:keypad animated:YES];
    [keypad release];
}

@end
