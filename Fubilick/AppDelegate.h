//
//  AppDelegate.h
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeViewController;
@class SearchViewController;
@class UserCenterViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) UINavigationController *homeNavController;
@property (nonatomic, retain) UINavigationController *searchNavController;
@property (nonatomic, retain) UINavigationController *userNavController;
@property (nonatomic, retain) HomeViewController *homeViewController;
@property (nonatomic, retain) SearchViewController *searchViewController;
@property (nonatomic, retain) UserCenterViewController *userViewController;

@end