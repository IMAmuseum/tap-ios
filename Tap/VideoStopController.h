//
//  VideoStopController.h
//  Tap
//
//  Created by Daniel Cervantes on 8/14/12.
//
//

#import <MediaPlayer/MediaPlayer.h>

@class TAPTour, TAPStop, TAPAsset, TAPAssetRef, TAPConnection, TAPContent, TAPProperty, TAPSource;

@interface VideoStopController : MPMoviePlayerViewController {
    TAPStop *videoStop;
}

@property (nonatomic, retain) TAPStop *videoStop;

- (id)initWithStop:(TAPStop *)stop;

@end
