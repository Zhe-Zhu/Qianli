//
//  MoviePlayerViewController.h
//  QianLi
//
//  Created by lutan on 9/23/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Utils.h"

@interface MoviePlayerViewController : UIViewController <UIGestureRecognizerDelegate>

@property(weak, nonatomic) NSMutableArray *thumbs;
@property(strong, nonatomic) NSString *videoID;

- (void)playMovieStream:(NSURL *)movieFileURL;
- (void)forwardFromRemote:(float)currentTime;
//- (void)forward;
- (void)backwardFromRemote:(float)currentTime;
//- (void)backward;
- (void)pauseFromRemote:(BOOL)paused;
- (void)cancelMoviePlayer;

@end
