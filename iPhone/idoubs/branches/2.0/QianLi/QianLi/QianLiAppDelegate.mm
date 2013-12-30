//
//  QianLiAppDelegate.m
//  QianLi
//
//  Created by Chen Xiangwen on 5/8/13.
//  Copyright (c) 2013 Chen Xiangwen. All rights reserved.
//

#import "QianLiAppDelegate.h"
#import "QianLiContactsViewController.h"
#import "HistoryRecordsMainViewController.h"
#import "SipStackUtils.h"
#import "iOSNgnStack.h"
#import "MediaSessionMgr.h"
#import "SettingViewController.h"
#import "SignUpEditProfileViewController.h"
#import "MainHistoryDataAccessor.h"
#import "HelpViewController.h"
#import "QianLiContactsAccessor.h"
#import "HistoryTransUtils.h"
#import "MobClick.h"
#import "UMFeedback.h"
#import "SipCallManager.h"

@interface QianLiAppDelegate (){
    UITabBarController *_tabController;
    SignUpEditProfileViewController *_signUpEditProfileViewController;
    BOOL multitaskingSupported;
    BOOL didLaunch;
}

@property(nonatomic, strong) SignUpEditProfileViewController *signUpEditProfileViewController;
@property(nonatomic, weak) QianLiContactsViewController *contactViewController;
@property(nonatomic, weak) HistoryRecordsMainViewController *historyMainController;
@property(nonatomic, weak) SettingViewController *settingViewController;
@property(nonatomic, weak) QianLiAudioCallViewController *audioCallViewController;

@end

@implementation QianLiAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize tabController = _tabController;

// 最近通话 联系人 设置界面的Navigation Bar颜色
const float kColorH = 187/360.0;
const float kColorS = 70/100.0;
const float kColorB = 60/100.0;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _didJustLaunch = YES;
    didLaunch = YES;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    UITabBarController *tabController = [[UITabBarController alloc] init];
    _tabController = tabController;
    if (!IS_OS_7_OR_LATER) {
        [_tabController.tabBar setBackgroundImage:[UIImage imageNamed:@"iOS6TabbarBackground@2x.png"]];
        CGRect oldFrame = _tabController.tabBar.frame;
        [_tabController.tabBar setFrame:CGRectMake(CGRectGetMinX(oldFrame), [[UIScreen mainScreen]bounds].size.height - 49, CGRectGetWidth(oldFrame), 49)];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"iOS6TabbarEmptySelected.png"]];
        UIColor *titleHighlightedColor = [UIColor colorWithRed:94/255.0 green:201/255.0 blue:217/255.0 alpha:1.0];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           titleHighlightedColor, UITextAttributeTextColor,
                                                           nil] forState:UIControlStateHighlighted];
    }
    
    // load the storyboard by name
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    // 设置TabBar
    _contactViewController = [storyboard instantiateViewControllerWithIdentifier:@"ContactViewController"];
    _contactViewController.title = NSLocalizedString(@"contactTitle", Nil);
    UINavigationController *contactNavigationVC = [[UINavigationController alloc] init];
    // 配置navigation controller
    [contactNavigationVC.navigationBar setTranslucent:NO];
    if ([contactNavigationVC.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [contactNavigationVC.navigationBar setBarTintColor:[UIColor colorWithHue:kColorH saturation:kColorS brightness:kColorB alpha:1.0]];
    }
    [contactNavigationVC.navigationBar setBarStyle:UIBarStyleBlack];
    if (!IS_OS_7_OR_LATER) {
        [contactNavigationVC.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6SignUpNavigationBarBackground"] forBarMetrics:UIBarMetricsDefault];
    }
    //contactNavigationVC.viewControllers = @[_contactViewController];
    [contactNavigationVC pushViewController:_contactViewController animated:NO];
    // 加入Tab Bar上的Icon
    UITabBarItem *contactIcon;
    if (IS_OS_7_OR_LATER) {
        contactIcon = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"contactTitle", Nil) image:[UIImage imageNamed:@"contactIcon.png"] selectedImage:[UIImage imageNamed:@"contactIconSelected.png"]];
    }
    else{
        contactIcon = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"contactTitle", Nil) image:[UIImage imageNamed:@"contactIcon.png"] tag:9999];
        [contactIcon setFinishedSelectedImage:[UIImage imageNamed:@"contactIconSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iOS6contactIcon.png"]];
    }
    contactNavigationVC.tabBarItem = contactIcon;
    
    _historyMainController = [storyboard instantiateViewControllerWithIdentifier:@"HistroryRecordMainController"];
    _historyMainController.title = NSLocalizedString(@"recentCalls", nil);
    UINavigationController *histroyNaviCV = [[UINavigationController alloc] init];
    // 配置navigation controller
    [histroyNaviCV.navigationBar setTranslucent:NO];
    if ([histroyNaviCV.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [histroyNaviCV.navigationBar setBarTintColor:[UIColor colorWithHue:kColorH saturation:kColorS brightness:kColorB alpha:1.0]];
    }
    [histroyNaviCV.navigationBar setBarStyle:UIBarStyleBlack];
    if (!IS_OS_7_OR_LATER) {
        [histroyNaviCV.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6SignUpNavigationBarBackground"] forBarMetrics:UIBarMetricsDefault];
    }
    
    // NavigationBar下的阴影
//    UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, 2)];
//    lineView.backgroundColor = [UIColor colorWithRed:160/255.0 green:160/255.0 blue:160/255.0 alpha:0.3];
//    [histroyNaviCV.navigationBar addSubview:lineView];
   // histroyNaviCV.viewControllers = @[_historyMainController];
    [histroyNaviCV pushViewController:_historyMainController animated:NO];
    
    // 加入Tab Bar上的Icon
    UITabBarItem *historyIcon;
    if (IS_OS_7_OR_LATER) {
        historyIcon = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"recentCalls", nil) image:[UIImage imageNamed:@"historyIcon.png"] selectedImage:[UIImage imageNamed:@"historyIconSelected.png"]];
    }
    else{
        historyIcon = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"recentCalls", nil) image:[UIImage imageNamed:@"historyIcon.png"] tag:9999];
        [historyIcon setFinishedSelectedImage:[UIImage imageNamed:@"historyIconSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iOS6historyIcon.png"]];
    }
    histroyNaviCV.tabBarItem = historyIcon;
    
    // 读取storyboard中的setting view
    _settingViewController = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    _settingViewController.title = NSLocalizedString(@"setting", nil);
    UINavigationController *settingNavigationController = [[UINavigationController alloc] init];
    // 配置navigation controller
    [settingNavigationController.navigationBar setTranslucent:NO];
    if ([settingNavigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
        [settingNavigationController.navigationBar setBarTintColor:[UIColor colorWithHue:kColorH saturation:kColorS brightness:kColorB alpha:1.0]];
    }
    [settingNavigationController.navigationBar setBarStyle:UIBarStyleBlack];
    if (!IS_OS_7_OR_LATER) {
        [settingNavigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"iOS6SignUpNavigationBarBackground"] forBarMetrics:UIBarMetricsDefault];
    }
    [settingNavigationController pushViewController:_settingViewController animated:NO];
    //settingNavigationController.viewControllers = @[_settingViewController];

    // 加入Tab Bar上的Icon
    UITabBarItem *settingIcon;
    if (IS_OS_7_OR_LATER) {
        settingIcon = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"setting", nil) image:[UIImage imageNamed:@"settingIcon.png"] selectedImage:[UIImage imageNamed:@"settingIconSelected.png"]];
    }
    else{
        settingIcon = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"setting", nil) image:[UIImage imageNamed:@"settingIcon.png"] tag:9999];
        [settingIcon setFinishedSelectedImage:[UIImage imageNamed:@"settingIconSelected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"iOS6settingIcon.png"]];
    }
    settingNavigationController.tabBarItem = settingIcon;
    
    NSArray *controllers = @[histroyNaviCV, contactNavigationVC, settingNavigationController];
    _tabController.viewControllers = controllers;
    [_tabController.tabBar setTintColor:[UIColor colorWithRed:56/255.0 green:181/255.0 blue:199/255.0 alpha:1.0]];
    if ([_tabController.tabBar respondsToSelector:@selector(setTranslucent:)]) {
        [_tabController.tabBar setTranslucent:YES];
    }
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveIncomingCallNotif:) name:kReceiveIncomingCallNotifName object:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults boolForKey:kSingUpKey]) {
        self.window.rootViewController = _tabController;
        [[SipStackUtils sharedInstance] start];
        [[SipStackUtils sharedInstance].soundService configureAudioSession];
        [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
        // Register remote notification
        [self registerAPNS];
    }
    else{
        if ([userDefaults boolForKey:@"noHelp"]) {
            SignUpEditProfileViewController *signUpEditProfileViewController = [storyboard instantiateViewControllerWithIdentifier:@"RegisterNavigationController"];
            _signUpEditProfileViewController = signUpEditProfileViewController;
            self.window.rootViewController = signUpEditProfileViewController;
        }
        else {
            HelpViewController *helpViewController = [storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
            self.window.rootViewController = helpViewController;
        }
    }
    
//    NSDictionary *remoteNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    // 初始化UmengSDK
    [MobClick startWithAppkey:kUmengSDKKey];
    [UMFeedback checkWithAppkey:kUmengSDKKey];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umCheck:) name:UMFBCheckFinishedNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkEvent:) name:kNgnNetworkEventArgs_Name object:nil];
    return YES;
}

- (void)resetRootViewController
{
    [UIView transitionFromView:_signUpEditProfileViewController.view toView:_tabController.view duration:0.5 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished){
        self.window.rootViewController = _tabController;
    }];
    
    [[SipStackUtils sharedInstance] start];
    [self configureParmsWithNumber:[UserDataAccessor getUserRemoteParty]];
    [[SipStackUtils sharedInstance].soundService configureAudioSession];
    [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
    // Register remote notification
    [self registerAPNS];
}

- (void)registerAPNS
{
    UIApplication *app = [UIApplication sharedApplication];
    [app registerForRemoteNotificationTypes: (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
    [application setKeepAliveTimeout:600 handler:^{
        [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
    }];

    [_contactViewController clearContacts];
    [_historyMainController clearHistory];
    [_settingViewController clearImages];
    if ([SipCallManager SharedInstance].audioVC == nil) {
        [Utils clearAllSharedInstance];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[HistoryTransUtils sharedInstance] getHistoryInBackground:NO];
    [application clearKeepAliveTimeout];
    switch (_tabController.selectedIndex) {
        case 0:
            [_historyMainController restoreHistory];
            break;
        case 1:
            [_contactViewController restoreContacts];
            break;
        case 2:
            [_settingViewController restoreImages];
            break;
        default:
            break;
    }
    
    ConnectionState_t registrationState = [[NgnEngine sharedInstance].sipService getRegistrationState];
    switch (registrationState) {
		case CONN_STATE_CONNECTING:
        case CONN_STATE_CONNECTED:
            break;
        default:
            [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
			break;
	}
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:kSingUpKey]) {
        [self displayNoPushNotificationWarning];
        [self displayNoRecordingWarning];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //NSInteger number = [UIApplication sharedApplication].applicationIconBadgeNumber;
    //[self setTabItemBadge:number];
    if (_tabController.selectedIndex == 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    didLaunch = NO;
    // Umeng
    [UMFeedback checkWithAppkey:kUmengSDKKey];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    [[SipStackUtils sharedInstance] stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NgnEngine sharedInstance].contactService unload];
	[[NgnEngine sharedInstance].historyService clear];
	[[NgnEngine sharedInstance].storageService clearFavorites];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            //abort();
        } 
    }
}

- (void)recieveIncomingCallNotif:(NSNotification *)userInfo
{
    NSDictionary * info = [userInfo userInfo];
    NSString *notifKey = (NSString *)[info objectForKey:kNotifKey];
    // handle a incoming call
	if([notifKey isEqualToString:kNotifKey_IncomingCall])
    {
        NSNumber* sessionId = [info objectForKey:kNotifIncomingCall_SessionId];
        if ([[SipStackUtils sharedInstance].audioService hasSessionWithId:[sessionId longValue]]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UINavigationController *audioCallNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"audioCallNavigationController"];
            _audioCallViewController = [storyboard instantiateViewControllerWithIdentifier:@"audioCallViewController"];            audioCallNavigationController.viewControllers = @[_audioCallViewController];
            _audioCallViewController.ViewState = ReceivingCall;
            _audioCallViewController.audioSessionID = [sessionId longValue];
            [SipStackUtils sharedInstance].sessionID = [sessionId longValue];
            _audioCallViewController.remotePartyNumber = [[SipStackUtils sharedInstance] getRemotePartyNumber];
            [self.tabController presentViewController:audioCallNavigationController animated:YES completion:nil];
            [SipCallManager SharedInstance].audioVC = _audioCallViewController;
            
            NSString *imageSessionID = [NSString stringWithFormat:@"%@%@",[[SipStackUtils sharedInstance] getRemotePartyNumber], [UserDataAccessor getUserRemoteParty]];
            [[PictureManager sharedInstance] setImageSession:imageSessionID];
            
            NSString *name = [[QianLiContactsAccessor sharedInstance] getNameForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
            if (!name) {
                //go to server to get name;
                [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:[NSString stringWithFormat:@"Received call from %@", name] Time:[[NSDate date] timeIntervalSince1970] Type:@"InComingCall"];
            }
            [[MainHistoryDataAccessor sharedInstance] updateForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber] Content:NSLocalizedString(@"historyReceivedCall", nil) Time:[[NSDate date] timeIntervalSince1970] Type:@"InComingCall"];
            [Utils updateMainHistNameForRemoteParty:[[SipStackUtils sharedInstance] getRemotePartyNumber]];
            
            // Add to history record
            DetailHistEvent *event = [[DetailHistEvent alloc] init];
            event.remoteParty = [[SipStackUtils sharedInstance] getRemotePartyNumber];
            event.type = kMediaType_Audio;
            event.status = kHistoryEventStatus_Incoming;
            event.start = [[NSDate date] timeIntervalSince1970];
            _audioCallViewController.activeEvent = event;
        }
        else{
        }
    }
}

- (void)configureParmsWithNumber:(NSString *)number
{
    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_DISPLAY_NAME andValue:number];
    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPU andValue:[NSString stringWithFormat:@"sip:%@@112.124.36.134",number]];
    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_IMPI andValue:number];
    [[NgnEngine sharedInstance].configurationService setStringWithKey:IDENTITY_PASSWORD andValue:number];
    [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_REALM andValue:@"112.124.36.134"];
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_EARLY_IMS andValue:YES];
    [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_PCSCF_HOST andValue:@"112.124.36.134"];
   // [[NgnEngine sharedInstance].configurationService setBoolWithKey:NATT_USE_STUN_DISCO andValue:YES];
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_KEEPAWAKE andValue:YES];
    [[NgnEngine sharedInstance].configurationService setBoolWithKey:NETWORK_USE_3G andValue:YES];
    [[NgnEngine sharedInstance].configurationService setStringWithKey:NETWORK_TRANSPORT andValue:@"tcp"];
    //112.124.36.134  192.168.1.200
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"QianLi" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"QianLi.sqlite"];
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Remote Notification Delegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"get token:%@",deviceToken);
    NSString *tokenJson = [NSString stringWithFormat:@"%@*%@",deviceToken,[UserDataAccessor getUserRemoteParty]];
    
    NSString *urlString= @"http://112.124.36.134:8080/notification/gettoken/";
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSString* requestDataLengthString = [[NSString alloc] initWithFormat:@"%d", [tokenJson length]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[tokenJson dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];
    [request setTimeoutInterval:30.0];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] >0 && error == nil)
         {
             NSLog(@"Data:%@",[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
         }
         else if (error != nil)
         {
             NSLog(@"Error = %@", error.localizedDescription);
         }
     }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error in registration. Error: %@", error);
}

+ (QianLiAppDelegate *)sharedInstance
{
    return ((QianLiAppDelegate *)[[UIApplication sharedApplication] delegate]);
}

# pragma mark -- Push notification --
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
    //TODO: deleta
    UILocalNotification *locaNotif = [[UILocalNotification alloc] init];
    locaNotif.alertBody = @"qianli is launched due to push notification";
    [[UIApplication sharedApplication] presentLocalNotificationNow:locaNotif];

    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSDictionary *dic = [aps objectForKey:@"alert"];
    NSString *type = [dic objectForKey:@"loc-key"];
    
    if ([type isEqualToString:@"PUSHCALLING"]) {
        if (application.applicationState == UIApplicationStateActive) {
            [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
            handler(UIBackgroundFetchResultNewData);
            return;
        }
        else{
            if (!didLaunch) {
                [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
                handler(UIBackgroundFetchResultNewData);
                return;
            }
        }
    }
    
    if ([type isEqualToString:@"MISSEDCALL"] || [type isEqualToString:@"APPOINTMENT"]) {
        [[HistoryTransUtils sharedInstance] getHistoryInBackground:NO];
        handler(UIBackgroundFetchResultNewData);
    }
    else{
        handler(UIBackgroundFetchResultNoData);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // when app is runing in forground, this method is called. TODO:copy the above method to this method for ios6
    if (application.applicationState == UIApplicationStateActive) {
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        NSDictionary *dic = [aps objectForKey:@"alert"];
        NSString *type = [dic objectForKey:@"loc-key"];
        if ([type isEqualToString:@"PUSHCALLING"]) {
            [[SipStackUtils sharedInstance] queryConfigurationAndRegister];
        }
    }
}

#pragma mark -- UILocalNotification --
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //add code
}

- (id)getAppDelegateAudioVC
{
    return _audioCallViewController;
}

- (void)setTabItemBadge:(NSInteger)number
{
    UITabBarItem *histItem = [_tabController.tabBar.items objectAtIndex:0];
    if (number == 0) {
        histItem.badgeValue = nil;
    }
    else{
        histItem.badgeValue = [NSString stringWithFormat:@"%d", number];
    }
}

- (NSInteger)getTabItemBadge
{
    UITabBarItem *histItem = [_tabController.tabBar.items objectAtIndex:0];
    return  [histItem.badgeValue integerValue];
}

- (void)displayNoPushNotificationWarning
{
    if ([UIApplication sharedApplication].enabledRemoteNotificationTypes == UIRemoteNotificationTypeNone) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertNotificationTitle", nil) message:NSLocalizedString(@"alertNotificationBody", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alertNotificationButton", nil) otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)displayNoRecordingWarning
{
    if (IS_OS_7_OR_LATER) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (!granted) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertRecordingTitle", nil) message:NSLocalizedString(@"alertRecordingBody", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"alertNotificationButton", nil) otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
}

# pragma mark -- Umeng
- (void)umCheck:(NSNotification *)notification
{
    if (notification.userInfo) {
        NSArray *newReplies = [notification.userInfo objectForKey:@"newReplies"];
        int RepliesNumber = [newReplies count];
        // 在设置界面显示反馈的数目
        [_settingViewController newReplies:RepliesNumber];
    }
}

@end
