//
//  AboutViewController.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "AboutViewController.h"
#import "UserCenterViewController.h"

@implementation AboutViewController

@synthesize userCenterVC = _userCenterVC;
@synthesize authorLabel = _authorLabel;
@synthesize contactLabel = _contactLabel;
@synthesize clearButton = _clearButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"关于";
    
    // 作者信息
    self.authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, self.view.bounds.size.width - 40, 24)];
    self.authorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.authorLabel.textAlignment = UITextAlignmentCenter;
    self.authorLabel.font = [UIFont boldSystemFontOfSize:18];
    self.authorLabel.textColor = [UIColor blackColor];
    self.authorLabel.text = @"作者: mougou666";
    [self.view addSubview:self.authorLabel];
    
    // 联系方式
    self.contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, self.view.bounds.size.width - 40, 60)];
    self.contactLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.contactLabel.textAlignment = UITextAlignmentCenter;
    self.contactLabel.font = [UIFont systemFontOfSize:14];
    self.contactLabel.textColor = [UIColor darkGrayColor];
    self.contactLabel.numberOfLines = 0;
    self.contactLabel.text = @"QQ: 1966534021\nMail: sfhdxmcn@163.com";
    [self.view addSubview:self.contactLabel];
    
    // 清除UID按钮
    self.clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.clearButton.frame = CGRectMake(40, 220, self.view.bounds.size.width - 80, 44);
    self.clearButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.clearButton setTitle:@"清除UID" forState:UIControlStateNormal];
    [self.clearButton addTarget:self action:@selector(clearUIDAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearButton];
}

- (void)clearUIDAction {
    // 弹出确认框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认清除"
                                                    message:@"您确定要清除已保存的UID吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
    [alert release];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 确定
        if (self.userCenterVC) {
            [self.userCenterVC clearSavedUID];
            // 返回个人中心
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_userCenterVC release];
    [_authorLabel release];
    [_contactLabel release];
    [_clearButton release];
    [super dealloc];
}

@end