#import <Foundation/Foundation.h>

#import "BaseStop.h"

@interface PollStop : BaseStop {

}

-(NSString*)getQuestion;

-(NSInteger)numberOfAnswers;

-(NSArray*)getAnswers;

@end
