//
//  NotificationHeader.h
//  QianLi
//
//  Created by Chen Xiangwen on 27/3/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationHeader : UIView

// present a notification in specified view, return the notification header to calling function, in order to dismiss the nofitication header later
+ (NotificationHeader *)presentNotificationHeader:(UIView *)inView inPosition:(CGPoint)position withIcon:(UIImage *)shownIcon andText:(NSString *)shownText;
//dismiss a notification header. after calling it, the calling function should release the notification header to avoid memeory leak.
+ (void)dismissNotificationHeader:(NotificationHeader *)header;


@end
