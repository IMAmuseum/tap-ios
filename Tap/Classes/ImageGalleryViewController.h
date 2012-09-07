//
//  ImageGalleryController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageScrollViewController, TAPTour, TAPStop, TAPAsset, TAPAssetRef, TAPConnection, TAPContent, TAPProperty, TAPSource;

@interface ImageGalleryViewController : UIViewController <UIScrollViewDelegate> {
    UIScrollView *pagingScrollView;
    TAPStop *imageStop;
    
    UIView *infoPane;
    CGRect currentPaneMinimizedFrame;
    BOOL displayInfoPane;
    BOOL isInfoPaneFullscreen;
    
    NSArray *assets;
    NSMutableSet *recycledPages;
    NSMutableSet *visiblePages;
    NSInteger currentIndex;
    
    BOOL isToolbarsHidden;
    BOOL rotationInProgress;
    
    BOOL viewDidAppearOnce;
    BOOL initializedToolbarAnimation;
    BOOL navbarWasTranslucent;
    
    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int firstVisiblePageIndexBeforeRotation;
    CGFloat percentScrolledIntoFirstVisiblePage;
}

@property (nonatomic, retain) TAPStop *imageStop;
@property (nonatomic, retain) NSArray *assets;

- (id)initWithStop:(TAPStop *)stop;
- (void)toggleToolbarsDisplay;

@end
