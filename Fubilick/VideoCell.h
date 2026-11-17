//
//  VideoCell.h
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCell : UITableViewCell

@property (nonatomic, retain) UIImageView *thumbnailView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *ownerLabel;
@property (nonatomic, retain) UILabel *viewLabel;

- (void)configureWithTitle:(NSString *)title pic:(NSString *)picUrl owner:(NSString *)owner view:(NSString *)viewCount;
- (void)loadImageFromURL:(NSString *)urlString;

@end