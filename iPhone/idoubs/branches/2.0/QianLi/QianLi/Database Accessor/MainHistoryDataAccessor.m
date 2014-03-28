//
//  MainHistoryDataAccessor.m
//  QianLi
//
//  Created by lutan on 8/21/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "MainHistoryDataAccessor.h"

@interface MainHistoryDataAccessor ()
{
   NSManagedObjectContext *_managedObjectContext;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation MainHistoryDataAccessor

@synthesize managedObjectContext = _managedObjectContext;
 static MainHistoryDataAccessor *mainHistoryDataAccessor;

+(id)sharedInstance
{
    if (!mainHistoryDataAccessor)
    {
        mainHistoryDataAccessor = [[MainHistoryDataAccessor alloc] init];
        QianLiAppDelegate *appDelegate = (QianLiAppDelegate *)[UIApplication sharedApplication].delegate;
        mainHistoryDataAccessor.managedObjectContext = appDelegate.managedObjectContext;
    }
    return mainHistoryDataAccessor;
}

// Insert new contacts
- (void)insertNewObject:(NSString *)remoteParty Content: (NSString *)content Time:(double)time Type:(NSString *)type
{
    [self.managedObjectContext lock];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"MainRecent" inManagedObjectContext:_managedObjectContext];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:remoteParty forKey:@"remoteParty"];
    [newManagedObject setValue:content forKey:@"content"];
    [newManagedObject setValue:[NSNumber numberWithDouble:time] forKey:@"time"];
    [newManagedObject setValue:type forKey:@"type"];
    
    // Save the context.
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
       // NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.managedObjectContext unlock];
}

- (void)deleteAllObjects
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MainRecent"];
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
        //NSLog(@"fetch error");
    }
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
        //NSLog(@"saving error during updating");
    }
    [self.managedObjectContext unlock];
}

- (void)deleteObjectForRemoteParty:(NSString *)remoteParty
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,remoteParty]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainRecent" inManagedObjectContext:self.managedObjectContext];
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
        //NSLog(@"fetch error");
    }
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]) {
        //NSLog(@"saving error during updating");
    }
    [self.managedObjectContext unlock];
}

- (void)updateForRemoteParty:(NSString *)remoteParty Content: (NSString *)content Time:(double)time Type:(NSString *)type
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,remoteParty]];
    [request setPredicate:predicate];
     NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainRecent" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] == 1) {
        NSManagedObject *object = [results objectAtIndex:0];
        double oldTime = [(NSNumber *)[object valueForKey:@"time"] doubleValue];
        if (oldTime < time) {
            [object setValue:content forKey:@"content"];
            [object setValue:[NSNumber numberWithDouble:time] forKey:@"time"];
            [object setValue:type forKey:@"type"];
            
            if (!error) {
                NSError *saveError;
                if (![self.managedObjectContext save:&saveError]) {
                    //NSLog(@"saving error during updating");
                }
            }

        }
    }
    else if ([results count] > 1){
        [self deleteObjectForRemoteParty:remoteParty];
        [self insertNewObject:remoteParty Content:content Time:time Type:type];
    }
    else{
        [self insertNewObject:remoteParty Content:content Time:time Type:type];
    }
    [self.managedObjectContext unlock];
}

- (NSArray *)getAllObjects
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MainRecent"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        [self.managedObjectContext unlock];
        return items;
    }
    else{
       // NSLog(@"fetch error");
        [self.managedObjectContext unlock];
        return nil;
    }
}

- (void)updateNameForRemotyParty:(NSString *)remoteParty withName:(NSString *)name
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,remoteParty]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainRecent" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] >= 1) {
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:name forKey:@"name"];
        if (!error) {
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
               // NSLog(@"saving error during updating name");
            }
        }
    }
    [self.managedObjectContext unlock];
}

- (NSString *)getNameForRemoteParty:(NSString *)remote
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName, remote]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainRecent" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] >= 1) {
        NSManagedObject *object = [results objectAtIndex:0];
        NSString *name = [object valueForKey:@"name"];
        if (!error) {
            [self.managedObjectContext unlock];
            return name;
        }
    }
    return @"";
    [self.managedObjectContext unlock];
}

- (void)updateTypeForRemotyParty:(NSString *)remoteParty withType:(NSString *)type
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"remoteParty";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,remoteParty]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MainRecent" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] >= 1) {
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:type forKey:@"type"];
        if (!error) {
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
               // NSLog(@"saving error during updating type");
            }
        }
    }
    [self.managedObjectContext unlock];
}

- (void)clearSharedInstance
{
    mainHistoryDataAccessor = nil;
}

@end
