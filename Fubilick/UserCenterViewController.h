//
//  UserCenterViewController.h
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AboutViewController;

@interface UserCenterViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSString *uid;
@property (nonatomic, retain) NSDictionary *userInfo;

// UI 元素
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *contentView;

// 输入界面
@property (nonatomic, retain) UITextField *uidTextField;
@property (nonatomic, retain) UIButton *confirmButton;
@property (nonatomic, retain) UILabel *inputPromptLabel;

// 信息显示界面
@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *levelLabel;
@property (nonatomic, retain) UILabel *signLabel;
@property (nonatomic, retain) UILabel *midLabel;
@property (nonatomic, retain) UILabel *fansLabel;
@property (nonatomic, retain) UILabel *friendLabel;
@property (nonatomic, retain) UIButton *aboutButton;

@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UILabel *errorLabel;

- (void)loadUserInfoWithUID:(NSString *)uid;
- (void)showInfoView;
- (void)showInputView;
- (void)saveUID:(NSString *)uid;
- (NSString *)getSavedUID;
- (void)clearSavedUID;

@end