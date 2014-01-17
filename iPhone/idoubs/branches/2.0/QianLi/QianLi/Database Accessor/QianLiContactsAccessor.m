//
//  QianLiContactsAccessor.m
//  QianLi
//
//  Created by lutan on 9/22/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "QianLiContactsAccessor.h"

#define HaveAccessedID @"firstAccess"

@interface QianLiContactsAccessor (){
    NSManagedObjectContext *_managedObjectContext;
}

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation QianLiContactsAccessor

@synthesize managedObjectContext = _managedObjectContext;
static QianLiContactsAccessor *contactsAccessor;

+ (id)sharedInstance
{
    if (!contactsAccessor)
    {
        contactsAccessor = [[QianLiContactsAccessor alloc] init];
        QianLiAppDelegate *appDelegate = (QianLiAppDelegate *)[UIApplication sharedApplication].delegate;
        contactsAccessor.managedObjectContext = appDelegate.managedObjectContext;
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        if (![userData boolForKey:HaveAccessedID]) {
            [userData setBool:YES forKey:HaveAccessedID];
            [contactsAccessor insertNewObject:@"qianli" Email:@"no" Profile:nil Numbers:@"008600000000000" UpdateCounter:1];
        }
    }
    return contactsAccessor;
}

- (NSArray *)getAllContacts
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:@"QianLiContacts"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        items = nil;
    }
    [self.managedObjectContext unlock];
    return items;
}

- (NSString *)getNameForRemoteParty:(NSString *)remoteParty
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"QianLiContacts"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    NSString *attributeName = @"number";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName, remoteParty]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (int i = 0; i < [items count]; ++i) {
            NSManagedObject *managedObject = [items objectAtIndex:0];
            [self.managedObjectContext unlock];
            return [managedObject valueForKey:@"name"];
        }
    }
    else{
        NSLog(@"fetch error");
    }
    [self.managedObjectContext unlock];
    return nil;
}

- (void)deleteItemForRemoteParty:(NSString *)remoteParty
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"QianLiContacts"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    NSString *attributeName = @"number";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName, remoteParty]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (int i = 0; i < [items count]; ++i) {
            NSManagedObject *managedObject = [items objectAtIndex:i];
            [self.managedObjectContext deleteObject:managedObject];
        }
    }
    else{
        NSLog(@"fetch error");
    }
    
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.managedObjectContext unlock];
}

- (UIImage *)getProfileForRemoteParty:(NSString *)remoteParty
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"QianLiContacts"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    NSString *attributeName = @"number";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName, remoteParty]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        for (int i = 0; i < [items count]; ++i) {
            NSManagedObject *managedObject = [items objectAtIndex:0];
            [self.managedObjectContext unlock];
            return [UIImage imageWithData:[managedObject valueForKey:@"profile"]];
        }
    }
    else{
        NSLog(@"fetch error");
    }
    [self.managedObjectContext unlock];
    return nil;
}

// Insert new contacts
- (void)insertNewObject:(NSString *)name Email: (NSString *)email Profile:(UIImage *)profile Numbers:(NSString *)number UpdateCounter:(NSInteger)nums
{
    [self.managedObjectContext lock];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"QianLiContacts" inManagedObjectContext:_managedObjectContext];
    
    UIImage *image;
    if (profile == nil) {
        image = [UIImage imageNamed:@"blank.png"];
    }
    else{
        image = profile;
    }
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:name forKey:@"name"];
    [newManagedObject setValue:email forKey:@"email"];
    [newManagedObject setValue:UIImageJPEGRepresentation(image, 0.5) forKey:@"profile"];
    [newManagedObject setValue:number forKey:@"number"];
    [newManagedObject setValue:[NSNumber numberWithInteger:nums] forKey:@"updatecounter"];
    
    // Save the context.
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.managedObjectContext unlock];
}

- (void)deleteAllObjects
{
    [self.managedObjectContext lock];
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:@"QianLiContacts"];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    
    NSError *error;
    NSArray *items = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        [self.managedObjectContext unlock];
        return;
    }
    
    for (NSManagedObject *managedObject in items) {
        [_managedObjectContext deleteObject:managedObject];
    }
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.managedObjectContext unlock];
}

- (void)updateName:(NSString *)name forNumber:(NSString *)number
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"number";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'",attributeName, number]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QianLiContacts" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:name forKey:@"name"];
        if (!error) {
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"saving error during updating");
            }
        }
    }
    else{
        NSLog(@"no such item");
    }
    [self.managedObjectContext unlock];
}

- (void)updateProfile:(UIImage *)profile updateCounter:(NSInteger)updateCouner forNumber:(NSString *)number
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"number";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ == '%@'",attributeName, number]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QianLiContacts" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:UIImageJPEGRepresentation(profile, 0.5) forKey:@"profile"];
        [object setValue:[NSNumber numberWithInteger:updateCouner] forKey:@"updatecounter"];
        if (!error) {
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"saving error during updating");
            }
        }
    }
    else{
        NSLog(@"no such item");
    }
    [self.managedObjectContext unlock];
}

- (void)updateProfile:(UIImage *)profile updateCounter:(NSInteger)updateCouner name:(NSString *)name forNumber:(NSString *)number
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"number";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'", attributeName,number]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QianLiContacts" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:UIImageJPEGRepresentation(profile, 0.5) forKey:@"profile"];
        [object setValue:[NSNumber numberWithInteger:updateCouner] forKey:@"updatecounter"];
        [object setValue:name forKey:@"name"];
        if (!error) {
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"saving error during updating");
            }
        }
    }
    else{
        NSLog(@"no such item");
    }
    [self.managedObjectContext unlock];
}

- (void)updateCounter:(NSInteger)updateCouner forNumber:(NSString *)number
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"number";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'", attributeName,number]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QianLiContacts" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        NSManagedObject *object = [results objectAtIndex:0];
        [object setValue:[NSNumber numberWithInteger:updateCouner] forKey:@"updatecounter"];
        if (!error) {
            NSError *saveError;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"saving error during updating");
            }
        }
    }
    else{
        NSLog(@"no such item");
    }
    [self.managedObjectContext unlock];
}

- (BOOL)hasContactNumber:(NSString *)number
{
    [self.managedObjectContext lock];
    NSString *attributeName = @"number";
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ like '%@'", attributeName,number]];
    [request setPredicate:predicate];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"QianLiContacts" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if ([results count] > 0) {
        [self.managedObjectContext unlock];
        return YES;
    }
    else{
        [self.managedObjectContext unlock];
        return NO;
    }
}

- (void)clearSharedInstance
{
    contactsAccessor = nil;
}

@end
