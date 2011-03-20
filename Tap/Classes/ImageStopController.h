#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TapAppDelegate.h"
#import "TapDetectingImageView.h"
#import "ImageStop.h"

@interface ImageStopController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate> {

	IBOutlet UIScrollView *scrollView;
	TapDetectingImageView *imageView;
	
	ImageStop *imageStop;

}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *imageView;

@property (assign) ImageStop *imageStop;

- (id)initWithImageStop:(ImageStop*)stop;

@end
