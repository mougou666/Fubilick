//
//  PlayerViewController.h
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayerViewController : UIViewController

@property (nonatomic, retain) NSString *bvid;
@property (nonatomic, retain) NSString *videoTitle;

@property (nonatomic, retain) UIView *playerContainer;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *contentView;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *upLabel;
@property (nonatomic, retain) UILabel *descLabel;
@property (nonatomic, retain) UILabel *viewLabel;
@property (nonatomic, retain) UILabel *likeLabel;
@property (nonatomic, retain) UILabel *coinLabel;
@property (nonatomic, retain) UILabel *favoriteLabel;
@property (nonatomic, retain) UILabel *shareLabel;

@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UILabel *errorLabel;

- (void)loadVideoDetail;
- (void)playVideo;

@end