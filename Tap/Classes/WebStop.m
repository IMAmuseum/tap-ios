#import "WebStop.h"

#import "WebStopController.h"


@implementation WebStop

-(NSString*)getSourcePath
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Source")) {
			char *src = (char*)xmlNodeGetContent(child);
			NSString *result = [NSString stringWithUTF8String:src];
			free(src);
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
	return [[WebStopController alloc] initWithWebStop:self];
}

-(NSString*)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-webpage" ofType:@"png"];
}

@end
