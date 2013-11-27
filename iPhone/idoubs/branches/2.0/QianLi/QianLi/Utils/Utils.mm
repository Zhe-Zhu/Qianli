//
//  Utils.m
//  VoIPModule
//
//  Created by Chen Xiangwen on 22/6/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "Utils.h"
#import "UserDataTransUtils.h"
#import "UserDataAccessor.h"
#import "MainHistoryDataAccessor.h"
#import "QianLiContactsAccessor.h"

@implementation Utils

+ (void)networkAlert:(NSString*)message{
	if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QianLi"
//														message:message
//													   delegate:nil
//											  cancelButtonTitle:NSLocalizedString(@"AlertMsgButtonOkText", nil)
//											  otherButtonTitles: nil];
//		[alert show];
	}
}

+ (void)newMessageAlert:(NSString*)message{
	if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
//		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QianLi"
//														message:message
//													   delegate:self
//											  cancelButtonTitle:NSLocalizedString(@"AlertMsgButtonCancelText", nil)
//											  otherButtonTitles:NSLocalizedString(@"AlertMsgButtonOkText", nil), nil];
//		[alert show];
	}
}

// 内容友好的时间显示方式
+ (NSString *)readableTimeFromSecondsSince1970: (double)time
{
    NSDate *d=[NSDate dateWithTimeIntervalSince1970:time];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    //    发表在一小时之内
    if (cha/3600<1) {
        if (cha/60<1) {
            timeString = @"1";
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    //    在一小时以上24小以内
    else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    //    发表在24以上10天以内
    else if (cha/86400>1&&cha/864000<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    //    发表时间大于10天
    else
    {
        NSDateFormatter *date=[[NSDateFormatter alloc] init];
        [date setDateFormat:@"yyyy年M月dd日"];
        timeString = [date stringFromDate:d];
    }
    return timeString;
}

// 内容友好的时间显示方式微信版
+ (NSString *)readableTimeFromSecondsSince1970LikeWeixin: (double)time
{
    // 得到当前日期(精确到日)
    NSDate *referenceDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-M-dd"];
    NSString *timeString = [dateFormatter stringFromDate:nowDate];
    // 计算今天凌晨时间,判断发送时间是否在今天之内
    NSDate *todayDawnTime = [dateFormatter dateFromString:timeString];
    NSTimeInterval passTime = [referenceDate timeIntervalSinceDate:todayDawnTime];
    if (passTime>=0 && passTime < 60*60*24) {
        // 在今天之内
        NSDateFormatter *todayFormatter = [[NSDateFormatter alloc] init];
        [todayFormatter setDateFormat:@"aah:mm"];
        timeString = [todayFormatter stringFromDate:referenceDate];
    }
    else if (passTime < 0 && passTime >= -60*60*24) {
        timeString = NSLocalizedString(@"yesterday", nil);
    }
    else if (passTime < -60*60*24) {
        // 判断是否还在这一周中
        NSDateFormatter *weekFirstDayFormatter = [[NSDateFormatter alloc] init];
        [weekFirstDayFormatter setDateFormat:@"c"];
        int dayDiff = [[weekFirstDayFormatter stringFromDate:todayDawnTime] intValue];
        NSDate *weekFirstDay = [NSDate dateWithTimeInterval:-(dayDiff - 1)*60*60*24 sinceDate:todayDawnTime];
        if ([referenceDate compare:weekFirstDay] == NSOrderedDescending) {
            switch([[weekFirstDayFormatter stringFromDate:referenceDate] intValue])
            {
                case 1:
                    timeString = NSLocalizedString(@"sunday", nil);
                    break;
                case 2:
                    timeString = NSLocalizedString(@"monday", nil);
                    break;
                case 3:
                    timeString = NSLocalizedString(@"tuesday", nil);
                    break;
                case 4:
                    timeString = NSLocalizedString(@"wednesday", nil);
                    break;
                case 5:
                    timeString = NSLocalizedString(@"thursday", nil);
                    break;
                case 6:
                    timeString = NSLocalizedString(@"friday", nil);
                    break;
                default:
                    timeString = NSLocalizedString(@"saturday", nil);
                    break;
            }
        }
        else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yy-M-dd"];
            timeString = [dateFormatter stringFromDate:referenceDate];
        }
    }
    return timeString;
}

+ (NSString *)createNewUUID {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string ;
}

+ (NSString *)getDeviceUDID
{
    NSString *retrieveuuid = [SSKeychain passwordForService:@"com.ashstudio.qianli" account:@"udid"];
    if (retrieveuuid == nil) {
        // if this is the first time app lunching , create key for device
        NSString *uuid  = [self createNewUUID];
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:@"com.ashstudio.qianli" account:@"udid"];
    }
    return retrieveuuid;
}

+ (BOOL)checkInternetAndDispWarning:(BOOL)willDisplay
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        if (willDisplay) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"noNetworkTitle", nil) message:NSLocalizedString(@"noNetworkMessage", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alertView show];
        }
        return NO;
    }
    return YES;
}

// This method is used to get a string from another string by removing all the spaces in itself. This method is useful during registration process because we don't want there are any spaces in the udid, password or any other information filled by user.
+ (NSString *)stringbyRmovingSpaceFromString:(NSString *)string
{
    NSArray* words = [string componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    return nospacestring;
}

+(void)updateMainHistNameForRemoteParty:(NSString *)remote
{
    NSString *name = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:remote];
    if (name) {
        [[MainHistoryDataAccessor sharedInstance] updateNameForRemotyParty:remote withName:name];
    }
    else{
        [UserDataTransUtils getUserData:remote Completion:^(NSString *name, NSString *avatarURL) {
            if (name == nil) {
                name = NSLocalizedString(@"unknownName", nil);
            }
            [[MainHistoryDataAccessor sharedInstance] updateNameForRemotyParty:remote withName:name];
        }];
    }
}

+ (BOOL)isHeadsetPluggedIn
{
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    OSStatus error = AudioSessionGetProperty (kAudioSessionProperty_AudioRoute, &routeSize, &route);
    
    /* Known values of route:
     * "Headset"
     * "Headphone"
     * "Speaker"
     * "SpeakerAndMicrophone"
     * "HeadphonesAndMicrophone"
     * "HeadsetInOut"
     * "ReceiverAndMicrophone"
     * "Lineout"
     */
    
    if (!error && (route != NULL)) {
        NSString* routeStr = (__bridge NSString*)route;
        NSRange headphoneRange = [routeStr rangeOfString : @"Head"];
        if (headphoneRange.location != NSNotFound){
            return YES;
        }
    }
    
    return NO;
}

@end
