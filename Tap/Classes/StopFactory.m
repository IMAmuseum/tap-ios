#import "StopFactory.h"


@implementation StopFactory

+(id<Stop>)newStopForStopNode:(xmlNodePtr)stop
{
    // Try to dynamically load the class with the matching name (e.g. ImageStop, StopGroup, etc)
    Class stopClass = NSClassFromString([NSString stringWithUTF8String:(char*)stop->name]);
    
    if ((stopClass != nil) && ([stopClass conformsToProtocol:@protocol(Stop)]))
    {
        return [[stopClass alloc] initWithStopNode:stop];
    }
    else
    {
        return nil;
    }
}

@end
