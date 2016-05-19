//
//  ImageGalleryController.m
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "ImageGalleryViewController.h"
#import "ImageScrollViewController.h"
#import "NonSelectableTextView.h"
#import "ImageStop.h"
#import "GTMNSString+HTML.h"

@interface ImageGalleryViewController () {
    UIScrollView *_pagingScrollView;
    UIView *_infoPane;
    CGRect _currentPaneMinimizedFrame;
    BOOL _displayInfoPane;
    BOOL _isInfoPaneFullscreen;

    NSMutableSet *_recycledPages;
    NSMutableSet *_visiblePages;
    NSInteger _currentIndex;

    BOOL _isToolbarsHidden;
    BOOL _rotationInProgress;

    BOOL _viewDidAppearOnce;
    BOOL _initializedToolbarAnimation;
    BOOL _navbarWasTranslucent;

    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int _firstVisiblePageIndexBeforeRotation;
    CGFloat _percentScrolledIntoFirstVisiblePage;
}

@property (nonatomic, strong) ImageStop *imageStop;
@property (nonatomic, strong) NSArray *assets;

- (void)setupInfoPane;
- (void)updateInfoPane;
- (void)configurePage:(ImageScrollViewController *)page forIndex:(NSUInteger)index;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (void)tilePages;
- (ImageScrollViewController *)dequeueRecycledPage;
- (NSUInteger)imageCount;
- (UIImage *)imageAtIndex:(NSUInteger)index;
- (void)setTitleWithCurrentPhotoIndex;
- (void)toggleToolbars:(BOOL)hide;
- (void)hideToolbars;
- (void)showToolbars;
- (void)toggleInfoPane:(UIGestureRecognizer *)tap;
@end

@implementation ImageGalleryViewController

- (id)initWithStop:(ImageStop *)stop
{
    self = [super init];
    if(self) {
        [self setImageStop:stop];
        [self setAssets:[self.imageStop.model getAssets]];
        _initializedToolbarAnimation = NO;
        _currentIndex = 1;
        
        [self setHidesBottomBarWhenPushed:YES];
    }
	return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // The first time the view appears, store away the previous controller's values so we can reset on pop.
    if (!_viewDidAppearOnce) {
        _viewDidAppearOnce = YES;
        _navbarWasTranslucent = [[[self navigationController] navigationBar] isTranslucent];
    }
    // Then ensure translucency. Without it, the view will appear below rather than under it.  
    [[[self navigationController] navigationBar] setTranslucent:YES];
    [self setTitleWithCurrentPhotoIndex];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self hideToolbars];
}

- (void)viewWillDisappear:(BOOL)animated 
{
    // Reset nav bar translucency bar style to whatever it was before.
    [[[self navigationController] navigationBar] setTranslucent:_navbarWasTranslucent];
    [super viewWillDisappear:animated];
}
	
- (void)loadView 
{
    [super loadView];
    
    CGRect scrollFrame = [self frameForPagingScrollView];
    
    UIScrollView *newView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    [newView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [newView setDelegate:self];  
    [newView setBackgroundColor:[UIColor blackColor]];
    [newView setPagingEnabled:YES];
    [newView setShowsVerticalScrollIndicator:NO];
    [newView setShowsHorizontalScrollIndicator:NO];
    [newView setContentSize:CGSizeMake(scrollFrame.size.width * [self imageCount], scrollFrame.size.height)];
    [[self view] addSubview:newView];
    
    _pagingScrollView = newView;
    
    
    _recycledPages = [[NSMutableSet alloc] init];
    _visiblePages  = [[NSMutableSet alloc] init];
    [self tilePages];
    [self setupInfoPane];
}

#pragma mark -
#pragma mark Info pane handling
#define PANEL_HEIGHT 0.4f
#define CONTENT_PADDING 10
#define TITLE_LABEL 1
#define COPYRIGHT_LABEL 2
#define CAPTION_TEXTVIEW 3
#define INFO_PANE_TOGGLE 4
#define INFO_PANE_TOGGLE_SIZE 16.0f

- (void)setupInfoPane
{
    _isInfoPaneFullscreen = NO;
    _infoPane = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
    [_infoPane setBackgroundColor:[UIColor clearColor]];
    [_infoPane setAlpha:1.0f];
    [_infoPane setAutoresizesSubviews:YES];
    [[self view] addSubview:_infoPane];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(toggleInfoPane:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    NSArray *gestureRecognizers = [[NSArray alloc] initWithObjects:tapGestureRecognizer, nil];
    _infoPane.gestureRecognizers = gestureRecognizers;
    
    UIView *background = [[UIView alloc] initWithFrame:_infoPane.bounds];
    [background setBackgroundColor:[UIColor blackColor]];
    [background setAlpha:0.65f];
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [_infoPane addSubview:background];
    
    UILabel *title = [[UILabel alloc] init];
    [title setLineBreakMode:NSLineBreakByWordWrapping];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont systemFontOfSize:13.0f]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTag:TITLE_LABEL];
    [_infoPane addSubview:title];
    
    UIImageView *infoPaneToggle = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn-open"]];
    [infoPaneToggle setTag:INFO_PANE_TOGGLE];
    [infoPaneToggle setOpaque:TRUE];
    [infoPaneToggle setAlpha:0.5f];
    [_infoPane addSubview:infoPaneToggle];
    
    UILabel *copyright = [[UILabel alloc] init];
    [copyright setLineBreakMode:NSLineBreakByWordWrapping];
    [copyright setTextColor:[UIColor lightGrayColor]];
    [copyright setFont:[UIFont systemFontOfSize:12]];    
    [copyright setBackgroundColor:[UIColor clearColor]];
    [copyright setTag:COPYRIGHT_LABEL];
    [_infoPane addSubview:copyright];
    
    NonSelectableTextView *caption = [[NonSelectableTextView alloc] init];
    [caption setEditable:NO];
    [caption setSecureTextEntry:YES];
    [caption setScrollEnabled:YES];
    [caption setAlwaysBounceHorizontal:NO];
    [caption setTextColor:[UIColor whiteColor]];
    [caption setFont:[UIFont systemFontOfSize:12]];
    [caption setBackgroundColor:[UIColor clearColor]];
    [caption setTag:CAPTION_TEXTVIEW];
    [_infoPane addSubview:caption];
    
    [self updateInfoPane];

}

- (void)updateInfoPane
{
    CGFloat titleHeight = 0;
    CGFloat copyrightHeight = 0;
    _displayInfoPane = NO;
    
    CGSize constraint = CGSizeMake(self.view.frame.size.width - 2 * CONTENT_PADDING, 20000.0f);
    
    TAPAsset *asset = [self.assets objectAtIndex:_currentIndex - 1];
    
    UIImageView *infoPaneToggle = (UIImageView *)[_infoPane viewWithTag:INFO_PANE_TOGGLE];
    [infoPaneToggle setFrame:CGRectMake(self.view.frame.size.width - INFO_PANE_TOGGLE_SIZE - CONTENT_PADDING, CONTENT_PADDING + 5.0f, INFO_PANE_TOGGLE_SIZE, INFO_PANE_TOGGLE_SIZE)];
    
    UILabel *lblTitle = (UILabel *)[_infoPane viewWithTag:TITLE_LABEL];
    TAPContent *title = [[asset getContentsByPart:@"title"] objectAtIndex:0];
    
    if (title != nil) {
        // calculate height
        CGSize titleSize = [title.data sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        
        titleHeight = titleSize.height;
        CGRect titleFrame = CGRectMake(CONTENT_PADDING, CONTENT_PADDING, self.view.frame.size.width - (2 * CONTENT_PADDING), CONTENT_PADDING + titleHeight);
        
        // set label properties
        [lblTitle setText:[title.data gtm_stringByUnescapingFromHTML]];
        [lblTitle setFrame:titleFrame];
        _displayInfoPane = YES;
    } else {
        [lblTitle setText:@""];
    }

    UILabel *lblCopyright = (UILabel *)[_infoPane viewWithTag:COPYRIGHT_LABEL];
    TAPContent *copyright = [[asset getContentsByPart:@"copyright"] objectAtIndex:0];
    if (copyright != nil) {
        // calculate height
        CGSize copyrightSize = [copyright.data sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        copyrightHeight = copyrightSize.height;
        
        CGRect copyrightFrame = CGRectMake(CONTENT_PADDING, titleHeight + CONTENT_PADDING, self.view.frame.size.width - (2 * CONTENT_PADDING), CONTENT_PADDING + copyrightHeight);
        
        // set label properties
        [lblCopyright setText:[copyright.data gtm_stringByUnescapingFromHTML]];
        [lblCopyright setFrame:copyrightFrame];
        _displayInfoPane = YES;
    } else {
        [lblCopyright setText:@""];
    }
    
    NonSelectableTextView *tvCaption = (NonSelectableTextView *)[_infoPane viewWithTag:CAPTION_TEXTVIEW];    
    TAPContent *caption = [[asset getContentsByPart:@"caption"] objectAtIndex:0];
    if (caption != nil) {
        CGRect captionFrame = CGRectMake(0, CONTENT_PADDING, self.view.frame.size.width, 0);
        if (titleHeight != 0) {
            captionFrame.origin.y += titleHeight + CONTENT_PADDING;
        }
        
        if (copyrightHeight != 0) {
            captionFrame.origin.y += copyrightHeight + CONTENT_PADDING;
        }
        captionFrame.size.height = (self.view.frame.size.height * PANEL_HEIGHT) - captionFrame.origin.y;
        
        [tvCaption setText:[caption.data gtm_stringByUnescapingFromHTML]];
        [tvCaption setFrame:captionFrame];
        _displayInfoPane = YES;
    } else {
        [tvCaption setText:@""];
    }

    if (_displayInfoPane) {
        float _infoPaneY = self.view.frame.size.height;
        if (_infoPaneY != 0) {
            _infoPaneY -= titleHeight + (2 * CONTENT_PADDING);
        }
        
        if (copyrightHeight != 0) {
            _infoPaneY -= copyrightHeight;
        }
        CGRect infoPaneFrame = CGRectMake(_infoPane.frame.origin.x, _infoPane.frame.origin.y, _infoPane.frame.size.width, _infoPane.frame.size.height);
        // calculate the minimized info pane height
        infoPaneFrame.origin.y = MIN(_infoPaneY, self.view.frame.size.height - 40);
        // save frame for later use
        _currentPaneMinimizedFrame = infoPaneFrame;
        
        if (_isToolbarsHidden) {
            infoPaneFrame.origin.y = self.view.frame.size.height;
        } else if (_isInfoPaneFullscreen) {
            infoPaneFrame.origin.y = self.view.frame.size.height - (self.view.frame.size.height * PANEL_HEIGHT);
        }
        
        [_infoPane setFrame:infoPaneFrame];
    }
    [_infoPane setHidden:!_displayInfoPane];
}

- (void)toggleInfoPane:(UIGestureRecognizer*)tap
{
    UIImageView *infoPaneToggle = (UIImageView *)[_infoPane viewWithTag:INFO_PANE_TOGGLE];

    CGRect newFrame;
    if (_isInfoPaneFullscreen) {
        newFrame = _currentPaneMinimizedFrame;
        _isInfoPaneFullscreen = NO;
        [infoPaneToggle setImage:[UIImage imageNamed:@"btn-open"]];
    } else {
        newFrame = _infoPane.frame;
        newFrame.origin.y = self.view.frame.size.height - (self.view.frame.size.height * PANEL_HEIGHT);
        _isInfoPaneFullscreen = YES;
        [infoPaneToggle setImage:[UIImage imageNamed:@"btn-close"]];
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [_infoPane setFrame:newFrame];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Tiling and page configuration

- (void)tilePages 
{
    // Calculate which pages are visible
    CGRect visibleBounds = _pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = (int)MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    // Recycle no-longer-visible pages 
    for (ImageScrollViewController *page in _visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [_recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [_visiblePages minusSet:_recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollViewController *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[ImageScrollViewController alloc] init];
                [page setScrollView:self];
            }
            [self configurePage:page forIndex:index];
            [_pagingScrollView addSubview:page];
            [_visiblePages addObject:page];
        }
    }
}

- (ImageScrollViewController *)dequeueRecycledPage
{
    ImageScrollViewController *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollViewController *page in _visiblePages) {
        if (page.index == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

- (void)configurePage:(ImageScrollViewController *)page forIndex:(NSUInteger)index
{
    page.index = index;
    page.frame = [self frameForPageAtIndex:index];
    [page displayImage:[self imageAtIndex:index]];
}

- (void)setTitleWithCurrentPhotoIndex
{
    NSString *formatString = NSLocalizedString(@"%1$i of %2$i", @"Picture X out of Y total.");
    NSString *title = [NSString stringWithFormat:formatString, _currentIndex, [self imageCount], nil];
    [self setTitle:title];
}

#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = _pagingScrollView.frame.size.width;
    int page = floor((_pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 2;
    if (page != _currentIndex) {
        _currentIndex = page;
        [self setTitleWithCurrentPhotoIndex];
        [self updateInfoPane];
    }

    [self tilePages];
}


#pragma mark -
#pragma mark  Frame calculations
#define PADDING  10

- (CGRect)frameForPagingScrollView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}


#pragma mark -
#pragma mark Image wrangling

- (NSArray *)imageData {
    static NSArray *__imageData = nil; // only load the imageData array once
    if (__imageData == nil) {
        // read the filenames/sizes out of a plist in the app bundle
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ImageData" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:path];
        NSString *error; NSPropertyListFormat format;
        __imageData = [NSPropertyListSerialization propertyListFromData:plistData
                                                        mutabilityOption:NSPropertyListImmutable
                                                                  format:&format
                                                        errorDescription:&error];
        if (!__imageData) {
            NSLog(@"Failed to read image names. Error: %@", error);
        }
    }
    return __imageData;
}

- (UIImage *)imageAtIndex:(NSUInteger)index {
    NSString *imagePath = [[[[self.assets objectAtIndex:index] getSourcesByPart:@"image"] objectAtIndex:0] uri];
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (NSUInteger)imageCount {
    return [_assets count];
}

- (CGSize)contentSizeForPagingScrollView {
    CGRect scrollFrame = _pagingScrollView.frame;
    return CGSizeMake(scrollFrame.size.width * [self imageCount], scrollFrame.size.height);
}

#pragma mark View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

- (enum UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat offset = _pagingScrollView.contentOffset.x;
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        _firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        _percentScrolledIntoFirstVisiblePage = (offset - (_firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        _firstVisiblePageIndexBeforeRotation = 0;
        _percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    // adjust frames and configuration of each visible page
    for (ImageScrollViewController *page in _visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = (_firstVisiblePageIndexBeforeRotation * pageWidth) + (_percentScrolledIntoFirstVisiblePage * pageWidth);
    _pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
    
    // adjust info pane
    CGRect new_infoPaneFrame = _infoPane.frame;
    new_infoPaneFrame.size.width = self.view.frame.size.width;
    _infoPane.frame = new_infoPaneFrame;
    
    [self updateInfoPane];
}

#pragma mark -
#pragma mark Toolbars Helpers

- (void)toggleToolbarsDisplay 
{
    [self toggleToolbars:!_isToolbarsHidden];
}

- (void)toggleToolbars:(BOOL)hide 
{    
    _isToolbarsHidden = hide;    
    [[self navigationController] setNavigationBarHidden:hide animated:_initializedToolbarAnimation];
    _initializedToolbarAnimation = YES;
    
    if (_displayInfoPane) {
        CGRect newFrame;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        if (hide) {
            newFrame = CGRectMake(0.0f, self.view.frame.size.height, _currentPaneMinimizedFrame.size.width, _currentPaneMinimizedFrame.size.height);
        } else {
            if (_isInfoPaneFullscreen) {
                newFrame = _infoPane.frame;
                newFrame.origin.y = self.view.frame.size.height - (self.view.frame.size.height * PANEL_HEIGHT);
            } else {
                newFrame = _currentPaneMinimizedFrame;
            }
        }
        
        [_infoPane setFrame:newFrame];
        [UIView commitAnimations];
    }
}

- (void)hideToolbars 
{
    [self toggleToolbars:YES];
}

- (void)showToolbars 
{
    [self toggleToolbars:NO];
}


@end