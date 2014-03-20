//
//  WaitingListUtils.m
//  QianLi
//
//  Created by LG on 2/13/14.
//  Copyright (c) 2014 Ash Studio. All rights reserved.
//

#import "WaitingListUtils.h"
#import "Utils.h"
#import "UserDataAccessor.h"

enum WaitingListNetworkType
{
	WaitingList_CheckingStatus,
	WaitingList_AddPartner
};


@interface WaitingListUtils ()

@property(strong, nonatomic) NSMutableArray *connections;
@property(nonatomic, assign) BOOL finished;
@end

@implementation WaitingListUtils

static WaitingListUtils *waitingListUtils;
+ (WaitingListUtils *)sharedInstance
{
    if (waitingListUtils == nil) {
        waitingListUtils = [[WaitingListUtils alloc] init];
        waitingListUtils.connections = [NSMutableArray arrayWithCapacity:1];
    }
    return waitingListUtils;
}

- (void)getWaitingStatus
{
    if ([Utils checkInternetAndDispWarning:YES]) {
        for (int i = 0; i < [self.connections count]; ++i) {
            NSDictionary *dict = [self.connections objectAtIndex:i];
            if ([[dict objectForKey:@"type"] integerValue] == WaitingList_CheckingStatus) {
                return;
            }
        }
        NSDictionary *info = @{@"type": [NSNumber numberWithInt:WaitingList_CheckingStatus]};
        NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(getWaitingStatusFromServer:) object:info];
        [thread start];
    }
}

- (void)addPartner:(NSString *)partnerNumber
{
    if ([Utils checkInternetAndDispWarning:YES]) {
        for (int i = 0; i < [self.connections count]; ++i) {
            NSDictionary *dict = [self.connections objectAtIndex:i];
            if ([[dict objectForKey:@"type"] integerValue] == WaitingList_AddPartner) {
                return;
            }
        }
        NSDictionary *info = @{@"partner":partnerNumber, @"type": [NSNumber numberWithInt:WaitingList_AddPartner]};
        NSThread * thread = [[NSThread alloc] initWithTarget:self selector:@selector(getWaitingStatusFromServer:) object:info];
        [thread start];
    }
}

- (void)getWaitingStatusFromServer:(NSDictionary *)info
{
    int type = [[info valueForKey:@"type"] integerValue];
    NSString *urlString;
    
    if (type == WaitingList_CheckingStatus) {
        urlString= [NSString stringWithFormat:@"%@/waitinglist/waitingstatus/%@/",kBaseURL ,[UserDataAccessor getUserWaitingNumber]];
    }
    else if (type == WaitingList_AddPartner){
        urlString= [NSString stringWithFormat:@"%@/waitinglist/addpartner/%@/%@/",kBaseURL ,[UserDataAccessor getUserWaitingNumber], [info valueForKey:@"partner"]];
    }
    _finished = NO;
    
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    //NSLog(@"json1:%@",jsonRequest);
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:30.0];
    NSURLConnection *m_URLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (m_URLConnection == nil) {
        return;
    }
    NSDictionary *connection = @{@"type": [NSNumber numberWithInt:type], @"connection": m_URLConnection};
    [self.connections addObject:connection];
    while(!_finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (NSInteger)getConnectionType:(NSURLConnection *)connection
{
    for (int i = 0; i < [self.connections count]; ++i) {
        NSDictionary *dict = [self.connections objectAtIndex:i];
        if ([dict objectForKey:@"connection"] == connection) {
            return [[dict objectForKey:@"type"] integerValue];
        }
    }
    return -1;
}

- (void)removeNetworkConnection:(NSURLConnection *)connection
{
    NSInteger num = [self.connections count];
    for (int i = 0; i < num; ++i) {
        NSDictionary *dict = [self.connections objectAtIndex:i];
        if ([dict objectForKey:@"connection"] == connection) {
            [self.connections removeObjectAtIndex:i];
            break;
        }
    }
}

// #programma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //[self removeNetworkConnection:connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self removeNetworkConnection:connection];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self removeNetworkConnection:connection];
    _finished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSInteger type = [self getConnectionType:connection];
    [self removeNetworkConnection:connection];
    NSError *error;
    NSDictionary *JsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if ([JsonArray count] == 0 || error) {
        return;
    }
    if (type == WaitingList_CheckingStatus){
        NSNotification *notif = [NSNotification notificationWithName:kCheckStatusNotification object:self userInfo:JsonArray];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notif waitUntilDone:NO];
    }
    else if (type == WaitingList_AddPartner){
        NSNotification *notif = [NSNotification notificationWithName:kAddPartnerNotification object:self userInfo:JsonArray];
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notif waitUntilDone:NO];
    }
}

@end
