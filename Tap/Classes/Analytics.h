#import <Foundation/Foundation.h>


@interface Analytics : NSObject {

}

// Record and event with the analytics system
+ (void)trackAction:(NSString*)action forStop:(NSString*)stop;

@end
