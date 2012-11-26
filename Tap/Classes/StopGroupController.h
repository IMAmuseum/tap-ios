//
//  StopGroupController.h
//  Tap
//
//  Created by Daniel Cervantes on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class TAPTour, TAPStop, TAPAsset, TAPAssetRef, TAPConnection, TAPContent, TAPProperty, TAPSource;

@interface StopGroupController : UIViewController <AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *stopGroupTable;
	IBOutlet UIImageView *bannerImage;
	
	TAPStop *stopGroup;
    NSMutableArray *stops;
    BOOL sectionsEnabled;
    
    AVAudioPlayer *audioPlayer;
    UISlider *audioScrubber;
    UIButton *pausePlayButton;
    UILabel *currentTime;
    UILabel *trackDuration;
    UILabel *trackTitle;
    NSTimer *playbackTimer;
}

@property (nonatomic, retain) UITableView *stopGroupTable;
@property (nonatomic, retain) TAPStop *stopGroup;
@property (nonatomic, retain) NSMutableArray *stops;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) IBOutlet UISlider *audioScrubber;
@property (nonatomic, retain) IBOutlet UIButton *pausePlayButton;
@property (nonatomic, retain) IBOutlet UILabel *currentTime;
@property (nonatomic, retain) IBOutlet UILabel *trackDuration;
@property (nonatomic, retain) IBOutlet UILabel *trackTitle;
@property (nonatomic, retain) NSTimer *playbackTimer;

- (id)initWithStop:(TAPStop *)stop;

@end
