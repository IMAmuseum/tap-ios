#import "ImageStop.h"

#import "ImageStopController.h"


@implementation ImageStop

-(NSString*)getSourcePath
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) 
    {
		if (xmlStrEqual(child->name, (xmlChar*)"AssetRef")) 
        {
            NSString *assetId = [NSString stringWithUTF8String:(char*) xmlGetProp(child, (xmlChar*)"id")];
            xmlNodePtr asset = [TourMLUtils getAsset:stopNode->doc withIdentifier:assetId];
            for (xmlNodePtr assetChild = asset->children; assetChild != NULL; assetChild = assetChild->next) 
            {
                if (xmlStrEqual(assetChild->name, (xmlChar*)"Source")) 
                {
                    xmlChar *uri = xmlGetProp(assetChild, (xmlChar*)"uri");
                    NSString *result = [NSString stringWithUTF8String:(char*)uri];
                    xmlFree(uri);
                    return result;
                }
            }
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