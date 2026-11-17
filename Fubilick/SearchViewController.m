//
//  SearchViewController.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "SearchViewController.h"
#import "PlayerViewController.h"
#import "VideoCell.h"
#import "JSONKit.h"

@implementation SearchViewController

@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize searchResults = _searchResults;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize placeholderLabel = _placeholderLabel;
@synthesize errorLabel = _errorLabel;

- (id)init {
    self = [super init];
    if (self) {
        self.searchResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 搜索栏
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"搜索视频";
    self.searchBar.barStyle = UIBarStyleDefault;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    // 使用系统默认 tintColor（不自定义）
    self.searchBar.showsCancelButton = YES;
    [self.view addSubview:self.searchBar];
    
    // 表格视图
    CGRect tableFrame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44);
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 110;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
    // 占位标签
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, self.view.bounds.size.width - 40, 60)];
    self.placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.placeholderLabel.textAlignment = UITextAlignmentCenter;
    self.placeholderLabel.textColor = [UIColor grayColor];
    self.placeholderLabel.font = [UIFont systemFontOfSize:16];
    self.placeholderLabel.text = @"输入关键词搜索视频";
    self.placeholderLabel.numberOfLines = 0;
    [self.view addSubview:self.placeholderLabel];
    
    // 加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.center = self.view.center;
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    
    // 错误标签
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, self.view.bounds.size.width - 40, 60)];
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.errorLabel.textAlignment = UITextAlignmentCenter;
    self.errorLabel.textColor = [UIColor redColor];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.hidden = YES;
    [self.view addSubview:self.errorLabel];
}

#pragma mark - 导航栏隐藏（搜索页不显示导航栏）
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏搜索页的导航栏
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    // 取消表格选中状态
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 恢复导航栏，以便播放页显示返回按钮
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - 搜索方法
- (void)searchVideosWithKeyword:(NSString *)keyword {
    if (keyword == nil || [keyword length] == 0) return;
    
    [self.loadingIndicator startAnimating];
    self.errorLabel.hidden = YES;
    self.placeholderLabel.hidden = YES;
    self.tableView.hidden = YES;
    [self.searchResults removeAllObjects];
    
    // 使用新的搜索 API
    NSString *encodedKeyword = [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://7891vip.top/search.php?msg=%@", encodedKeyword];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self.loadingIndicator stopAnimating];
                               
                               if (error) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"搜索失败: %@", error.localizedDescription];
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               if (data == nil) {
                                   self.errorLabel.text = @"搜索失败: 没有数据";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               JSONDecoder *decoder = [JSONDecoder decoder];
                               NSError *parseError = nil;
                               NSDictionary *jsonDict = [decoder objectWithData:data error:&parseError];
                               if (parseError || jsonDict == nil) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"解析失败: %@", parseError.localizedDescription];
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               NSNumber *codeNum = [jsonDict objectForKey:@"Code"];
                               if ([codeNum intValue] != 0) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"搜索错误: code=%@", codeNum];
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               NSArray *items = [jsonDict objectForKey:@"data"];
                               if (items == nil || ![items isKindOfClass:[NSArray class]]) {
                                   self.errorLabel.text = @"搜索失败: 没有结果";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               for (NSDictionary *item in items) {
                                   if (![item isKindOfClass:[NSDictionary class]]) continue;
                                   NSString *bvid = [item objectForKey:@"bvid"];
                                   NSString *title = [item objectForKey:@"title"];
                                   NSString *cover = [item objectForKey:@"cover"];
                                   NSString *author = [item objectForKey:@"author"];
                                   NSString *viewCount = [item objectForKey:@"view_count"];
                                   NSString *duration = [item objectForKey:@"duration"];
                                   
                                   NSMutableDictionary *video = [NSMutableDictionary dictionary];
                                   [video setObject:bvid ?: @"" forKey:@"bvid"];
                                   [video setObject:title ?: @"" forKey:@"title"];
                                   [video setObject:cover ?: @"" forKey:@"pic"];
                                   [video setObject:author ?: @"" forKey:@"owner"];
                                   [video setObject:viewCount ?: @"" forKey:@"view"];
                                   [video setObject:duration ?: @"0" forKey:@"duration"];
                                   [self.searchResults addObject:video];
                               }
                               
                               if ([self.searchResults count] > 0) {
                                   self.tableView.hidden = NO;
                                   [self.tableView reloadData];
                               } else {
                                   self.errorLabel.text = @"没有找到相关视频";
                                   self.errorLabel.hidden = NO;
                               }
                           }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    NSString *keyword = searchBar.text;
    if (keyword && [keyword length] > 0) [self searchVideosWithKeyword:keyword];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [self.searchResults removeAllObjects];
    self.tableView.hidden = YES;
    self.placeholderLabel.hidden = NO;
    self.errorLabel.hidden = YES;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] == 0) {
        [self.searchResults removeAllObjects];
        self.tableView.hidden = YES;
        self.placeholderLabel.hidden = NO;
        self.errorLabel.hidden = YES;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SearchVideoCell";
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[VideoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    NSDictionary *video = [self.searchResults objectAtIndex:indexPath.row];
    [cell configureWithTitle:[video objectForKey:@"title"]
                         pic:[video objectForKey:@"pic"]
                       owner:[video objectForKey:@"owner"]
                        view:[video objectForKey:@"view"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *video = [self.searchResults objectAtIndex:indexPath.row];
    NSString *bvid = [video objectForKey:@"bvid"];
    NSString *title = [video objectForKey:@"title"];
    if (bvid && [bvid length] > 0) {
        [self showPlayerWithBVID:bvid title:title];
    }
}

- (void)showPlayerWithBVID:(NSString *)bvid title:(NSString *)title {
    PlayerViewController *playerVC = [[PlayerViewController alloc] init];
    playerVC.bvid = bvid;
    playerVC.videoTitle = title;
    [self.navigationController pushViewController:playerVC animated:YES];
    [playerVC release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_searchBar release];
    [_tableView release];
    [_searchResults release];
    [_loadingIndicator release];
    [_placeholderLabel release];
    [_errorLabel release];
    [super dealloc];
}

@end