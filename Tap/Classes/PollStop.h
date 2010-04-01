//
//  PollStop.h
//  Tap
//
//  Created by Charlie Moad on 5/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BaseStop.h"

@interface PollStop : BaseStop {

}

-(NSString*)getQuestion;

-(NSInteger)numberOfAnswers;

-(NSArray*)getAnswers;

@end
