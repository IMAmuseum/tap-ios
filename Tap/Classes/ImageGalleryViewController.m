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
#import "TAPStop.h"
#import "TAPProperty.h"
#import "TAPAssetRef.h"
#import "TAPAsset.h"
#import "TAPSource.h"
#import "TAPContent.h"

@interface ImageGalleryViewController ()
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
- (void)toggleInfoPane:(UIGestureRecognizer*)tap;
@end

@implementation ImageGalleryViewController

- (id)initWithStop:(TAPStop *)stop
{
    self = [super init];
    if(self) {
        [self setImageStop:stop];
        [self setAssets:[stop getAssets]];
        [self setWantsFullScreenLayout:YES];
        initializedToolbarAnimation = NO;
        currentIndex = 1;
    }
	return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // The first time the view appears, store away the previous controller's values so we can reset on pop.
    if (!viewDidAppearOnce) {
        viewDidAppearOnce = YES;
        navbarWasTranslucent = [[[self navigationController] navigationBar] isTranslucent];
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
    [[[self navigationController] navigationBar] setTranslucent:navbarWasTranslucent];
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
    
    pagingScrollView = newView;
    
    
    recycledPages = [[NSMutableSet alloc] init];
    visiblePages  = [[NSMutableSet alloc] init];
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

- (void)setupInfoPane
{
    isInfoPaneFullscreen = NO;
    infoPane = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 240.0f)];
    [infoPane setBackgroundColor:[UIColor clearColor]];
    [infoPane setAlpha:1.0f];
    [infoPane setAutoresizesSubviews:YES];
    [[self view] addSubview:infoPane];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(toggleInfoPane:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    NSArray *gestureRecognizers = [[NSArray alloc] initWithObjects:tapGestureRecognizer, nil];
    infoPane.gestureRecognizers = gestureRecognizers;
    
    UIView *background = [[UIView alloc] initWithFrame:infoPane.bounds];
    [background setBackgroundColor:[UIColor blackColor]];
    [background setAlpha:0.65f];
    [background setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [infoPane addSubview:background];
    
    UILabel *title = [[UILabel alloc] init];
    [title setLineBreakMode:UILineBreakModeWordWrap];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont systemFontOfSize:13.0f]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTag:TITLE_LABEL];
    [infoPane addSubview:title];
    
    UILabel *copyright = [[UILabel alloc] init];
    [copyright setLineBreakMode:UILineBreakModeWordWrap];
    [copyright setTextColor:[UIColor lightGrayColor]];
    [copyright setFont:[UIFont systemFontOfSize:12]];    
    [copyright setBackgroundColor:[UIColor clearColor]];
    [copyright setTag:COPYRIGHT_LABEL];
    [infoPane addSubview:copyright];
    
    NonSelectableTextView *caption = [[NonSelectableTextView alloc] init];
    [caption setEditable:NO];
    [caption setSecureTextEntry:YES];
    [caption setScrollEnabled:YES];
    [caption setAlwaysBounceHorizontal:NO];
    [caption setTextColor:[UIColor whiteColor]];
    [caption setFont:[UIFont systemFontOfSize:12]];
    [caption setBackgroundColor:[UIColor clearColor]];
    [caption setTag:CAPTION_TEXTVIEW];
    [infoPane addSubview:caption];
    
    [self updateInfoPane];

}

- (void)updateInfoPane
{
    CGFloat titleHeight = 0;
    CGFloat copyrightHeight = 0;
    displayInfoPane = NO;
    
    CGSize constraint = CGSizeMake(self.view.frame.size.width - 2 * CONTENT_PADDING, 20000.0f);
    
    TAPAsset *asset = [self.assets objectAtIndex:currentIndex - 1];
    
    UILabel *lblTitle = (UILabel *)[infoPane viewWithTag:TITLE_LABEL];
    TAPContent *title = [[asset getContentsByPart:@"title"] objectAtIndex:0];
    if (title != nil) {
        // calculate height
        CGSize titleSize = [title.data sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        titleHeight = titleSize.height;
        CGRect titleFrame = CGRectMake(CONTENT_PADDING, CONTENT_PADDING, self.view.frame.size.width - (2 * CONTENT_PADDING), CONTENT_PADDING + titleHeight);
        
        // set label properties
        [lblTitle setText:title.data];
        [lblTitle setFrame:titleFrame];
        displayInfoPane = YES;
    } else {
        [lblTitle setText:@""];
    }

    UILabel *lblCopyright = (UILabel *)[infoPane viewWithTag:COPYRIGHT_LABEL];
    TAPContent *copyright = [[asset getContentsByPart:@"copyright"] objectAtIndex:0];
    if (copyright != nil) {
        // calculate height
        CGSize copyrightSize = [copyright.data sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        copyrightHeight = copyrightSize.height;
        
        CGRect copyrightFrame = CGRectMake(CONTENT_PADDING, titleHeight + CONTENT_PADDING, self.view.frame.size.width - (2 * CONTENT_PADDING), CONTENT_PADDING + copyrightHeight);
        
        // set label properties
        [lblCopyright setText:copyright.data];
        [lblCopyright setFrame:copyrightFrame];
        displayInfoPane = YES;
    } else {
        [lblCopyright setText:@""];
    }
    
    NonSelectableTextView *tvCaption = (NonSelectableTextView *)[infoPane viewWithTag:CAPTION_TEXTVIEW];    
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
        
        [tvCaption setText:caption.data];
        [tvCaption setFrame:captionFrame];
        displayInfoPane = YES;
    } else {
        [tvCaption setText:@""];
    }

    if (displayInfoPane) {
        float infoPaneY = self.view.frame.size.height;
        if (infoPaneY != 0) {
            infoPaneY -= titleHeight + (2 * CONTENT_PADDING);
        }
        
        if (copyrightHeight != 0) {
            infoPaneY -= copyrightHeight;
        }
        CGRect infoPaneFrame = CGRectMake(infoPane.frame.origin.x, infoPane.frame.origin.y, infoPane.frame.size.width, infoPane.frame.size.height);
        // calculate the minimized info pane height
        infoPaneFrame.origin.y = MIN(infoPaneY, self.view.frame.size.height - 40);
        // save frame for later use
        currentPaneMinimizedFrame = infoPaneFrame;
        
        if (isToolbarsHidden) {
            infoPaneFrame.origin.y = self.view.frame.size.height;
        } else if (isInfoPaneFullscreen) {
            infoPaneFrame.origin.y = self.view.frame.size.height - (self.view.frame.size.height * PANEL_HEIGHT);
        }
        
        [infoPane setFrame:infoPaneFrame];
    }
    [infoPane setHidden:!displayInfoPane];
}

- (void)toggleInfoPane:(UIGestureRecognizer*)tap
{
    CGRect newFrame;
    if (isInfoPaneFullscreen) {
        newFrame = currentPaneMinimizedFrame;
        isInfoPaneFullscreen = NO;
    } else {
        newFrame = infoPane.frame;
        newFrame.origin.y = self.view.frame.size.height - (self.view.frame.size.height * PANEL_HEIGHT);
        isInfoPaneFullscreen = YES;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [infoPane setFrame:newFrame];
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Tiling and page configuration

- (void)tilePages 
{
    // Calculate which pages are visible
    CGRect visibleBounds = pagingScrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, [self imageCount] - 1);
    
    // Recycle no-longer-visible pages 
    for (ImageScrollViewController *page in visiblePages) {
        if (page.index < firstNeededPageIndex || page.index > lastNeededPageIndex) {
            [recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }
    [visiblePages minusSet:recycledPages];
    
    // add missing pages
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            ImageScrollViewController *page = [self dequeueRecycledPage];
            if (page == nil) {
                page = [[ImageScrollViewController alloc] init];
                [page setScrollView:self];
            }
            [self configurePage:page forIndex:index];
            [pagingScrollView addSubview:page];
            [visiblePages addObject:page];
        }
    }
}

- (ImageScrollViewController *)dequeueRecycledPage
{
    ImageScrollViewController *page = [recycledPages anyObject];
    if (page) {
        [recycledPages removeObject:page];
    }
    return page;
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (ImageScrollViewController *page in visiblePages) {
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
    NSString *title = [NSString stringWithFormat:formatString, currentIndex, [self imageCount], nil];
    [self setTitle:title];
}

#pragma mark -
#pragma mark ScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = pagingScrollView.frame.size.width;
    int page = floor((pagingScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 2;
    if (page != currentIndex) {
        currentIndex = page;
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
    CGRect bounds = pagingScrollView.bounds;
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
    NSString *imagePath = [[[[_assets objectAtIndex:index] source] anyObject] uri];
    return [UIImage imageWithContentsOfFile:imagePath];    
}

- (NSUInteger)imageCount {
    return [_assets count];
}

- (CGSize)contentSizeForPagingScrollView {
    CGRect scrollFrame = pagingScrollView.frame;
    return CGSizeMake(scrollFrame.size.width * [self imageCount], scrollFrame.size.height);
}

#pragma mark View controller rotation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGFloat offset = pagingScrollView.contentOffset.x;
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    
    if (offset >= 0) {
        firstVisiblePageIndexBeforeRotation = floorf(offset / pageWidth);
        percentScrolledIntoFirstVisiblePage = (offset - (firstVisiblePageIndexBeforeRotation * pageWidth)) / pageWidth;
    } else {
        firstVisiblePageIndexBeforeRotation = 0;
        percentScrolledIntoFirstVisiblePage = offset / pageWidth;
    }    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // recalculate contentSize based on current orientation
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    // adjust frames and configuration of each visible page
    for (ImageScrollViewController *page in visiblePages) {
        CGPoint restorePoint = [page pointToCenterAfterRotation];
        CGFloat restoreScale = [page scaleToRestoreAfterRotation];
        page.frame = [self frameForPageAtIndex:page.index];
        [page setMaxMinZoomScalesForCurrentBounds];
        [page restoreCenterPoint:restorePoint scale:restoreScale];
        
    }
    
    // adjust contentOffset to preserve page location based on values collected prior to location
    CGFloat pageWidth = pagingScrollView.bounds.size.width;
    CGFloat newOffset = (firstVisiblePageIndexBeforeRotation * pageWidth) + (percentScrolledIntoFirstVisiblePage * pageWidth);
    pagingScrollView.contentOffset = CGPointMake(newOffset, 0);
    
    // adjust info pane
    CGRect newInfoPaneFrame = infoPane.frame;
    newInfoPaneFrame.size.width = self.view.frame.size.width;
    infoPane.frame = newInfoPaneFrame;
    
    [self updateInfoPane];
}

#pragma mark -
#pragma mark Toolbars Helpers

- (void)toggleToolbarsDisplay 
{
    [self toggleToolbars:!isToolbarsHidden];
}

- (void)toggleToolbars:(BOOL)hide 
{    
    isToolbarsHidden = hide;    
    [[self navigationController] setNavigationBarHidden:hide animated:initializedToolbarAnimation];
    initializedToolbarAnimation = YES;
    
    if (displayInfoPane) {
        CGRect newFrame;

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        
        if (hide) {
            newFrame = CGRectMake(0.0f, self.view.frame.size.height, currentPaneMinimizedFrame.size.width, currentPaneMinimizedFrame.size.height);
        } else {
            if (isInfoPaneFullscreen) {
                newFrame = infoPane.frame;
                newFrame.origin.y = self.view.frame.size.height - (self.view.frame.size.height * PANEL_HEIGHT);
            } else {
                newFrame = currentPaneMinimizedFrame;
            }
        }
        
        [infoPane setFrame:newFrame];
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