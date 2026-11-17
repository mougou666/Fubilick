//
//  AboutViewController.h
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserCenterViewController;

@interface AboutViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, retain) UserCenterViewController *userCenterVC;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) UILabel *contactLabel;
@property (nonatomic, retain) UIButton *clearButton;

- (void)clearUIDAction;

@end