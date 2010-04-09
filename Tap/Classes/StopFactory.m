#import "StopFactory.h"


@implementation StopFactory

+(id)newStopForStopNode:(xmlNodePtr)stop
{
	if (!stop) {
		// Produce error?
		return nil;
	}
	
	if (xmlStrEqual(stop->name, (xmlChar*)"ImageStop"))
	{
		return [[ImageStop alloc] initWithStopNode:stop];
	}
	else if (xmlStrEqual(stop->name, (xmlChar*)"PollStop"))
	{
		return [[PollStop alloc] initWithStopNode:stop];
	}
	else if (xmlStrEqual(stop->name, (xmlChar*)"StopGroup"))
	{
		return [[StopGroup alloc] initWithStopNode:stop];
	}
	else if (xmlStrEqual(stop->name, (xmlChar*)"VideoStop"))
	{
		VideoStop *videoStop = [[VideoStop alloc] initWithStopNode:stop];
		[videoStop setIsAudio:NO];
		return videoStop;
	}
	else if (xmlStrEqual(stop->name, (xmlChar*)"AudioStop"))
	{
		VideoStop *videoStop = [[VideoStop alloc] initWithStopNode:stop];
		[videoStop setIsAudio:YES];
		return videoStop;
	}
	else if (xmlStrEqual(stop->name, (xmlChar*)"WebStop"))
	{
		return [[WebStop alloc] initWithStopNode:stop];
	}
	else
	{
		return nil;
	}
}

@end
