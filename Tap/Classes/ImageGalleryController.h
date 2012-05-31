//
//  ImageGalleryController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapAppDelegate.h"
#import "ImageStopController.h"
#import "ImageStop.h"

@interface ImageGalleryController : UIViewController <UIScrollViewDelegate> {
    UIScrollView *galleryScrollView;
    UIPageControl *pager;
    ImageStop *imageStop;
    NSMutableArray *imageViews;    
}

@property (nonatomic, retain) IBOutlet UIScrollView *galleryScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pager;
@property (assign) ImageStop *imageStop;
@property (nonatomic, retain) NSMutableArray *imageViews;

- (id)initWithImageStop:(ImageStop*)stop;

@end
