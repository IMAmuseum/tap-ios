//
//  TranscriptStopController.m
//  Tap
//
//  Created by Daniel Cervantes on 11/4/12.
//
//

#import "TranscriptStopController.h"
#import "AppDelegate.h"
#import "TAPTour.h"
#import "TAPStop.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"
#import "TAPConnection.h"

@implementation TranscriptStopController

@synthesize transcriptStop = _transcriptStop;
@synthesize transcript = _transcript;

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if(self) {
        [self setTranscriptStop:stop];
    }
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create a pinch gesture recognizer instance.
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)] autorelease];
    [_transcript addGestureRecognizer:pinchGestureRecognizer];
    [_transcript setText:(NSString *)_transcriptStop.desc];
}

- (void)viewWillAppear:(BOOL)animated
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    TAPTour *tour = appDelegate.currentTour;
    TAPAsset *image = [[tour getAssetsByUsage:@"asset-image-banner"] objectAtIndex:0];
    [bannerImage setImage:[UIImage imageWithContentsOfFile:[[[image source] anyObject] uri]]];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer
{    
	UIFont *font = _transcript.font;
	CGFloat pointSize = font.pointSize;
	NSString *fontName = font.fontName;
    
	pointSize = ((gestureRecognizer.velocity > 0) ? 1 : -1) * 1 + pointSize;
    
	if (pointSize < 13) pointSize = 13;
	if (pointSize > 42) pointSize = 42;
    
	_transcript.font = [UIFont fontWithName:fontName size:pointSize];
}

- (void)dealloc
{
    [_transcriptStop release];
    [_transcript release];
    [super dealloc];
}

@end
