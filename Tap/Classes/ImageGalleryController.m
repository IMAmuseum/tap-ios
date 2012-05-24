//
//  ImageGalleryController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageGalleryController.h"

@implementation ImageGalleryController

@synthesize galleryScrollView;
@synthesize pager;
@synthesize imageStop;

- (id)initWithImageStop:(ImageStop*)stop
{
	if ((self = [super initWithNibName:@"ImageGallery" bundle:[NSBundle mainBundle]])) {
		[self setImageStop:stop];
		[self autorelease];
	}
    
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	NSArray *assets = [imageStop getAssetIds];
    for (int i = 0; i < assets.count; i++) {
        CGRect frame;
        frame.origin.x = galleryScrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = galleryScrollView.frame.size;
        ImageStopController *image = [[ImageStopController alloc] initWithAssetId:[assets objectAtIndex:i] rootController:self];
        image.view.frame = frame;
        [galleryScrollView addSubview:[image view]];
    }
    
    galleryScrollView.contentSize = CGSizeMake(galleryScrollView.frame.size.width * assets.count, 
                                                    galleryScrollView.frame.size.height);
    pager.currentPage = 0;
	pager.numberOfPages = assets.count;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
	[galleryScrollView release];
	[pager release];
	[imageStop release];
    
	[super dealloc];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.galleryScrollView.frame.size.width;
    int page = floor((self.galleryScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pager.currentPage = page;
}

@end
