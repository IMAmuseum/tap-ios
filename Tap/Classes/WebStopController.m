#import "WebStopController.h"


@implementation WebStopController

@synthesize webView;
@synthesize webStop;

- (id)initWithWebStop:(WebStop*)stop
{
	if (self = [super initWithNibName:@"WebStop" bundle:[NSBundle mainBundle]]) {
		[self setWebStop:stop];
	}
	
	return self;
}

- (void)dealloc
{
	[webStop release];	
	
	[super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad
{
	// Reference the page for this stop
	NSBundle *tourBundle = [((TapAppDelegate*)[[UIApplication sharedApplication] delegate]) tourBundle];
	NSString *pageSrc = [webStop getSourcePath];
	NSString *pagePath = [tourBundle pathForResource:[[pageSrc lastPathComponent] stringByDeletingPathExtension]
											  ofType:[[pageSrc lastPathComponent] pathExtension]
										 inDirectory:[pageSrc stringByDeletingLastPathComponent]];

	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:pagePath]];
	[webView loadRequest:request];
}

@end
