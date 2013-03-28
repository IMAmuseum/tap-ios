//
//  VideoStopController.h
//  Tap
//
//  Created by Daniel Cervantes on 8/16/12.
//  Copyright (c) 2012 Indianapolis Museum of Art. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@class VideoStop;

@interface VideoStopViewController : MPMoviePlayerViewController

- (id)initWithStop:(VideoStop *)stop;

@end