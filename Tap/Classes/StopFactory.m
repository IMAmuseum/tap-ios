#import "StopFactory.h"


@implementation StopFactory

+(id<Stop>)newStopForStopNode:(xmlNodePtr)stop
{
    // Check for Video/AudioStop cases where we always use the VideoStop
    // This could be handled more elegantly later
    if (xmlStrEqual(stop->name, (xmlChar*)"AudioStop"))
    {
        VideoStop *videoStop = [[VideoStop alloc] initWithStopNode:stop];
        [videoStop setIsAudio:YES];
        return videoStop;
    }
    else if (xmlStrEqual(stop->name, (xmlChar*)"VideoStop"))
    {
        VideoStop *videoStop = [[VideoStop alloc] initWithStopNode:stop];
        [videoStop setIsAudio:NO];
        return videoStop;
    }
    
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
