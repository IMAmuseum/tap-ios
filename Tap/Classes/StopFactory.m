//
//  StopFactory.m
//  Tap
//
//  Created by Daniel Cervantes on 2/3/13.
//
//

#import "StopFactory.h"
#import "AppDelegate.h"

@implementation StopFactory

+ (BaseStop *)newStopForStopNode:(TAPStop *)stopModel
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSDictionary *stops = [appDelegate.tapConfig objectForKey:@"Stops"];
    NSString *className = [stops objectForKey:stopModel.view];
    
    if (className != nil) {
        BaseStop *class = [[NSClassFromString(className) alloc] initWithStopModel:stopModel];
        return class;
    }
    
    return nil;
}

@end
