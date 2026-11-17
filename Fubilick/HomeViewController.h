//
//  HomeViewController.h
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerViewController;

@interface HomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *videoList;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UILabel *errorLabel;

- (void)loadVideos;
- (void)showPlayerWithBVID:(NSString *)bvid title:(NSString *)title;

@end