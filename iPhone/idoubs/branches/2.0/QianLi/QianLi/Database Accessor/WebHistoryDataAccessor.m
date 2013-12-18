//
//  WebHistoryDataAccessor.m
//  QianLi
//
//  Created by lutan on 10/18/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "WebHistoryDataAccessor.h"
#import "QianLiAppDelegate.h"

@interface WebHistoryDataAccessor (){
    NSManagedObjectContext *_managedObjectContext;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation WebHistoryDataAccessor

@synthesize managedObjectContext = _managedObjectContext;

+ (WebHistoryDataAccessor *)sharedInstance
{
    static WebHistoryDataAccessor *webHistAccessor;
    if (webHistAccessor == nil) {
        webHistAccessor = [[WebHistoryDataAccessor alloc] init];
        QianLiAppDelegate *appDelegate = (QianLiAppDelegate *)[UIApplication sharedApplication].delegate;
        webHistAccessor.managedObjectContext = appDelegate.managedObjectContext;
    }
    return webHistAccessor;
}

- (void)insert:(NSString *)title url:(NSString *)url type:(NSString *)type
{
    [self.managedObjectContext lock];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"WebHistory" inManagedObjectContext:_managedObjectContext];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:title forKey:@"title"];
    [newManagedObject setValue:url forKey:@"url"];
    [newManagedObject setValue:type forKey:@"type"];
    
    // Save the context.
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.managedObjectContext unlock];
}

- (void)update:(NSString *)title url:(NSString *)url type:(NSString *)type
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"url";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,url]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WebHistory" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:title forKey:@"title"];
        [object setValue:type forKey:@"type"];
        
        if (!error) {
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"saving error during updating");
            }
        }
    }
    else{
        [self insert:title url:url type:type];
    }
    [self.managedObjectContext unlock];
}


- (NSArray *)getAllObjectsWithType:(NSString *)type
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"type";
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"WebHistory"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,type]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        [self.managedObjectContext unlock];
        return items;
    }
    else{
        NSLog(@"fetch error");
        [self.managedObjectContext unlock];
        return nil;
    }
}

- (void)deleteObjectForType:(NSString *)type
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"type";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName ,type]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"WebHistory" inManagedObjectContext:self.managedObjectContext];
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

@end
