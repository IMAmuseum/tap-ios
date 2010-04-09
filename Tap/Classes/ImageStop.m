#import "ImageStop.h"

#import "ImageStopController.h"


@implementation ImageStop

-(NSString*)getSourcePath
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Source")) {
			char *source = (char*)xmlNodeGetContent(child);
			NSString *result = [NSString stringWithUTF8String:source];
			free(source);
			return result;
		}
	}
	
	return nil;
}

#pragma mark BaseStop

-(BOOL)providesViewController
{
	return YES;
}

-(UIViewController*)newViewController
{
	return [[ImageStopController alloc] initWithImageStop:self];
}

-(NSString*)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-image" ofType:@"png"];
}

@end
