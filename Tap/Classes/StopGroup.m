#import "StopGroup.h"

#import "StopGroupController.h"


@implementation StopGroup

-(NSInteger)numberOfStops
{
	NSInteger result = 0;
	xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
	xpathCtx = xmlXPathNewContext(stopNode->doc);
    if(xpathCtx == NULL) {
		NSLog(@"Unable to create new XPath context.");
		return NO;
    }
	xmlXPathRegisterNs(xpathCtx, (xmlChar*)TOURML_XML_PREFIX, (xmlChar*)TOURML_XMLNS);
    
	NSString *stopXPath = [NSString stringWithFormat:@"/tourml:Tour/tourml:Connection[@tourml:srcId='%@']", [self getStopId]];
	xmlChar *xpathExpr = (xmlChar*)[stopXPath UTF8String];
	xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    if(xpathObj == NULL) 
    {
        NSLog(@"Unable to evaluate xpath expression: %@", xpathExpr);
		xmlXPathFreeContext(xpathCtx);
        return NO;
    }
	if (xmlXPathNodeSetIsEmpty(xpathObj->nodesetval)) 
    {
		NSLog(@"Unable to find matching node.");
        xmlXPathFreeContext(xpathCtx);
		xmlXPathFreeObject(xpathObj);
        return NO;
	}
	
	for (int i = 0; i < xpathObj->nodesetval->nodeNr; i++) 
    {
		result++;
	}
	
    xmlXPathFreeContext(xpathCtx);
	xmlXPathFreeObject(xpathObj);	

	return result;
}

-(BaseStop*)stopAtIndex:(NSInteger)index
{
    NSMutableArray *stops = [TourMLUtils getStopConnectionsByPriority:stopNode->doc withSource:[self getStopId]];

    NSString *stop = [stops objectAtIndex:index];
    if([stop length] != 0) {
        xmlNodePtr refStopNode = [TourMLUtils getStopInDocument:stopNode->doc withIdentifier:stop];            
        return [StopFactory newStopForStopNode:refStopNode];            
    }
    return NULL;
}

-(NSString*)getHeaderPortraitImage
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) 
    {
		if (xmlStrEqual(child->name, (xmlChar*)"AssetRef")) 
        {
			xmlChar *usage = xmlGetProp(child, (xmlChar*)"usage");
			if (usage && (strcmp((char*)usage, "header-image-portrait") == 0)) 
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
                        xmlFree(usage);
                        return result;                        
                    }
                }
			}
			xmlFree(usage);
		}
	}
	
	return nil;
}

-(NSString*)getHeaderLandscapeImage
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) 
    {
		if (xmlStrEqual(child->name, (xmlChar*)"AssetRef")) 
        {
			xmlChar *usage = xmlGetProp(child, (xmlChar*)"usage");
			if (usage && (strcmp((char*)usage, "header-image-landscape") == 0)) 
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
                        xmlFree(usage);
                        return result;                        
                    }
                }
			}
			
			xmlFree(usage);
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
	return [[StopGroupController alloc] initWithStopGroup:self];
}

@end
