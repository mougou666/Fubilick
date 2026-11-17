//
//  PlayerViewController.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "PlayerViewController.h"
#import "JSONKit.h"

@interface PlayerViewController ()
- (void)updateContentSize;
- (void)playVideoWithURL:(NSString *)urlString;
@end

@implementation PlayerViewController

@synthesize bvid = _bvid;
@synthesize videoTitle = _videoTitle;
@synthesize playerContainer = _playerContainer;
@synthesize moviePlayer = _moviePlayer;
@synthesize scrollView = _scrollView;
@synthesize contentView = _contentView;
@synthesize titleLabel = _titleLabel;
@synthesize upLabel = _upLabel;
@synthesize descLabel = _descLabel;
@synthesize viewLabel = _viewLabel;
@synthesize likeLabel = _likeLabel;
@synthesize coinLabel = _coinLabel;
@synthesize favoriteLabel = _favoriteLabel;
@synthesize shareLabel = _shareLabel;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize errorLabel = _errorLabel;

- (id)init {
    self = [super init];
    if (self) {
        self.bvid = @"";
        self.videoTitle = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"视频详情";
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 600)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.contentView];
    
    CGFloat playerHeight = 220;
    self.playerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, playerHeight)];
    self.playerContainer.backgroundColor = [UIColor blackColor];
    self.playerContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.playerContainer];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.loadingIndicator.center = CGPointMake(self.view.bounds.size.width / 2, playerHeight / 2);
    self.loadingIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.loadingIndicator.hidesWhenStopped = YES;
    [self.playerContainer addSubview:self.loadingIndicator];
    
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 60)];
    self.errorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.errorLabel.textAlignment = UITextAlignmentCenter;
    self.errorLabel.textColor = [UIColor whiteColor];
    self.errorLabel.font = [UIFont systemFontOfSize:14];
    self.errorLabel.numberOfLines = 0;
    self.errorLabel.hidden = YES;
    [self.playerContainer addSubview:self.errorLabel];
    
    CGFloat yOffset = playerHeight + 15;
    CGFloat labelWidth = self.view.bounds.size.width - 30;
    CGFloat xOffset = 15;
    
    // 标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, labelWidth, 24)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.titleLabel.text = self.videoTitle;
    [self.titleLabel sizeToFit];
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.size.width = labelWidth;
    self.titleLabel.frame = titleFrame;
    [self.contentView addSubview:self.titleLabel];
    
    yOffset += self.titleLabel.frame.size.height + 10;
    
    // UP主 —— 使用系统默认黑色
    self.upLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, labelWidth, 20)];
    self.upLabel.font = [UIFont systemFontOfSize:14];
    self.upLabel.textColor = [UIColor blackColor];
    self.upLabel.text = @"UP主: --";
    [self.contentView addSubview:self.upLabel];
    
    yOffset += 25;
    
    // 播放量
    self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, labelWidth, 18)];
    self.viewLabel.font = [UIFont systemFontOfSize:13];
    self.viewLabel.textColor = [UIColor grayColor];
    self.viewLabel.text = @"播放: --";
    [self.contentView addSubview:self.viewLabel];
    
    yOffset += 22;
    
    // 点赞/投币/收藏/转发
    NSArray *labelTitles = [NSArray arrayWithObjects:@"点赞: --", @"投币: --", @"收藏: --", @"转发: --", nil];
    CGFloat statWidth = (labelWidth - 20) / 4;
    NSMutableArray *statLabels = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(xOffset + i * (statWidth + 5), yOffset, statWidth, 18)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor grayColor];
        label.text = [labelTitles objectAtIndex:i];
        label.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:label];
        [statLabels addObject:label];
        [label release];
    }
    self.likeLabel = [statLabels objectAtIndex:0];
    self.coinLabel = [statLabels objectAtIndex:1];
    self.favoriteLabel = [statLabels objectAtIndex:2];
    self.shareLabel = [statLabels objectAtIndex:3];
    
    yOffset += 25;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, labelWidth, 1)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [self.contentView addSubview:lineView];
    [lineView release];
    
    yOffset += 10;
    
    UILabel *descTitle = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, 60, 20)];
    descTitle.font = [UIFont boldSystemFontOfSize:14];
    descTitle.textColor = [UIColor blackColor];
    descTitle.text = @"简介:";
    [self.contentView addSubview:descTitle];
    [descTitle release];
    
    yOffset += 22;
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, labelWidth, 50)];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = [UIColor darkGrayColor];
    self.descLabel.numberOfLines = 0;
    self.descLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.descLabel.text = @"加载中...";
    [self.contentView addSubview:self.descLabel];
    
    [self updateContentSize];
    [self loadVideoDetail];
}

#pragma mark - 布局更新
- (void)updateContentSize {
    CGFloat labelWidth = self.view.bounds.size.width - 30;
    CGFloat yOffset = self.descLabel.frame.origin.y;
    if (self.descLabel.text) {
        CGSize maxSize = CGSizeMake(labelWidth, 999);
        CGSize size = [self.descLabel.text sizeWithFont:self.descLabel.font
                                      constrainedToSize:maxSize
                                          lineBreakMode:UILineBreakModeWordWrap];
        CGRect frame = self.descLabel.frame;
        frame.size.height = size.height + 10;
        self.descLabel.frame = frame;
        yOffset += frame.size.height + 20;
    } else {
        yOffset += 60;
    }
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = yOffset + 20;
    self.contentView.frame = contentFrame;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, contentFrame.size.height);
}

#pragma mark - 加载视频详情
- (void)loadVideoDetail {
    if (self.bvid == nil || [self.bvid length] == 0) {
        self.errorLabel.text = @"视频ID无效";
        self.errorLabel.hidden = NO;
        [self.loadingIndicator stopAnimating];
        return;
    }
    [self.loadingIndicator startAnimating];
    self.errorLabel.hidden = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.bilibili.com/x/web-interface/wbi/view?bvid=%@", self.bvid];
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
                                   return;
                               }
                               if (data == nil) {
                                   self.errorLabel.text = @"加载失败: 没有数据";
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
                               NSNumber *codeNum = [jsonDict objectForKey:@"code"];
                               if ([codeNum intValue] != 0) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"API错误: code=%@", codeNum];
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               NSDictionary *dataDict = [jsonDict objectForKey:@"data"];
                               if (dataDict == nil || ![dataDict isKindOfClass:[NSDictionary class]]) {
                                   self.errorLabel.text = @"加载失败: 数据为空";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               NSString *title = [dataDict objectForKey:@"title"] ?: self.videoTitle;
                               NSString *desc = [dataDict objectForKey:@"desc"] ?: @"没有简介";
                               desc = [desc stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                               NSDictionary *owner = [dataDict objectForKey:@"owner"];
                               NSString *ownerName = @"";
                               if ([owner isKindOfClass:[NSDictionary class]]) {
                                   ownerName = [owner objectForKey:@"name"] ?: @"";
                               }
                               NSDictionary *stat = [dataDict objectForKey:@"stat"];
                               NSString *viewCount = @"0", *likeCount = @"0", *coinCount = @"0", *favoriteCount = @"0", *shareCount = @"0";
                               if ([stat isKindOfClass:[NSDictionary class]]) {
                                   NSNumber *view = [stat objectForKey:@"view"];
                                   if (view) viewCount = [NSString stringWithFormat:@"%@", view];
                                   NSNumber *like = [stat objectForKey:@"like"];
                                   if (like) likeCount = [NSString stringWithFormat:@"%@", like];
                                   NSNumber *coin = [stat objectForKey:@"coin"];
                                   if (coin) coinCount = [NSString stringWithFormat:@"%@", coin];
                                   NSNumber *favorite = [stat objectForKey:@"favorite"];
                                   if (favorite) favoriteCount = [NSString stringWithFormat:@"%@", favorite];
                                   NSNumber *share = [stat objectForKey:@"share"];
                                   if (share) shareCount = [NSString stringWithFormat:@"%@", share];
                               }
                               
                               self.titleLabel.text = title;
                               [self.titleLabel sizeToFit];
                               CGRect titleFrame = self.titleLabel.frame;
                               titleFrame.size.width = self.view.bounds.size.width - 30;
                               self.titleLabel.frame = titleFrame;
                               self.upLabel.text = [NSString stringWithFormat:@"UP主: %@", ownerName];
                               self.descLabel.text = desc;
                               self.viewLabel.text = [NSString stringWithFormat:@"播放: %@", viewCount];
                               self.likeLabel.text = [NSString stringWithFormat:@"点赞: %@", likeCount];
                               self.coinLabel.text = [NSString stringWithFormat:@"投币: %@", coinCount];
                               self.favoriteLabel.text = [NSString stringWithFormat:@"收藏: %@", favoriteCount];
                               self.shareLabel.text = [NSString stringWithFormat:@"转发: %@", shareCount];
                               
                               [self updateContentSize];
                               [self playVideo];
                           }];
}

#pragma mark - 播放视频（使用新 JSON 接口）
- (void)playVideo {
    if (self.bvid == nil || [self.bvid length] == 0) return;
    
    // 使用新的 JSON 接口
    NSString *urlString = [NSString stringWithFormat:@"http://7891vip.top/Video.php?bvid=%@", self.bvid];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error || data == nil) {
                                   self.errorLabel.text = @"无法获取视频播放地址";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               // 解析 JSON
                               JSONDecoder *decoder = [JSONDecoder decoder];
                               NSError *parseError = nil;
                               NSDictionary *jsonDict = [decoder objectWithData:data error:&parseError];
                               
                               if (parseError || jsonDict == nil) {
                                   self.errorLabel.text = @"播放地址解析失败";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               // 检查 code
                               NSNumber *codeNum = [jsonDict objectForKey:@"code"];
                               if ([codeNum intValue] != 0) {
                                   self.errorLabel.text = [NSString stringWithFormat:@"接口错误: code=%@", codeNum];
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               // 获取 data 中的 mp4_url
                               NSDictionary *dataDict = [jsonDict objectForKey:@"data"];
                               if (dataDict == nil || ![dataDict isKindOfClass:[NSDictionary class]]) {
                                   self.errorLabel.text = @"播放地址数据为空";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               NSString *mp4URL = [dataDict objectForKey:@"mp4_url"];
                               if (mp4URL == nil || [mp4URL length] == 0) {
                                   self.errorLabel.text = @"未找到 mp4 播放地址";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               // 播放视频
                               [self playVideoWithURL:mp4URL];
                           }];
}

- (void)playVideoWithURL:(NSString *)urlString {
    if (self.moviePlayer) {
        [self.moviePlayer stop];
        [self.moviePlayer.view removeFromSuperview];
        [self.moviePlayer release];
        self.moviePlayer = nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        self.errorLabel.text = @"无效的视频地址";
        self.errorLabel.hidden = NO;
        return;
    }
    
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    self.moviePlayer.view.frame = self.playerContainer.bounds;
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    self.moviePlayer.shouldAutoplay = YES;
    
    [self.playerContainer addSubview:self.moviePlayer.view];
    [self.playerContainer sendSubviewToBack:self.moviePlayer.view];
    [self.moviePlayer play];
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.moviePlayer) [self.moviePlayer stop];
}

- (void)dealloc {
    if (_moviePlayer) {
        [_moviePlayer stop];
        [_moviePlayer release];
        _moviePlayer = nil;
    }
    [_bvid release];
    [_videoTitle release];
    [_playerContainer release];
    [_scrollView release];
    [_contentView release];
    [_titleLabel release];
    [_upLabel release];
    [_descLabel release];
    [_viewLabel release];
    [_likeLabel release];
    [_coinLabel release];
    [_favoriteLabel release];
    [_shareLabel release];
    [_loadingIndicator release];
    [_errorLabel release];
    [super dealloc];
}

@end