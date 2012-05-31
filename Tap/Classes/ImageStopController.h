#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TapAppDelegate.h"
#import "ImageInfoController.h"
#import "TapDetectingImageView.h"
#import "ImageStop.h"

@interface ImageStopController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate, ImageInfoControllerDelegate> {
	IBOutlet UIScrollView *scrollView;
    IBOutlet UIButton *infoButton;
	TapDetectingImageView *imageView;
    NSString *assetId;
}

@property (assign) UIViewController *rootController;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIButton *infoButton;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) NSString *assetId;

- (IBAction)toggleInfoPane:(id)sender;
- (id)initWithAssetId:(NSString*)assetID rootController:(UIViewController*)controller;

@end