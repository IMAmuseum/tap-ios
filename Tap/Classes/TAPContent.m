//
//  TAPContent.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import "TAPContent.h"
#import "TAPAsset.h"
#import "TAPProperty.h"
#import "GDataXMLNode.h"


@implementation TAPContent

@dynamic data;
@dynamic format;
@dynamic language;
@dynamic part;
@dynamic asset;
@dynamic propertySet;

- (NSObject *)getParsedData {
    NSObject *returnData = NULL;
    NSError *error;
    
    if ([self.format isEqualToString:@"text/xml"]) {
        returnData = [[GDataXMLDocument alloc] initWithXMLString:self.data options:0 error:&error];
    } else {
        returnData = self.data;
    }
    
    return returnData;
}

@end
