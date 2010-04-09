#import "Analytics.h"

// action
// stop
// localtime
// device uuid
// device name
#define ANALYTICS_URL_FORMAT @"http://athena.imamuseum.org/tap/tourml/analytics/%@/%@/%d/%@/%@"

@implementation Analytics

+ (void)trackAction:(NSString*)action forStop:(NSString*)stop
{
	Analytics *analytics = [[Analytics alloc] init];
	
	UIDevice *device = [UIDevice currentDevice];
	NSString *reqUrl = [NSString stringWithFormat:ANALYTICS_URL_FORMAT,
						stop,
						action,
						time(NULL),
						[device uniqueIdentifier],
						[device name]];
	reqUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)reqUrl, NULL, NULL, kCFStringEncodingUTF8);
	[reqUrl autorelease];
	
    NSLog(@"Tracking analytics: action=%@ stop=%@ time=%d device_uuid=%@ device_name=%@", action, stop, time(NULL), [device uniqueIdentifier], [device name]);
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:reqUrl]
											 cachePolicy:NSURLRequestReloadIgnoringCacheData
										 timeoutInterval:5];
    
    [[NSURLConnection alloc] initWithRequest:request 
									delegate:analytics 
							startImmediately:YES];
}

#pragma mark NSURLConnection

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSString *message = [NSString stringWithFormat:@"Error! %@", [error localizedDescription]];
	NSLog(@"analytics didFailWithError:%@", message);
	
	[connection release];
	[self release];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
	[connection release];
	[self release];
}

@end
