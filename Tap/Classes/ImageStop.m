#import "ImageStop.h"
#import "TourMLUtils.h"
#import "ImageGalleryController.h"


@implementation ImageStop

+ (NSString*)getSource:(xmlDocPtr)document withIdentifier:(NSString*)ident
{
    xmlNodePtr asset = [TourMLUtils getAsset:document withIdentifier:ident];
    for (xmlNodePtr assetChild = asset->children; assetChild != NULL; assetChild = assetChild->next) 
    {
        if (xmlStrEqual(assetChild->name, (xmlChar*)"Source")) 
        {
            xmlChar *uri = xmlGetProp(assetChild, (xmlChar*)"uri");
            NSString *source = [NSString stringWithUTF8String:(char*)uri];
            xmlFree(uri);
            return source;
        }
    }
    return nil;
}

+ (NSString*)getCaption:(xmlDocPtr)document withIdentifier:(NSString*)ident
{
    xmlNodePtr asset = [TourMLUtils getAsset:document withIdentifier:ident];
    for (xmlNodePtr assetChild = asset->children; assetChild != NULL; assetChild = assetChild->next) 
    {
        if (xmlStrEqual(assetChild->name, (xmlChar*)"Content")) 
        {
            xmlChar *part = xmlGetProp(assetChild, (xmlChar*)"part");
            if (xmlStrEqual(part, (xmlChar*)"field_caption")) {
                for (xmlNodePtr contentChild = assetChild->children; contentChild != NULL; contentChild = contentChild->next) {
                    if (xmlStrEqual(contentChild->name, (xmlChar*)"Data")) {
                        NSString *caption = [NSString stringWithUTF8String:(char*)xmlNodeGetContent(contentChild)];
                        xmlFree(part);
                        return caption;
                    }
                }

            }
            xmlFree(part);
        }
    }
    return nil; 
}

+ (NSString*)getCreditLine:(xmlDocPtr)document withIdentifier:(NSString*)ident
{
    xmlNodePtr asset = [TourMLUtils getAsset:document withIdentifier:ident];
    for (xmlNodePtr assetChild = asset->children; assetChild != NULL; assetChild = assetChild->next) 
    {
        if (xmlStrEqual(assetChild->name, (xmlChar*)"AssetRights")) 
        {
            for (xmlNodePtr assetRight = assetChild->children; assetChild != NULL; assetRight = assetRight->next) {
                if (xmlStrEqual(assetRight->name, (xmlChar*)"Copyright")) {
                    NSString *creditLine = [NSString stringWithUTF8String:(char*)xmlNodeGetContent(assetRight)];
                    return creditLine;
                }
            }                
        }
    }
    return nil; 
}

- (NSArray*)getAssetIds
{
    NSMutableArray *assets = [[[NSMutableArray alloc] init] autorelease];
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) 
    {
		if (xmlStrEqual(child->name, (xmlChar*)"AssetRef")) 
        {
            NSString *assetId = [NSString stringWithUTF8String:(char*) xmlGetProp(child, (xmlChar*)"id")];
            [assets addObject:assetId];
		}
	}
	
	return assets;
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