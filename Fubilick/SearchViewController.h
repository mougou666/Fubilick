//
//  SearchViewController.h
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerViewController;

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UILabel *placeholderLabel;
@property (nonatomic, retain) UILabel *errorLabel;

- (void)searchVideosWithKeyword:(NSString *)keyword;
- (void)showPlayerWithBVID:(NSString *)bvid title:(NSString *)title;

@end