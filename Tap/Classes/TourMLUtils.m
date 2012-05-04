#import "TourMLUtils.h"
#import "XPathQuery.h"

@implementation TourMLUtils

+ (xmlNodePtr)getAsset:(xmlDocPtr)document withIdentifier:(NSString*)ident
{
	xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
	
	xpathCtx = xmlXPathNewContext(document);
    if(xpathCtx == NULL) {
		NSLog(@"Unable to create new XPath context.");
		return NO;
    }
	xmlXPathRegisterNs(xpathCtx, (xmlChar*)TOURML_XML_PREFIX, (xmlChar*)TOURML_XMLNS);

	NSString *stopXPath = [NSString stringWithFormat:@"/tourml:Tour/tourml:Asset[@tourml:id='%@']", ident];
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
	
	xmlNodePtr asset = NULL;
	for (int i = 0; i < xpathObj->nodesetval->nodeNr; i++) 
    {
		asset = xpathObj->nodesetval->nodeTab[i];
		break;
	}
	
    xmlXPathFreeContext(xpathCtx);
	xmlXPathFreeObject(xpathObj);
    
	return asset;
}

+ (NSMutableArray*)getStopConnectionsByPriority:(xmlDocPtr)document withSource:(NSString*)sourceId
{
    NSMutableDictionary *stops = [[NSMutableDictionary alloc] init];
	xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    
	xpathCtx = xmlXPathNewContext(document);
    if(xpathCtx == NULL) {
		NSLog(@"Unable to create new XPath context.");
		return NO;
    }
	xmlXPathRegisterNs(xpathCtx, (xmlChar*)TOURML_XML_PREFIX, (xmlChar*)TOURML_XMLNS);
	
    NSString *stopXPath = [NSString stringWithFormat:@"/tourml:Tour/tourml:Connection[@tourml:srcId='%@']", sourceId];
	xmlChar *xpathExpr = (xmlChar*)[stopXPath UTF8String];
	xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    if(xpathObj == NULL) {
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
        int priority = [[NSString stringWithUTF8String:(char*)xmlGetProp(xpathObj->nodesetval->nodeTab[i], (xmlChar*)"priority")] intValue];
        NSString *destId = [NSString stringWithUTF8String:(char*)xmlGetProp(xpathObj->nodesetval->nodeTab[i], (xmlChar*)"destId")];
        [stops setObject:destId forKey:[NSNumber numberWithInt:priority]];
	}
    NSArray *myKeys = [stops allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *sortedValues = [[[NSMutableArray alloc] init] autorelease];
    
    for(id key in sortedKeys) 
    {
        id object = [stops objectForKey:key];
        [sortedValues addObject:object];
    }
    [stops release];
    xmlXPathFreeContext(xpathCtx);
	xmlXPathFreeObject(xpathObj);
    
    return sortedValues;
}

+ (xmlNodePtr)getStopInDocument:(xmlDocPtr)document withCode:(NSString*)code
{
	xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
	
	xpathCtx = xmlXPathNewContext(document);
    if(xpathCtx == NULL) 
    {
		NSLog(@"Unable to create new XPath context.");
		return NO;
    }
	xmlXPathRegisterNs(xpathCtx, (xmlChar*)TOURML_XML_PREFIX, (xmlChar*)TOURML_XMLNS);
	
	NSString *xPath = [NSString stringWithFormat:@"/tourml:Tour/*[tourml:PropertySet/tourml:Property[@tourml:name='code']= %@]", code];
	xmlChar *xpathExpr = (xmlChar*)[xPath UTF8String];
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
	
	xmlNodePtr stop = NULL;
	for (int i = 0; i < xpathObj->nodesetval->nodeNr; i++) 
    {
		stop = xpathObj->nodesetval->nodeTab[i];
		break;
	}
	
    xmlXPathFreeContext(xpathCtx);
	xmlXPathFreeObject(xpathObj);
	
	return stop;
}

+ (xmlNodePtr)getStopInDocument:(xmlDocPtr)document withIdentifier:(NSString*)ident
{
	xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
	
	xpathCtx = xmlXPathNewContext(document);
    if(xpathCtx == NULL) 
    {
		NSLog(@"Unable to create new XPath context.");
		return NO;
    }
	xmlXPathRegisterNs(xpathCtx, (xmlChar*)TOURML_XML_PREFIX, (xmlChar*)TOURML_XMLNS);
	
	NSString *xPath = [NSString stringWithFormat:@"/tourml:Tour/tourml:Stop[@tourml:id='%@']", ident];
	xmlChar *xpathExpr = (xmlChar*)[xPath UTF8String];
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
	
	xmlNodePtr stop = NULL;
	for (int i = 0; i < xpathObj->nodesetval->nodeNr; i++) 
    {
		stop = xpathObj->nodesetval->nodeTab[i];
		break;
	}
	
    xmlXPathFreeContext(xpathCtx);
	xmlXPathFreeObject(xpathObj);
	
	return stop;
}

+ (NSString*)getTourTitle:(xmlDocPtr)document
{
    NSArray *nodes = PerformXPathQuery(document, @"/tourml:Tour/tourml:TourMetadata/tourml:Title");
    return [[nodes objectAtIndex:0] objectForKey:@"nodeContent"];
}

+ (NSString*)getGATrackerCode:(xmlDocPtr)document
{
    NSArray *nodes = PerformXPathQuery(document, @"/tourml:Tour/tourml:TourMetadata/tourml:PropertySet/tourml:Property[@tourml:name='google-analytics']");
    return [[nodes objectAtIndex:0] objectForKey:@"nodeContent"];
}

@end
