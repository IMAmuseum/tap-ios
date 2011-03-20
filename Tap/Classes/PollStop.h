#import <Foundation/Foundation.h>

#import "BaseStop.h"

@interface PollStop : BaseStop <Stop> {

}

-(NSString*)getQuestion;

-(NSInteger)numberOfAnswers;

-(NSArray*)getAnswers;

@end
