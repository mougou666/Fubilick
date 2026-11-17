//
//  VideoCell.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "VideoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation VideoCell

@synthesize thumbnailView = _thumbnailView;
@synthesize titleLabel = _titleLabel;
@synthesize ownerLabel = _ownerLabel;
@synthesize viewLabel = _viewLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 120, 80)];
        self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailView.clipsToBounds = YES;
        self.thumbnailView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.thumbnailView.layer.cornerRadius = 4;
        self.thumbnailView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.thumbnailView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 8, self.contentView.bounds.size.width - 155, 42)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleLabel];
        
        // UP主标签 —— 使用黑色（系统默认）
        self.ownerLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 55, 150, 18)];
        self.ownerLabel.font = [UIFont systemFontOfSize:12];
        self.ownerLabel.textColor = [UIColor blackColor];  // 改为黑色
        self.ownerLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.ownerLabel];
        
        self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 73, 150, 16)];
        self.viewLabel.font = [UIFont systemFontOfSize:11];
        self.viewLabel.textColor = [UIColor grayColor];
        self.viewLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.viewLabel];
        
        self.selectedBackgroundView = [[[UIView alloc] init] autorelease];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title pic:(NSString *)picUrl owner:(NSString *)owner view:(NSString *)viewCount {
    self.titleLabel.text = title ?: @"";
    CGSize maxSize = CGSizeMake(self.contentView.bounds.size.width - 155, 42);
    CGSize size = [title sizeWithFont:self.titleLabel.font
                    constrainedToSize:maxSize
                        lineBreakMode:UILineBreakModeWordWrap];
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.size.height = size.height;
    self.titleLabel.frame = titleFrame;
    
    self.ownerLabel.text = [NSString stringWithFormat:@"UP主: %@", owner ?: @"未知"];
    CGRect ownerFrame = self.ownerLabel.frame;
    ownerFrame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 4;
    self.ownerLabel.frame = ownerFrame;
    
    self.viewLabel.text = [NSString stringWithFormat:@"播放: %@", viewCount ?: @"0"];
    CGRect viewFrame = self.viewLabel.frame;
    viewFrame.origin.y = self.ownerLabel.frame.origin.y + self.ownerLabel.frame.size.height + 2;
    self.viewLabel.frame = viewFrame;
    
    [self loadImageFromURL:picUrl];
}

- (void)loadImageFromURL:(NSString *)urlString {
    self.thumbnailView.image = nil;
    self.thumbnailView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
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
                                       self.thumbnailView.image = image;
                                       self.thumbnailView.backgroundColor = [UIColor clearColor];
                                   }
                               }
                           }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.size.width = self.contentView.bounds.size.width - 155;
    self.titleLabel.frame = titleFrame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.thumbnailView.image = nil;
    self.thumbnailView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.titleLabel.text = @"";
    self.ownerLabel.text = @"";
    self.viewLabel.text = @"";
}

- (void)dealloc {
    [_thumbnailView release];
    [_titleLabel release];
    [_ownerLabel release];
    [_viewLabel release];
    [super dealloc];
}

@end