#import "VideoStop.h"

#import "TapAppDelegate.h"
#import "KeypadController.h"
#import "StopGroupController.h"

@implementation VideoStop

@synthesize isAudio;

-(NSString*)getSourcePath
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Source")) {
			char *src = (char*)xmlNodeGetContent(child);
			NSString *result = [NSString stringWithUTF8String:src];
			free(src);
			return result;
		}
	}
	
	return nil;
}

#pragma mark BaseStop

-(BOOL)providesViewController
{
	return NO;
}

-(NSString*)getIconPath
{
	if (isAudio) return [[NSBundle mainBundle] pathForResource:@"icon-audio" ofType:@"png"];
	else return [[NSBundle mainBundle] pathForResource:@"icon-video" ofType:@"png"];
}

-(BOOL)loadStopView
{
	NSBundle *tourBundle = [((TapAppDelegate*)[[UIApplication sharedApplication] delegate]) tourBundle];
	NSString *videoSrc = [self getSourcePath];
	NSString *videoPath = [tourBundle pathForResource:[[videoSrc lastPathComponent] stringByDeletingPathExtension]
											   ofType:[[videoSrc lastPathComponent] pathExtension]
										  inDirectory:[videoSrc stringByDeletingLastPathComponent]];
	if (!videoPath) return NO;
	
	NSURL *videoURL = [NSURL fileURLWithPath:videoPath];	
	MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
	[[movieController moviePlayer] setControlStyle:MPMovieControlStyleFullscreen];
	
	// Add finished observer
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(moviePlayBackDidFinish:)
												 name:MPMoviePlayerPlaybackDidFinishNotification
											   object:[movieController moviePlayer]];
	
	TapAppDelegate *appDelegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
	[[[appDelegate navigationController] visibleViewController] presentMoviePlayerViewControllerAnimated:movieController];
	
	return YES;
}

-(void)moviePlayBackDidFinish:(NSNotification*)notification
{
	MPMoviePlayerController *moviePlayer = [notification object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:MPMoviePlayerPlaybackDidFinishNotification
												  object:moviePlayer];
	
	// Remove highlight from stop if in a stop group
	TapAppDelegate *appDelegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];
	if ([[[appDelegate navigationController] visibleViewController] isKindOfClass:[StopGroupController class]])
	{
		UITableView *stopTable = [(StopGroupController*)[[appDelegate navigationController] visibleViewController] stopTable];
		[stopTable deselectRowAtIndexPath:[stopTable indexPathForSelectedRow] animated:YES];
	}
	
	// Clear the code if in a keypad
	else if ([[[appDelegate navigationController] visibleViewController] isKindOfClass:[KeypadController class]])
	{
		[(KeypadController*)[[appDelegate navigationController] visibleViewController] clearCode];
	}
	
	[Analytics trackAction:@"movie-stop" forStop:[self getStopId]];
	
	[self release];
}

@end
