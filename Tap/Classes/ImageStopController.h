#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TapAppDelegate.h"
#import "TapDetectingImageView.h"
#import "ImageStop.h"

@interface ImageStopController : UIViewController <UIScrollViewDelegate, TapDetectingImageViewDelegate> {

	IBOutlet UIScrollView *scrollView;
	TapDetectingImageView *imageView;
	
	NSString *imageSrc;

}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *imageView;

@property (assign) NSString *imageSrc;

- (id)initWithImageSource:(NSString*)source;

@end
