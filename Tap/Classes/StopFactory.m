#import "StopFactory.h"


@implementation StopFactory

+(id<Stop>)newStopForStopNode:(xmlNodePtr)stop
{
    xmlChar* stopType = xmlGetProp(stop, (xmlChar*)"view");

    // Check for Video/AudioStop cases where we always use the VideoStop
    // This could be handled more elegantly later

    if (xmlStrEqual(stopType, (xmlChar*)"tour_audio_stop")) 
    {
        free(stopType);
        VideoStop *videoStop = [[VideoStop alloc] initWithStopNode:stop];
        [videoStop setIsAudio:YES];
        return videoStop;
    } 
    else if (xmlStrEqual(stopType, (xmlChar*)"tour_video_stop")) 
    {
        VideoStop *videoStop = [[VideoStop alloc] initWithStopNode:stop];
        [videoStop setIsAudio:NO];
        free(stopType);        
        return videoStop;
    } 
    else if(xmlStrEqual(stopType, (xmlChar*)"tour_image_stop")) 
    {
        ImageStop *imageStop = [[ImageStop alloc] initWithStopNode:stop];
        free(stopType);
        return imageStop;
    } 
    else if(xmlStrEqual(stopType, (xmlChar*)"tour_poll_stop")) 
    {
        PollStop *pollStop = [[PollStop alloc] initWithStopNode:stop];
        free(stopType);
        return pollStop;        
    }
    else if(xmlStrEqual(stopType, (xmlChar*)"tour_stop_group")) 
    {
        StopGroup *stopGroup = [[StopGroup alloc] initWithStopNode:stop];
        free(stopType);
        return stopGroup;        
    }     
    else 
    {
        return nil;
    }
}

@end
