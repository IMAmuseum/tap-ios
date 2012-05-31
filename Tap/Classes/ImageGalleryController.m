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
@synthesize imageViews;

- (id)initWithImageStop:(ImageStop*)stop
{
	if ((self = [super initWithNibName:@"ImageGallery" bundle:[NSBundle mainBundle]])) {
		[self setImageStop:stop];
		[self autorelease];
	}
    
	return self;
}

- (void)loadView
{
    [super loadView];
    
  	NSArray *assets = [imageStop getAssetIds];
    imageViews = [[NSMutableArray alloc] init];
    for (NSString *assetId in assets) {
        ImageStopController *image = [[ImageStopController alloc] initWithAssetId:assetId rootController:self];
        [imageViews addObject:image];
        [image release];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    ImageStopController *image = nil;
    for (int i = 0; i < [imageViews count]; i++) {        
        image = (ImageStopController *)[self.imageViews objectAtIndex:i];
        CGRect frame;
        frame.origin.x = galleryScrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = galleryScrollView.frame.size;
        image.view.frame = frame;
        [galleryScrollView addSubview:image.view];
    }
    
    galleryScrollView.contentSize = CGSizeMake(galleryScrollView.frame.size.width * [imageViews count], 
                                                    galleryScrollView.frame.size.height);
    pager.currentPage = 0;
	pager.numberOfPages = [imageViews count];
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
    [imageViews removeAllObjects];
    [imageViews release];
    
	[super dealloc];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.galleryScrollView.frame.size.width;
    int page = floor((self.galleryScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pager.currentPage = page;
}

@end
