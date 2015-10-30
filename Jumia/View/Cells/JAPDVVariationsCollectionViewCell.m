//
//  JAPDVVariationsCollectionViewCell.m
//  Jumia
//
//  Created by claudiosobrinho on 21/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVVariationsCollectionViewCell.h"
#import "RIProduct.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"
#import "JARatingsView.h"

@interface JAPDVVariationsCollectionViewCell()

@property (nonatomic, strong) UIView* contentView;

@end

@implementation JAPDVVariationsCollectionViewCell

@synthesize bottomHorizontalSeparator = _bottomHorizontalSeparator, topHorizontalSeparator = _topHorizontalSeparator, rightVerticalSeparator = _rightVerticalSeparator, contentView = _contentView;

- (void)initViews
{
    [super initViews];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(32.0f, 0, self.frame.size.width - 64.0f, self.frame.size.height)];

    } else {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(12.0f, 0, self.frame.size.width - 24.0f , self.frame.size.height)];
    }
    
    [_contentView addSubview:self.productImageView];
    
    [_contentView addSubview:self.brandLabel];
    
    [_contentView addSubview:self.nameLabel];
    
    [_contentView addSubview:self.recentProductImageView];
    
    [_contentView addSubview:self.sizeButton];
    
    [_contentView addSubview:self.feedbackView];
    
    [_contentView addSubview:self.priceView];
    
    [self addSubview:_contentView];
    
    [self.layer setCornerRadius:0.f];
    
    _bottomHorizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 1, self.frame.size.width, 1)];
    [_bottomHorizontalSeparator setBackgroundColor:[UIColor colorWithRed:0.867 green:0.878 blue:0.878 alpha:1]];
    [self addSubview:_bottomHorizontalSeparator];
    
    _topHorizontalSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    [_topHorizontalSeparator setBackgroundColor:[UIColor colorWithRed:0.867 green:0.878 blue:0.878 alpha:1]];
    [self addSubview:_topHorizontalSeparator];
    
    _rightVerticalSeparator = [[UIView alloc] initWithFrame:CGRectMake(self.width - 1, 0, 1, self.frame.size.height)];
    [_rightVerticalSeparator setBackgroundColor:[UIColor colorWithRed:0.867 green:0.878 blue:0.878 alpha:1]];
    [self addSubview:_rightVerticalSeparator];

}

- (void)reloadViews
{
    [super reloadViews];
    
    [self displayNameInMultipleLines];
    
    self.nameLabel.width -= 64;
    [self.discountLabel setX:self.frame.size.width - (32 + self.discountLabel.width)];
    [self.favoriteButton setX:self.frame.size.width - (42 + self.favoriteButton.width)];
    
    [_bottomHorizontalSeparator setWidth:self.frame.size.width];
    [_topHorizontalSeparator setWidth:self.frame.size.width];
    [_rightVerticalSeparator setX:self.frame.size.width - 1];
    [_rightVerticalSeparator setHeight:self.frame.size.height];
}

- (void)displayNameInMultipleLines{
    
    [self.nameLabel setNumberOfLines:2];
    [self.nameLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
    
    if ([self lineCountForLabel:self.nameLabel] > 1) {
        [self.nameLabel sizeToFit];

        self.priceView.y += 15.0f;
    }
}

- (int)lineCountForLabel:(UILabel *)label
{
    CGFloat labelWidth = label.frame.size.width;
    int lineCount = 0;
    CGSize textSize = CGSizeMake(labelWidth, MAXFLOAT);
    long rHeight = lroundf([label sizeThatFits:textSize].height);
    long charSize = lroundf(label.font.leading);
    lineCount = (int)( rHeight / charSize );
    return lineCount;
}

@end