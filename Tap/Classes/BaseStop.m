#import "BaseStop.h"


@implementation BaseStop

@synthesize stopNode;

-(id)initWithStopNode:(xmlNodePtr)stop
{
	if (self = [super init]) {
		[self setStopNode:stop];
	}
	
	return self;
}

-(NSString*)getStopId
{
	char *propId = (char*)xmlGetProp(stopNode, (xmlChar*)"id");
    NSString *result = [NSString stringWithUTF8String:propId];
	xmlFree(propId);
	return result;
}

-(NSString*)getTitle
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Title")) {
			char *title = (char*)xmlNodeGetContent(child);
			NSString *result = [NSString stringWithUTF8String:title];
			free(title);
			return result;
		}
	}
	
	return nil;
}

-(NSString*)getDescription
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Description")) {
			char *desc = (char*)xmlNodeGetContent(child);
			NSString *result = [NSString stringWithUTF8String:desc];
			free(desc);
			return result;
		}
	}
	
	return nil;
}

-(NSString*)getIconPath
{
	// Default case if we get here
	return [[NSBundle mainBundle] pathForResource:@"icon-webpage" ofType:@"png"];
}

-(BOOL)providesViewController
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

-(UIViewController*)newViewController
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(BOOL)loadStopView
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end
