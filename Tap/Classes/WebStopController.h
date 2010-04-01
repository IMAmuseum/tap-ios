//
//  WebViewController.h
//  Tap
//
//  Created by Charlie Moad on 5/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TapAppDelegate.h"

@interface WebStopController : UIViewController {

	IBOutlet UIWebView *webView;
	
	WebStop *webStop;
	
}

@property (nonatomic, retain) UIWebView *webView;
@property (assign) WebStop *webStop;

- (id)initWithWebStop:(WebStop*)stop;

@end
