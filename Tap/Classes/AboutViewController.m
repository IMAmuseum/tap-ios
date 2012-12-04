//
//  AboutViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 11/29/12.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()
- (IBAction)dismissView:(id)sender;
@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                              pathForResource:@"About" ofType:@"html"] isDirectory:NO]]];
    [webView setDelegate:self];
}

- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

@end
