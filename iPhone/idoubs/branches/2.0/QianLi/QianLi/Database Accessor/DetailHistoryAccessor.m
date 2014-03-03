//
//  DetailHistoryAccessor.m
//  QianLi
//
//  Created by lutan on 11/28/13.
//  Copyright (c) 2013 Ash Studio. All rights reserved.
//

#import "DetailHistoryAccessor.h"

@interface DetailHistoryAccessor (){
    NSManagedObjectContext *_managedObjectContext;
}

@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation DetailHistoryAccessor
@synthesize managedObjectContext = _managedObjectContext;

static DetailHistoryAccessor *detailHistAccessor = nil;

+ (DetailHistoryAccessor *)sharedInstance
{
    if (detailHistAccessor == nil) {
        detailHistAccessor = [[DetailHistoryAccessor alloc] init];
        QianLiAppDelegate *appDelegate = (QianLiAppDelegate *)[UIApplication sharedApplication].delegate;
        detailHistAccessor.managedObjectContext = appDelegate.managedObjectContext;

    }
    return detailHistAccessor;
}

- (NSArray *)getDetailHistForRemoteParty:(NSString *)remoteParty withNumber:(NSInteger)number
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,remoteParty]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DetailHistory" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [request setFetchLimit:number];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!error) {
        [self.managedObjectContext unlock];
        return results;
    }
    else{
        NSLog(@"fetch error");
        [self.managedObjectContext unlock];
        return nil;
    }
}

- (NSArray *)getAllDetailHistForRemoteParty:(NSString *)remoteParty
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,remoteParty]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DetailHistory" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"start" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!error) {
        [self.managedObjectContext unlock];
        return results;
    }
    else{
        NSLog(@"fetch error");
        [self.managedObjectContext unlock];
        return nil;
    }
}

- (void)addEventWithRemoteParty:(NSString *)remote start:(double)startT end:(double)endT status:(NSString *)status type:(NSString *)type content:(NSData *)content
{
    [self.managedObjectContext lock];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"DetailHistory" inManagedObjectContext:_managedObjectContext];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:remote forKey:@"remoteParty"];
    [newManagedObject setValue:content forKey:@"content"];
    [newManagedObject setValue:[NSNumber numberWithDouble:endT] forKey:@"end"];
    [newManagedObject setValue:[NSNumber numberWithDouble:startT] forKey:@"start"];
    [newManagedObject setValue:type forKey:@"type"];
    [newManagedObject setValue:status forKey:@"status"];
    
    // Save the context.
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.managedObjectContext unlock];
}

- (void)addHistEntry:(DetailHistEvent *)entry
{
    if (entry.end >= entry.start) {
        [self addEventWithRemoteParty:entry.remoteParty start:entry.start end:entry.end status:entry.status type:entry.type content:entry.content];
    }
    else{
        [self addEventWithRemoteParty:entry.remoteParty start:entry.start end:entry.start status:entry.status type:entry.type content:entry.content];
    }
}

- (void)deleteHistoryForRemoteParty:(NSString *)remoteParty
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,remoteParty]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DetailHistory" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (!error) {
        for (int i = 0; i < [items count]; ++i) {
            NSManagedObject *managedObject = [items objectAtIndex:i];
            [self.managedObjectContext deleteObject:managedObject];
        }
    }
    else{
        NSLog(@"fetch error");
    }
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"saving error during updating");
    }
    [self.managedObjectContext unlock];
}

- (void)deleteAllHistory
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DetailHistory"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (NSManagedObject *managedObject in items) {
            [_managedObjectContext deleteObject:managedObject];
        }
    }
    else{
        NSLog(@"fetch error");
    }
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"saving error during updating");
    }
    [self.managedObjectContext unlock];
}

- (void)clearSharedInstance
{
    detailHistAccessor = nil;
}

@end
