//
//  TapBeacon.h
//  Tap
//
//  Created by Kyle Jaebker on 1/8/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TapBeacon : NSObject

@property (nonatomic, strong) NSUUID *uuid;
@property (nonatomic, strong) NSString *bId;
@property (nonatomic) int major;
@property (nonatomic) int minor;
@property (nonatomic, strong) CLBeacon *beacon;
@property (nonatomic, strong) NSArray *stopIds;

- (id)initWithId:(NSString *)bId uuid:(NSUUID *)uuid major:(int)major minor:(int)minor;
- (NSString *)proximityToString;

@end
