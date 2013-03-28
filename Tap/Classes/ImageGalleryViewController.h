//
//  ImageGalleryController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageScrollViewController, ImageStop;

@interface ImageGalleryViewController : UIViewController <UIScrollViewDelegate>
- (id)initWithStop:(ImageStop *)stop;
- (void)toggleToolbarsDisplay;
@end
