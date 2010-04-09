#import "TourMLUtils.h"


@implementation TourMLUtils

+ (xmlNodePtr)getStopInDocument:(xmlDocPtr)document withCode:(NSString*)code
{
	xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
	
	xpathCtx = xmlXPathNewContext(document);
    if(xpathCtx == NULL) {
		NSLog(@"Unable to create new XPath context.");
		return NO;
    }
	xmlXPathRegisterNs(xpathCtx, (xmlChar*)TOURML_XML_PREFIX, (xmlChar*)TOURML_XMLNS);
	
	NSString *stopXPath = [NSString stringWithFormat:@"/TourML:Tour/*[@code='%@']", code];
	xmlChar *xpathExpr = (xmlChar*)[stopXPath UTF8String];
	xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    if(xpathObj == NULL) {
        NSLog(@"Unable to evaluate xpath expression: %@", xpathExpr);
		xmlXPathFreeContext(xpathCtx);
        return NO;
    }
	if (xmlXPathNodeSetIsEmpty(xpathObj->nodesetval)) {
		NSLog(@"Unable to find matching node.");
        xmlXPathFreeContext(xpathCtx);
		xmlXPathFreeObject(xpathObj);
        return NO;
	}
	
	xmlNodePtr stop = NULL;
	for (int i = 0; i < xpathObj->nodesetval->nodeNr; i++) {
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
    if(xpathCtx == NULL) {
		NSLog(@"Unable to create new XPath context.");
		return NO;
    }
	xmlXPathRegisterNs(xpathCtx, (xmlChar*)TOURML_XML_PREFIX, (xmlChar*)TOURML_XMLNS);
	
	NSString *stopXPath = [NSString stringWithFormat:@"/TourML:Tour/*[@id='%@']", ident];
	xmlChar *xpathExpr = (xmlChar*)[stopXPath UTF8String];
	xpathObj = xmlXPathEvalExpression(xpathExpr, xpathCtx);
    if(xpathObj == NULL) {
        NSLog(@"Unable to evaluate xpath expression: %@", xpathExpr);
		xmlXPathFreeContext(xpathCtx);
        return NO;
    }
	if (xmlXPathNodeSetIsEmpty(xpathObj->nodesetval)) {
		NSLog(@"Unable to find matching node.");
        xmlXPathFreeContext(xpathCtx);
		xmlXPathFreeObject(xpathObj);
        return NO;
	}
	
	xmlNodePtr stop = NULL;
	for (int i = 0; i < xpathObj->nodesetval->nodeNr; i++) {
		stop = xpathObj->nodesetval->nodeTab[i];
		break;
	}
	
    xmlXPathFreeContext(xpathCtx);
	xmlXPathFreeObject(xpathObj);
	
	return stop;
}

@end
