//
//  UserCenterViewController.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "UserCenterViewController.h"
#import "AboutViewController.h"
#import "JSONKit.h"
#import <QuartzCore/QuartzCore.h>

@implementation UserCenterViewController

@synthesize uid = _uid;
@synthesize userInfo = _userInfo;
@synthesize scrollView = _scrollView;
@synthesize contentView = _contentView;
@synthesize uidTextField = _uidTextField;
@synthesize confirmButton = _confirmButton;
@synthesize inputPromptLabel = _inputPromptLabel;
@synthesize avatarView = _avatarView;
@synthesize nameLabel = _nameLabel;
@synthesize levelLabel = _levelLabel;
@synthesize signLabel = _signLabel;
@synthesize midLabel = _midLabel;
@synthesize fansLabel = _fansLabel;
@synthesize friendLabel = _friendLabel;
@synthesize aboutButton = _aboutButton;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize errorLabel = _errorLabel;

- (id)init {
    self = [super init];
    if (self) {
        self.uid = @"";
        self.userInfo = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"个人中心";
    
    // 滚动视图
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 600)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.contentView];
    
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
    
    // 检查是否已保存 uid
    NSString *savedUID = [self getSavedUID];
    if (savedUID && [savedUID length] > 0) {
        self.uid = savedUID;
        [self loadUserInfoWithUID:savedUID];
    } else {
        [self showInputView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - 输入界面
- (void)showInputView {
    [self clearContentViews];
    
    self.inputPromptLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width - 40, 40)];
    self.inputPromptLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.inputPromptLabel.textAlignment = UITextAlignmentCenter;
    self.inputPromptLabel.textColor = [UIColor grayColor];
    self.inputPromptLabel.font = [UIFont systemFontOfSize:16];
    self.inputPromptLabel.text = @"请输入您的UID:";
    [self.contentView addSubview:self.inputPromptLabel];
    
    self.uidTextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 130, self.view.bounds.size.width - 80, 40)];
    self.uidTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.uidTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.uidTextField.placeholder = @"UID (数字)";
    self.uidTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.uidTextField.returnKeyType = UIReturnKeyDone;
    self.uidTextField.delegate = self;
    self.uidTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.contentView addSubview:self.uidTextField];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.confirmButton.frame = CGRectMake(80, 190, self.view.bounds.size.width - 160, 44);
    self.confirmButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmUID:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.confirmButton];
    
    [self updateContentSize];
}

- (void)confirmUID:(id)sender {
    NSString *uidText = self.uidTextField.text;
    if (uidText == nil || [uidText length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请输入UID"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    NSScanner *scanner = [NSScanner scannerWithString:uidText];
    long long uidValue;
    if (![scanner scanLongLong:&uidValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"UID必须是数字"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    [self saveUID:uidText];
    self.uid = uidText;
    [self loadUserInfoWithUID:uidText];
}

#pragma mark - 显示个人信息
- (void)showInfoView {
    [self clearContentViews];
    
    if (self.userInfo == nil) {
        [self showInputView];
        return;
    }
    
    // 头像
    self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30, 80, 80)];
    self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = 40;
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.avatarView];
    [self loadAvatarWithURL:[self.userInfo objectForKey:@"face"]];
    
    // 名称
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 30, self.view.bounds.size.width - 140, 24)];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:18];
    self.nameLabel.textColor = [UIColor blackColor];
    self.nameLabel.text = [self.userInfo objectForKey:@"name"] ?: @"未知";
    [self.contentView addSubview:self.nameLabel];
    
    // 等级
    NSDictionary *levelInfo = [self.userInfo objectForKey:@"level_info"];
    NSString *levelText = @"";
    if ([levelInfo isKindOfClass:[NSDictionary class]]) {
        NSNumber *level = [levelInfo objectForKey:@"current_level"];
        if (level) {
            levelText = [NSString stringWithFormat:@"等级: %@", level];
        }
    }
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 60, self.view.bounds.size.width - 140, 20)];
    self.levelLabel.font = [UIFont systemFontOfSize:14];
    self.levelLabel.textColor = [UIColor grayColor];
    self.levelLabel.text = levelText;
    [self.contentView addSubview:self.levelLabel];
    
    // MID
    NSString *mid = [self.userInfo objectForKey:@"mid"] ?: self.uid;
    self.midLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 85, self.view.bounds.size.width - 140, 18)];
    self.midLabel.font = [UIFont systemFontOfSize:12];
    self.midLabel.textColor = [UIColor grayColor];
    self.midLabel.text = [NSString stringWithFormat:@"UID: %@", mid];
    [self.contentView addSubview:self.midLabel];
    
    // 签名
    NSString *sign = [self.userInfo objectForKey:@"sign"] ?: @"这个人很懒，没有签名";
    self.signLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, self.view.bounds.size.width - 40, 40)];
    self.signLabel.font = [UIFont systemFontOfSize:14];
    self.signLabel.textColor = [UIColor darkGrayColor];
    self.signLabel.numberOfLines = 0;
    self.signLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.signLabel.text = sign;
    [self.contentView addSubview:self.signLabel];
    [self.signLabel sizeToFit];
    CGRect signFrame = self.signLabel.frame;
    signFrame.size.width = self.view.bounds.size.width - 40;
    self.signLabel.frame = signFrame;
    
    CGFloat yOffset = self.signLabel.frame.origin.y + self.signLabel.frame.size.height + 20;
    
    // 粉丝 和 关注（两列）
    NSString *fans = [self.userInfo objectForKey:@"fans"] ?: @"0";
    NSString *friend = [self.userInfo objectForKey:@"friend"] ?: @"0";
    CGFloat labelWidth = (self.view.bounds.size.width - 60) / 2;
    
    self.fansLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yOffset, labelWidth, 20)];
    self.fansLabel.font = [UIFont systemFontOfSize:14];
    self.fansLabel.textColor = [UIColor blackColor];
    self.fansLabel.text = [NSString stringWithFormat:@"粉丝: %@", fans];
    [self.contentView addSubview:self.fansLabel];
    
    self.friendLabel = [[UILabel alloc] initWithFrame:CGRectMake(40 + labelWidth, yOffset, labelWidth, 20)];
    self.friendLabel.font = [UIFont systemFontOfSize:14];
    self.friendLabel.textColor = [UIColor blackColor];
    self.friendLabel.text = [NSString stringWithFormat:@"关注: %@", friend];
    [self.contentView addSubview:self.friendLabel];
    
    yOffset += 30;
    
    // 关于按钮
    self.aboutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.aboutButton.frame = CGRectMake(40, yOffset, self.view.bounds.size.width - 80, 44);
    self.aboutButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.aboutButton setTitle:@"关于" forState:UIControlStateNormal];
    [self.aboutButton addTarget:self action:@selector(showAbout) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.aboutButton];
    
    yOffset += 60;
    
    CGRect contentFrame = self.contentView.frame;
    contentFrame.size.height = yOffset + 20;
    self.contentView.frame = contentFrame;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, contentFrame.size.height);
}

- (void)clearContentViews {
    for (UIView *subview in [self.contentView subviews]) {
        [subview removeFromSuperview];
    }
    self.inputPromptLabel = nil;
    self.uidTextField = nil;
    self.confirmButton = nil;
    self.avatarView = nil;
    self.nameLabel = nil;
    self.levelLabel = nil;
    self.signLabel = nil;
    self.midLabel = nil;
    self.fansLabel = nil;
    self.friendLabel = nil;
    self.aboutButton = nil;
}

- (void)updateContentSize {
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 400);
}

#pragma mark - 加载头像
- (void)loadAvatarWithURL:(NSString *)urlString {
    if (urlString == nil || [urlString length] == 0) return;
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) return;
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (data && !error) {
                                   UIImage *image = [UIImage imageWithData:data];
                                   if (image) {
                                       self.avatarView.image = image;
                                       self.avatarView.backgroundColor = [UIColor clearColor];
                                   }
                               }
                           }];
}

#pragma mark - 网络请求获取用户信息
- (void)loadUserInfoWithUID:(NSString *)uid {
    if (uid == nil || [uid length] == 0) return;
    
    [self.loadingIndicator startAnimating];
    self.errorLabel.hidden = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.bilibili.com/x/web-interface/card?mid=%@", uid];
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
                               
                               NSDictionary *card = [dataDict objectForKey:@"card"];
                               if (card == nil || ![card isKindOfClass:[NSDictionary class]]) {
                                   self.errorLabel.text = @"加载失败: 无用户信息";
                                   self.errorLabel.hidden = NO;
                                   return;
                               }
                               
                               self.userInfo = card;
                               [self showInfoView];
                           }];
}

#pragma mark - 存储UID
- (void)saveUID:(NSString *)uid {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:uid forKey:@"user_uid"];
    [defaults synchronize];
}

- (NSString *)getSavedUID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"user_uid"];
}

- (void)clearSavedUID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user_uid"];
    [defaults synchronize];
    self.uid = @"";
    self.userInfo = nil;
    [self showInputView];
}

#pragma mark - 关于页面
- (void)showAbout {
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    aboutVC.userCenterVC = self;
    [self.navigationController pushViewController:aboutVC animated:YES];
    [aboutVC release];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self confirmUID:nil];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_uid release];
    [_userInfo release];
    [_scrollView release];
    [_contentView release];
    [_uidTextField release];
    [_confirmButton release];
    [_inputPromptLabel release];
    [_avatarView release];
    [_nameLabel release];
    [_levelLabel release];
    [_signLabel release];
    [_midLabel release];
    [_fansLabel release];
    [_friendLabel release];
    [_aboutButton release];
    [_loadingIndicator release];
    [_errorLabel release];
    [super dealloc];
}

@end