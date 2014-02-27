//
//  VideoViewController.h
//  QianLi
//
//  Created by lutan on 9/15/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoviePlayerViewController.h"
#import "Global.h"
#import "DetailHistoryAccessor.h"
#import "DetailHistEvent.h"

@interface VideoViewController : UIViewController 

@property (nonatomic, strong) NSString *url;
@property (nonatomic) double lateSynTime;
@property (nonatomic, assign) BOOL isIncoming;

- (void)loadWebSite;
- (void)cancelFromRemote;
- (void)cancelPlayerFromRemote;
- (void)playMovieStream:(NSString *)videoID;
- (void)pauseFromRemote:(BOOL)paused;
- (void)backwardFromRemote:(float)currentTime;
- (void)forwardFromRemote:(float)currentTime;

@end
