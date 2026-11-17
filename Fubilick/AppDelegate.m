//
//  AppDelegate.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "SearchViewController.h"
#import "UserCenterViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize homeNavController = _homeNavController;
@synthesize searchNavController = _searchNavController;
@synthesize userNavController = _userNavController;
@synthesize homeViewController = _homeViewController;
@synthesize searchViewController = _searchViewController;
@synthesize userViewController = _userViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // 主页
    self.homeViewController = [[HomeViewController alloc] init];
    self.homeViewController.title = @"Fubilick(Demo)";
    self.homeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"主页"
                                                                       image:nil
                                                                         tag:0];
    self.homeNavController = [[UINavigationController alloc] initWithRootViewController:self.homeViewController];
    
    // 搜索页
    self.searchViewController = [[SearchViewController alloc] init];
    // 修正：UITabItem → UITabBarItem
    self.searchViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"搜索"
                                                                         image:nil
                                                                           tag:1];
    self.searchNavController = [[UINavigationController alloc] initWithRootViewController:self.searchViewController];
    
    // 个人中心
    self.userViewController = [[UserCenterViewController alloc] init];
    self.userViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"个人中心"
                                                                       image:nil
                                                                         tag:2];
    self.userNavController = [[UINavigationController alloc] initWithRootViewController:self.userViewController];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                             self.homeNavController,
                                             self.searchNavController,
                                             self.userNavController,
                                             nil];
    self.tabBarController.delegate = self;
    // 标签栏使用系统默认颜色
    
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

- (void)dealloc {
    [_window release];
    [_tabBarController release];
    [_homeNavController release];
    [_searchNavController release];
    [_userNavController release];
    [_homeViewController release];
    [_searchViewController release];
    [_userViewController release];
    [super dealloc];
}

@end