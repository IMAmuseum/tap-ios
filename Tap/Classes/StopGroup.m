//
//  StopGroup.m
//  Tap
//
//  Created by Charlie Moad on 5/15/09.
//  Copyright 2009 Indianapolis Museum of Art. All rights reserved.
//

#import "StopGroup.h"

#import "StopGroupController.h"


@implementation StopGroup

-(NSInteger)numberOfStops
{
	NSInteger result = 0;
	
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"StopRef")) {
			result++;
		}
	}
	
	return result;
}

-(BaseStop*)stopAtIndex:(NSInteger)index
{
	NSInteger current = 0;
	
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"StopRef")) {
			if (current == index) {
				// Get the id attribute
				for (xmlAttrPtr attr = child->properties; attr != NULL; attr = attr->next) {
					if (xmlStrEqual(attr->name, (xmlChar*)"id")) {
						char *xid = (char*)xmlNodeGetContent(attr->children);
						NSString *ident = [NSString stringWithUTF8String:xid];
						free(xid);
						xmlNodePtr refStopNode = [TourMLUtils getStopInDocument:stopNode->doc withIdentifier:ident];
						
						return [StopFactory newStopForStopNode:refStopNode];
					}
				}
			} else {
				current++;
			}
		}
	}
	
	return NULL;
}

-(NSString*)getHeaderPortraitImage
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Param")) {
			xmlChar *key = xmlGetProp(child, (xmlChar*)"key");
			if (key && (strcmp((char*)key, "header-image-portrait") == 0)) {
				xmlChar *value = xmlGetProp(child, (xmlChar*)"value");
				NSString *result = [NSString stringWithUTF8String:(char*)value];
				xmlFree(value);
				xmlFree(key);
				return result;
			}
			
			xmlFree(key);
		}
	}
	
	return nil;
}

-(NSString*)getHeaderLandscapeImage
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Param")) {
			xmlChar *key = xmlGetProp(child, (xmlChar*)"key");
			if (key && (strcmp((char*)key, "header-image-landscape") == 0)) {
				xmlChar *value = xmlGetProp(child, (xmlChar*)"value");
				NSString *result = [NSString stringWithUTF8String:(char*)value];
				xmlFree(value);
				xmlFree(key);
				return result;
			}
			
			xmlFree(key);
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
