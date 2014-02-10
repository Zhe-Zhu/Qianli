//
//  QianLiAppDelegate.h
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "ImageDisplayController.h"
#import "UserDataAccessor.h"
#import "UINavigationControllerPortraitViewController.h"
#import "UITabBarController+Portrait.h"
#import "HelpView.h"

@interface QianLiAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) UITabBarController *tabController;
@property (nonatomic, assign) BOOL didJustLaunch;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (QianLiAppDelegate *)sharedInstance;
- (void)resetRootViewController;
- (id)getAppDelegateAudioVC;
- (void)setTabItemBadge:(NSInteger)number;
- (NSInteger)getTabItemBadge;

@end
