//
//  BaseStop.m
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import "BaseStop.h"

@implementation BaseStop

- (id)initWithStopModel:(TAPStop *)stopModel
{
	if ((self = [super init])) {
		[self setModel:stopModel];
	}
    
	return self;
}

- (NSString *)getStopId
{
    return (NSString *)[self.model id];
}

- (NSString *)getTitle
{
    return (NSString *)[self.model title];
}

- (NSString *)getDescription
{
    return (NSString *)[self.model desc];
}

- (NSString *)getIconPath
{
	// Default case if we get here
	return [[NSBundle mainBundle] pathForResource:@"icon-webpage" ofType:@"png"];
}

- (BOOL)providesViewController
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (UIViewController *)newViewController
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (BOOL)loadStopViewForViewController:(UIViewController *)viewController;
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end
