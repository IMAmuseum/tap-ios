#import "ImageStop.h"

#import "ImageGalleryController.h"


@implementation ImageStop

-(NSArray*)getSources
{
    NSMutableArray *sources = [[NSMutableArray alloc] init];
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
                    NSString *source = [NSString stringWithUTF8String:(char*)uri];
                    xmlFree(uri);
                    [sources addObject:source];
                }
            }
		}
	}
	
	return sources;
}

#pragma mark BaseStop

-(BOOL)providesViewController
{
	return YES;
}

-(UIViewController*)newViewController
{
	return [[ImageGalleryController alloc] initWithImageStop:self];
}

-(NSString*)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-image" ofType:@"png"];
}

@end