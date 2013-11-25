//
//  WebViewController.h
//  QianLi
//
//  Created by lutan on 9/17/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate>

@property(nonatomic, strong) NSString *initialURL; // 打开web时初始的URL, 默认为空, 然后跳转到让用户输入URL的界面
@property(nonatomic, strong) NSString *remoteURL;
@property(nonatomic) CGPoint remoteOffset;
@property(nonatomic) BOOL fromRemote;
@property(nonatomic) BOOL inComing;

- (void)loadWebWithURL:(NSString *)url;
- (void)cancelFromRemoteParty;
- (void)synSuccessed;

@end
