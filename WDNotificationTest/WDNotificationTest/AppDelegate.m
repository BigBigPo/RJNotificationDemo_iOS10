//
//  AppDelegate.m
//  RJNotificationTest
//
//  Created by Po on 2017/12/11.
//  Copyright © 2017年 Po. All rights reserved.

#import "AppDelegate.h"
#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
@interface AppDelegate ()<JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
//    if (@available(iOS 10.0, *)) {
//    }
    
    UNNotificationAction * likeAction;              //喜欢
    UNNotificationAction * ingnoreAction;           //取消
    UNNotificationAction * emojiAction;             //自定义表情
    UNTextInputNotificationAction * inputAction;    //文本输入
    
    likeAction = [UNNotificationAction actionWithIdentifier:@"action_like"
                                                      title:@"点赞"
                                                    options:UNNotificationActionOptionForeground];

    inputAction = [UNTextInputNotificationAction actionWithIdentifier:@"action_input"
                                                                title:@"评论"
                                                              options:UNNotificationActionOptionForeground
                                                 textInputButtonTitle:@"发送"
                                                 textInputPlaceholder:@"说点什么"];
    
    emojiAction = [UNNotificationAction actionWithIdentifier:@"action_emoji"
                                                       title:@"表情"
                                                     options:UNNotificationActionOptionForeground];
    
    ingnoreAction = [UNNotificationAction actionWithIdentifier:@"action_cancel"
                                                         title:@"忽略"
                                                       options:UNNotificationActionOptionForeground];
    
    //下面的Identifier 需与 NotificationContent的info.plist 文件中所配置的 UNNotificationExtensionCategory 一致，
    //本示例中为“myNotificationCategory”
    UNNotificationCategory * category;
    category = [UNNotificationCategory categoryWithIdentifier:@"myNotificationCategory"
                                                      actions:@[likeAction, inputAction, ingnoreAction]
                                            intentIdentifiers:@[]
                                                      options:UNNotificationCategoryOptionNone];
    
    NSSet * sets = [NSSet setWithObjects:category, nil];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:sets];
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    [JPUSHService setupWithOption:launchOptions appKey:@"XXX"
                          channel:@"test"
                 apsForProduction:NO
            advertisingIdentifier:nil];

    return YES;
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - JPUSH
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

//// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}
@end
