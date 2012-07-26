//
//  AudioControlViewController.m
//  Tap
//
//  Created by Daniel Cervantes on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioControlViewController.h"

@interface AudioControlViewController (Private)
- (IBAction)togglePlay;
- (IBAction)moveScurbber:sender;
- (void)updateTime;
@end

@implementation AudioControlViewController

@synthesize audioPlayer = _audioPlayer;
@synthesize audioScrubber = _audioScrubber;
@synthesize pausePlayButton = _pausePlayButton;
@synthesize currentTime = _currentTime;
@synthesize trackDuration = _trackDuration;
@synthesize trackTitle = _trackTitle;
@synthesize playbackTimer = _playbackTimer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
    
    [_audioScrubber setThumbImage:[UIImage imageNamed:@"slider-button.png"] forState:UIControlStateNormal];
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"classical" ofType:@"wav"]];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        [_audioPlayer setDelegate:self];
        [_audioPlayer prepareToPlay];
        [_audioScrubber setMaximumValue:(int)[_audioPlayer duration] - 1];
        [_audioScrubber setMinimumValue:0.0f];
        [_audioScrubber setValue:0.0f];
        float minutes = floor(_audioPlayer.duration / 60);
        float seconds = _audioPlayer.duration - (minutes * 60);
        NSString *duration = [[NSString alloc] initWithFormat:@"%0.0f:%02.0f", minutes, seconds];
        [_trackDuration setText:duration];
        [duration release];
        [self togglePlay];
    }    
}

- (IBAction)togglePlay
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
        [_pausePlayButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        [_playbackTimer invalidate];
    } else {
        [_audioPlayer play];
        [_pausePlayButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        _playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

- (IBAction)moveScurbber:sender
{
    [_audioPlayer stop];
    [_audioPlayer setCurrentTime:_audioScrubber.value];
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

-(void)updateTime
{
    float minutes = floor(_audioPlayer.currentTime / 60);
    float seconds = _audioPlayer.currentTime - (minutes * 60);
    
    NSString *duration = [[NSString alloc] initWithFormat:@"%0.0f:%02.0f", minutes, seconds];
    [_currentTime setText:duration];
    [duration release];
    
    [_audioScrubber setValue:_audioPlayer.currentTime];
}

#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        [_pausePlayButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    }
}

- (void)dealloc
{
    [_audioPlayer release];
    [_audioScrubber release];
    [_pausePlayButton release];
    [_currentTime release];
    [_trackDuration release];
    [_trackTitle release];
    [_playbackTimer release];
    [super dealloc];
}

@end
