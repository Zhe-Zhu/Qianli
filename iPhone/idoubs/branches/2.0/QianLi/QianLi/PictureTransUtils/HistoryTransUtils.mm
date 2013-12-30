//
//  HistoryTransUtils.m
//  QianLi
//
//  Created by lutan on 10/16/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "HistoryTransUtils.h"
#import "SipStackUtils.h"
#import "MainHistoryDataAccessor.h"
#import "QianLiContactsAccessor.h"
#import "Utils.h"

@interface HistoryTransUtils ()

@property (nonatomic) BOOL finished;
@property (nonatomic) BOOL didFinishUpdateHist;
@property (nonatomic) BOOL willVibrate;
@property (nonatomic, weak) NSThread *backThread;
@end

@implementation HistoryTransUtils

static HistoryTransUtils *histUtils;

+(HistoryTransUtils *)sharedInstance
{
    if (histUtils == nil) {
        histUtils = [[HistoryTransUtils alloc] init];
        histUtils.finished = NO;
        histUtils.willVibrate = NO;
        histUtils.didFinishUpdateHist = YES;
    }
    return histUtils;
}

- (void)getHistoryInBackground:(BOOL)willVibrate;
{
    _willVibrate = willVibrate;
    if ([Utils checkInternetAndDispWarning:NO]) {
        if (_backThread == nil) {
            NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(getHistoryFromServer) object:nil];
            _backThread = thread;
            [_backThread start];
        }
        else if (_backThread.isFinished) {
            [_backThread start];
        }
        else{
            NSLog(@"not finished");
        }
    }
}

- (void)getHistoryFromServer
{
    if (!_didFinishUpdateHist) {
        return;
    }
    
    _didFinishUpdateHist = NO;
    _finished = NO;
    NSString *urlString= [NSString stringWithFormat:@"http://112.124.36.134:8080/dialrecords/missedcalls/%@/", [UserDataAccessor getUserRemoteParty]];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    //NSLog(@"json1:%@",jsonRequest);
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:30.0];
    
    NSURLConnection *m_URLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (m_URLConnection == nil) {
        _didFinishUpdateHist = YES;
        return;
    }
    while(!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

// #programma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //NSLog(@"connectionDidFinishLoading");
    _finished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *error;
    NSArray *JsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if ([JsonArray count] == 0) {
        _didFinishUpdateHist = YES;
        return;
    }
    if (error) {
        _didFinishUpdateHist = YES;
        return;
    }
    
    NSInteger number = 0;
    for (NSDictionary *dict in JsonArray) {
        NSString *remoteParty, *type, *dateStr;
        remoteParty = [dict objectForKey:@"calling_number"];
        type = [dict objectForKey:@"calling_type"];
        dateStr = [dict objectForKey:@"calling_date"];

        // 1 missed call
        if ([type isEqualToString:@"1"]) {
            number ++;
            
            DetailHistEvent *event = [[DetailHistEvent alloc] init];
            event.status = kHistoryEventStatus_Missed;
            event.type = kMediaType_Audio;
            event.remoteParty = remoteParty;
            
            NSArray *dateArray = [dateStr componentsSeparatedByString:@"."];
            NSDate *date = [self getDateFromRFC3339DateTimeString:[NSString stringWithFormat:@"%@%@",[dateArray objectAtIndex:0], @"Z"]];
            double startingTime = [date timeIntervalSince1970];
            event.start = startingTime;
            event.end = startingTime;
            [[DetailHistoryAccessor sharedInstance] performSelectorOnMainThread:@selector(addHistEntry:) withObject:event waitUntilDone:YES];
            
            NSString *contentStr = NSLocalizedString(@"historyDetailMissedCall", nil);
            NSArray *array = @[remoteParty, contentStr, [NSNumber numberWithDouble:startingTime], @"MissedCall"];
            [self performSelectorOnMainThread:@selector(writeHistory:) withObject:array waitUntilDone:YES];
        }
        // 2 appointment
        else if ([type isEqualToString:@"0"]){
            number ++;
            DetailHistEvent *event = [[DetailHistEvent alloc] init];
            event.type = kMediaType_Audio;
            event.remoteParty = remoteParty;
            event.status = kHistoryEventStatus_Appointment;
            
            NSArray *dateArray = [dateStr componentsSeparatedByString:@"."];
            NSDate *date = [self getDateFromRFC3339DateTimeString:[NSString stringWithFormat:@"%@%@",[dateArray objectAtIndex:0], @"Z"]];
            double startingTime = [date timeIntervalSince1970];
            event.start = startingTime;
            event.end = startingTime;
            [[DetailHistoryAccessor sharedInstance] performSelectorOnMainThread:@selector(addHistEntry:) withObject:event waitUntilDone:YES];
            //                NSString *contentStr = [NSString stringWithFormat:@"Appointment from %@", name];
            NSString *contentStr = NSLocalizedString(@"appointmentNoName", nil);
            NSArray *array = @[remoteParty, contentStr, [NSNumber numberWithDouble:startingTime], @"Appointment"];
            [self performSelectorOnMainThread:@selector(writeHistory:) withObject:array waitUntilDone:YES];
        }
    }
    _didFinishUpdateHist = YES;
    if (_willVibrate) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    NSNotification *notif = [NSNotification notificationWithName:kHistoryChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notif waitUntilDone:NO];
    QianLiAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate setTabItemBadge:number + [appDelegate getTabItemBadge]];
}

- (NSDate *)getDateFromRFC3339DateTimeString:(NSString *)rfc3339DateTimeString
{
    /*
     Returns a user-visible date time string that corresponds to the specified
     RFC 3339 date time string. Note that this does not handle all possible
     RFC 3339 date time strings, just one of the most common styles.
     */
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [NSLocale currentLocale];//[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:locale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
    return date;
}

- (void)writeHistory:(NSArray *)array
{
    NSString *remoteParty = [array objectAtIndex:0];
    NSString *contentStr = [array objectAtIndex:1];
    double startingTime = [[array objectAtIndex:2] doubleValue];
    NSString *type = [array objectAtIndex:3];
    if ([type isEqualToString:@"MissedCall"]) {
        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:remoteParty Content:contentStr Time:startingTime Type:@"MissedCall"];
        [Utils updateMainHistNameForRemoteParty:remoteParty];
    }
    else{
        [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:remoteParty Content:contentStr Time:startingTime Type:kMainHistAppMark];
        [Utils updateMainHistNameForRemoteParty:remoteParty];
    }
}

- (void)clearSharedInstance
{
    histUtils = nil;
}

@end
