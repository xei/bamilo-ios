//
//  JAChooseCountryTableViewCell.m
//  Jumia
//
//  Created by Jose Mota on 24/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAChooseCountryTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"

@interface JAChooseCountryTableViewCell ()

@property (strong, nonatomic) UIImageView *countryImage;
@property (strong, nonatomic) UILabel *countryName;
@property (strong, nonatomic) UIImageView *checkImage;
@property (strong, nonatomic) UIView *separatorView;

@end

@implementation JAChooseCountryTableViewCell

- (UIImageView *)countryImage
{
    if (!VALID(_countryImage, UIImageView)) {
        _countryImage = [UIImageView new];
        CGSize countryImageSize = CGSizeMake(25, 25);
        [_countryImage setFrame:CGRectMake(16, (kCountryCellHeight - countryImageSize.height)/2, countryImageSize.width, countryImageSize.height)];
        _countryImage.layer.cornerRadius = _countryImage.frame.size.height /2;
        _countryImage.contentMode = UIViewContentModeScaleAspectFill;
        _countryImage.layer.masksToBounds = YES;
        _countryImage.layer.borderWidth = 0;
        [self addSubview:_countryImage];
    }
    return _countryImage;
}

- (UILabel *)countryName
{
    if (!VALID(_countryName, UILabel)) {
        _countryName = [[UILabel alloc] init];
        CGPoint countryNamePoint = CGPointMake(CGRectGetMaxX(self.countryImage.frame) + 10.f, 0);
        CGSize countryNameSize = CGSizeMake(self.checkImage.x - countryNamePoint.x, kCountryCellHeight);
        [_countryName setFrame:CGRectMake(countryNamePoint.x, countryNamePoint.y, countryNameSize.width, countryNameSize.height)];
        [_countryName setFont:JAListFont];
        [_countryName setTextColor:JABlackColor];
        [self addSubview:_countryName];
    }
    return _countryName;
}

- (UIImageView *)checkImage
{
    if (!VALID(_checkImage, UIImageView)) {
        _checkImage = [UIImageView new];
        [_checkImage setImage:[UIImage imageNamed:@"selectionCheckmark"]];
        CGSize checkImageSize = CGSizeMake(18, 14);
        [_checkImage setFrame:CGRectMake(self.width - checkImageSize.width - 16.f, (kCountryCellHeight - checkImageSize.height)/2, checkImageSize.width, checkImageSize.height)];
        [_checkImage setHidden:YES];
        [self addSubview:_checkImage];
    }
    return _checkImage;
}

- (UIView *)separatorView
{
    if (!VALID(_separatorView, UIView)) {
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(16.f, self.height/2, self.width-16.f, 1.f)];
        [_separatorView setBackgroundColor:JABlack400Color];
        [self addSubview:_separatorView];
    }
    return _separatorView;
}

- (void)setCountry:(RICountry *)country
{
    self.countryName.text = country.name;
    [self.countryImage sd_setImageWithURL:[NSURL URLWithString:country.flag]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:NO animated:animated];
}

- (void)setSelectedCountry:(BOOL)selectedCountry
{
    self.checkImage.hidden = !selectedCountry;
}

- (void)layoutSubviews
{
    [self.countryImage setX:16];
    [self.countryName setX:CGRectGetMaxX(self.countryImage.frame) + 10.f];
    [self.checkImage setX:self.width - self.checkImage.width - 16.f];
    [self.countryName setWidth:self.checkImage.x - self.countryName.x];
    [self.countryName setTextAlignment:NSTextAlignmentLeft];
    [self.separatorView setFrame:CGRectMake(16.f, self.height-1, self.width-16.f, 1.f)];
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
    [super layoutSubviews];
}

@end
