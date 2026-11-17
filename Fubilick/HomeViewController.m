//
//  HomeViewController.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "HomeViewController.h"
#import "PlayerViewController.h"
#import "VideoCell.h"
#import "JSONKit.h"

@implementation HomeViewController

@synthesize tableView = _tableView;
@synthesize videoList = _videoList;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize errorLabel = _errorLabel;

- (id)init {
    self = [super init];
    if (self) {
        self.videoList = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建表格视图
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 110;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    // separatorInset 已移除（iOS 4 不支持）
    [self.view addSubview:self.tableView];
    
    // 创建加载指示器
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.center = self.view.center;
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingIndicator];
    
    // 创建错误标签
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 60)];
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.errorLabel.textAlignment = UITextAlignmentCenter;
    self.errorLabel.textColor = [UIColor grayColor];
    self.errorLabel.font = [UIFont systemFontOfSize:16];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.hidden = YES;
    [self.view addSubview:self.errorLabel];
    
    // 加载数据
    [self loadVideos];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)loadVideos {
    [self.loadingIndicator startAnimating];
    self.errorLabel.hidden = YES;
    self.tableView.hidden = YES;
    
    NSString *urlString = @"https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               [self.loadingIndicator stopAnimating];
                               
                               if (error) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"加载失败: %@", error.localizedDescription];
                                   self.errorLabel.hidden = NO;
                                   self.tableView.hidden = NO;
                                   return;
                               }
                               
                               if (data == nil) {
                                   self.errorLabel.text = @"加载失败: 没有数据";
                                   self.errorLabel.hidden = NO;
                                   self.tableView.hidden = NO;
                                   return;
                               }
                               
                               JSONDecoder *decoder = [JSONDecoder decoder];
                               NSError *parseError = nil;
                               NSDictionary *jsonDict = [decoder objectWithData:data error:&parseError];
                               
                               if (parseError || jsonDict == nil) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"解析失败: %@", parseError.localizedDescription];
                                   self.errorLabel.hidden = NO;
                                   self.tableView.hidden = NO;
                                   return;
                               }
                               
                               NSNumber *codeNum = [jsonDict objectForKey:@"code"];
                               if ([codeNum intValue] != 0) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"API错误: code=%@", codeNum];
                                   self.errorLabel.hidden = NO;
                                   self.tableView.hidden = NO;
                                   return;
                               }
                               
                               NSDictionary *dataDict = [jsonDict objectForKey:@"data"];
                               if (dataDict == nil || ![dataDict isKindOfClass:[NSDictionary class]]) {
                                   self.errorLabel.text = @"加载失败: 数据为空";
                                   self.errorLabel.hidden = NO;
                                   self.tableView.hidden = NO;
                                   return;
                               }
                               
                               NSArray *items = [dataDict objectForKey:@"item"];
                               if (items == nil || ![items isKindOfClass:[NSArray class]]) {
                                   self.errorLabel.text = @"加载失败: 没有视频列表";
                                   self.errorLabel.hidden = NO;
                                   self.tableView.hidden = NO;
                                   return;
                               }
                               
                               [self.videoList removeAllObjects];
                               
                               for (NSDictionary *item in items) {
                                   if (![item isKindOfClass:[NSDictionary class]]) continue;
                                   
                                   NSString *bvid = [item objectForKey:@"bvid"];
                                   NSString *title = [item objectForKey:@"title"];
                                   NSString *pic = [item objectForKey:@"pic"];
                                   NSString *duration = [item objectForKey:@"duration"];
                                   
                                   NSDictionary *owner = [item objectForKey:@"owner"];
                                   NSString *ownerName = @"";
                                   if ([owner isKindOfClass:[NSDictionary class]]) {
                                       ownerName = [owner objectForKey:@"name"] ?: @"";
                                   }
                                   
                                   NSDictionary *stat = [item objectForKey:@"stat"];
                                   NSString *viewCount = @"";
                                   if ([stat isKindOfClass:[NSDictionary class]]) {
                                       NSNumber *view = [stat objectForKey:@"view"];
                                       if (view) {
                                           viewCount = [NSString stringWithFormat:@"%@", view];
                                       }
                                   }
                                   
                                   NSMutableDictionary *video = [NSMutableDictionary dictionary];
                                   [video setObject:bvid ?: @"" forKey:@"bvid"];
                                   [video setObject:title ?: @"" forKey:@"title"];
                                   [video setObject:pic ?: @"" forKey:@"pic"];
                                   [video setObject:ownerName forKey:@"owner"];
                                   [video setObject:viewCount forKey:@"view"];
                                   [video setObject:duration ?: @"0" forKey:@"duration"];
                                   
                                   [self.videoList addObject:video];
                               }
                               
                               self.tableView.hidden = NO;
                               [self.tableView reloadData];
                               
                               if ([self.videoList count] == 0) {
                                   self.errorLabel.text = @"暂无视频";
                                   self.errorLabel.hidden = NO;
                               }
                           }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.videoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"VideoCell";
    VideoCell *cell = (VideoCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[VideoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSDictionary *video = [self.videoList objectAtIndex:indexPath.row];
    [cell configureWithTitle:[video objectForKey:@"title"]
                         pic:[video objectForKey:@"pic"]
                       owner:[video objectForKey:@"owner"]
                        view:[video objectForKey:@"view"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *video = [self.videoList objectAtIndex:indexPath.row];
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
    [_tableView release];
    [_videoList release];
    [_loadingIndicator release];
    [_errorLabel release];
    [super dealloc];
}

@end