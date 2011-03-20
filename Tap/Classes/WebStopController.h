#import <UIKit/UIKit.h>

#import "TapAppDelegate.h"
#import "WebStop.h"

@interface WebStopController : UIViewController {

	IBOutlet UIWebView *webView;
	
	WebStop *webStop;
	
}

@property (nonatomic, retain) UIWebView *webView;
@property (assign) WebStop *webStop;

- (id)initWithWebStop:(WebStop*)stop;

@end
