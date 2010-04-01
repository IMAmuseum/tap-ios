//
//  PollStop.m
//  Tap
//
//  Created by Charlie Moad on 5/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PollStop.h"

#import "PollStopController.h"


@implementation PollStop

-(NSString*)getQuestion
{
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Question")) {
			char *question = (char*)xmlNodeGetContent(child);
			NSString *result = [NSString stringWithUTF8String:question];
			free(question);
			return result;
		}
	}
	
	return nil;
}

-(NSInteger)numberOfAnswers
{
	NSInteger result = 0;
	
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Answer")) {
			result++;
		}
	}
	
	return result;
}

-(NSArray*)getAnswers
{
	NSMutableArray *result = [NSMutableArray array];
	
	for (xmlNodePtr child = stopNode->children; child != NULL; child = child->next) {
		if (xmlStrEqual(child->name, (xmlChar*)"Answer")) {
			char *answer = (char*)xmlNodeGetContent(child);
			[result addObject:[NSString stringWithUTF8String:answer]];
			free(answer);
		}
	}
	
	return [NSArray arrayWithArray:result];
}

#pragma mark BaseStop

-(BOOL)providesViewController
{
	return YES;
}

-(UIViewController*)newViewController
{
	return [[PollStopController alloc] initWithPollStop:self];
}

-(NSString*)getIconPath
{
	return [[NSBundle mainBundle] pathForResource:@"icon-poll" ofType:@"png"];
}

@end
