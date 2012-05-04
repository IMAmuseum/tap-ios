#import "ImageStopController.h"

@interface ImageStopController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation ImageStopController

@synthesize scrollView;
@synthesize imageView;
@synthesize imageSrc;


- (id)initWithImageSource:(NSString*)source
{
	if ((self = [super initWithNibName:@"ImageStop" bundle:[NSBundle mainBundle]])) {
		[self setImageSrc:source];
	}

	return self;
}

- (void)dealloc
{
	[imageView release];
	[imageSrc release];
	[scrollView release];
    
	[super dealloc];
}

#pragma mark UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	//return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad
{
	// Reference the image for this stop
	NSBundle *tourBundle = [((TapAppDelegate*)[[UIApplication sharedApplication] delegate]) tourBundle];
	NSString *imagePath = [tourBundle pathForResource:[[imageSrc lastPathComponent] stringByDeletingPathExtension]
											   ofType:[[imageSrc lastPathComponent] pathExtension]
										  inDirectory:[imageSrc stringByDeletingLastPathComponent]];
	
	[self setImageView:[[TapDetectingImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]]];
    [imageView setDelegate:self];
    
	[imageView setFrame:scrollView.bounds];
	[imageView setContentMode: (UIViewContentModeScaleAspectFit)];
	[imageView setAutoresizingMask: (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		
	[scrollView setContentSize:[imageView frame].size];
	[scrollView	setContentMode: UIViewContentModeScaleAspectFit];
	[scrollView setClipsToBounds: YES];
		 
	[scrollView setMinimumZoomScale: 1.0f];
	[scrollView setMaximumZoomScale: [imageView image].size.width/[imageView frame].size.width];
	[scrollView addSubview:imageView];
}

#pragma mark UIScrollViewDelegate 

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}

#pragma mark TapDetectingImageViewDelegate

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotSingleTapAtPoint:(CGPoint)tapPoint
{
    // Toggle zoom in or out
	[self tapDetectingImageView:view gotDoubleTapAtPoint:tapPoint]; // just call double tap
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint
{
    TapAppDelegate *delegate = (TapAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSError *error;
    if (![[GANTracker sharedTracker]
          setCustomVariableAtIndex:1 
          name:@"Bundle" 
          value:[[delegate tourBundle] bundleIdentifier]
          withError:&error]) {
        NSLog(@"GANTracker error: %@", error);
    }
    
	// Toggle zoom in or out
	if ([scrollView zoomScale] == [scrollView minimumZoomScale])
	{
		// Zoom all the way in
		[scrollView zoomToRect:[self zoomRectForScale:[scrollView maximumZoomScale] withCenter:tapPoint] animated:YES];
        
        if (![[GANTracker sharedTracker] 
              trackEvent:@"Image" 
              action:@"zoom-in" 
              label:@"Zoom-in image" 
              value: 1
              withError: &error]){
            NSLog(@"GANTracker error: %@", error);
        }
	}
	else if ([scrollView zoomScale] == [scrollView maximumZoomScale])
	{
		// Zoom all the way out
		[scrollView zoomToRect:[self zoomRectForScale:[scrollView minimumZoomScale] withCenter:tapPoint] animated:YES];
		
        if (![[GANTracker sharedTracker] 
              trackEvent:@"Image" 
              action:@"zoom-out" 
              label:@"Zoom-out image" 
              value: 1
              withError: &error]){
            NSLog(@"GANTracker error: %@", error);
        }
	}
	else if (([scrollView zoomScale] - [scrollView minimumZoomScale]) < ([scrollView maximumZoomScale] - [scrollView zoomScale]))
	{
		// Zoom out if closer to min zoom
		[scrollView zoomToRect:[self zoomRectForScale:[scrollView minimumZoomScale] withCenter:tapPoint] animated:YES];
		
        if (![[GANTracker sharedTracker] 
              trackEvent:@"Image" 
              action:@"zoom-out" 
              label:@"Zoom-out image" 
              value: 1
              withError: &error]){
            NSLog(@"GANTracker error: %@", error);
        }
	}
	else
	{
		// Zoom in if closer to max zoom
		[scrollView zoomToRect:[self zoomRectForScale:[scrollView maximumZoomScale] withCenter:tapPoint] animated:YES];
		
        if (![[GANTracker sharedTracker] 
              trackEvent:@"Image" 
              action:@"zoom-in" 
              label:@"Zoom-in image" 
              value: 1
              withError: &error]){
            NSLog(@"GANTracker error: %@", error);
        }
	}
}

- (void)tapDetectingImageView:(TapDetectingImageView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
	// Nothing for now
}

#pragma mark Utility methods
	
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
			
	CGRect zoomRect;
			
	// the zoom rect is in the content view's coordinates. 
	//    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
	//    As the zoom scale decreases, so more content is visible, the size of the rect grows.
	zoomRect.size.height = [scrollView frame].size.height / scale;
	zoomRect.size.width  = [scrollView frame].size.width  / scale;
			
	// choose an origin so as to get the right center.
	zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
	zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
			
	return zoomRect;
}

@end
