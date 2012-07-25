//
//  TAPSource.m
//  Tap
//
//  Created by Daniel Cervantes on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPSource.h"
#import "TAPAsset.h"
#import "TAPProperty.h"
#import "TAPTour.h"
#import "AppDelegate.h"

@implementation TAPSource

@dynamic format;
@dynamic language;
@dynamic lastModified;
@dynamic part;
@dynamic uri;
@dynamic propertySet;
@dynamic relationship;

- (NSString *)uri 
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;

    [self willAccessValueForKey:@"uri"];
    NSString *originalUri = [self primitiveValueForKey:@"uri"];
    [self didAccessValueForKey:@"uri"];
    
    NSURL *url = [NSURL URLWithString:originalUri];
    // verify uri isn't a remote path
    if (![[url scheme] isEqualToString:@"http"] && ![[url scheme] isEqualToString:@"https"]) {
        // check if file exists locally and return if true
        if ([[NSFileManager defaultManager] fileExistsAtPath:originalUri]) {
            return originalUri;
        }
    }
    
    NSString *localPath = nil;
    // setup request
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // setup connection and make request for file
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (data != nil){
        // generate path for tour
        NSString *assetsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", appDelegate.currentTour.id]];
        // get the local path
        localPath = [assetsDirectory stringByAppendingPathComponent:[originalUri lastPathComponent]];
        // write file to local path
        [data writeToFile:localPath atomically:YES];
        // update the model to include the new uri path
        [self setUri:localPath];
    } else {
        // if we fail here for whatever reason return the original uri
        localPath = originalUri;
        NSLog(@"%@", error);
    }
    return localPath;
}

@end
