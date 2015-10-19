//
//  JACategoriesSideMenuCell.m
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JACategoriesSideMenuCell.h"
#import "RICategory.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

@interface JACategoriesSideMenuCell()

@property (nonatomic, strong) UILabel* mainLabel;
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UIView* separatorView;

@end

@implementation JACategoriesSideMenuCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundClickableView = [[JAClickableView alloc] init];
        [self.backgroundClickableView addTarget:self action:@selector(clickableViewWasPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backgroundClickableView];
        
        self.mainLabel = [UILabel new];
        [self.backgroundClickableView addSubview:self.mainLabel];
        
        self.accessoryImageView = [UIImageView new];
        self.accessoryImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.backgroundClickableView addSubview:self.accessoryImageView];
        
        self.iconImageView = [UIImageView new];
        [self.backgroundClickableView addSubview:self.iconImageView];
        
        self.separatorView = [UIView new];
        [self.separatorView setBackgroundColor:UIColorFromRGB(0xe2e2e2)];
        [self.backgroundClickableView addSubview:self.separatorView];
    }
    return self;
}

- (void)setupWithCategory:(RICategory*)category hasSeparator:(BOOL)hasSeparator isOpen:(BOOL)isOpen;
{
    self.category = category;
    
    CGFloat height = [JACategoriesSideMenuCell heightForCategory:category];
    CGFloat width = 256.0f;
    UIColor* backgroundColor = UIColorFromRGB(0xf0f0f0);
    BOOL clickableViewIsEnabled = NO;
    CGFloat textTopOffset = 3.0f;
    CGFloat leftMargin = 16.0f;
    CGFloat rightMargin = 16.0f;
    UIFont* font = [UIFont fontWithName:kFontMediumName size:17.0f];
    UIColor* textColor = [UIColor blackColor];
    NSString* cellText = [category.label uppercaseString];
    CGFloat accessoryImageWidth = 0.0f;
    CGFloat accessoryImageMargin = 0.0f;
    CGFloat iconImageWidth = 0.0f;
    CGFloat iconImageMargin = 0.0f;
    CGFloat separatorHeight = 0.0f;
    
    if (VALID_NOTEMPTY(category.level, NSNumber) && 1 == [category.level integerValue]) {
        
        backgroundColor = [UIColor whiteColor];
        clickableViewIsEnabled = YES;
        
        textTopOffset = 0.0f;
        cellText = category.label;
        
        accessoryImageWidth = 22.0f;
        accessoryImageMargin = 16.0f;
        
        if (0 == category.children.count) {
            [self.accessoryImageView setImage:[UIImage imageNamed:@"sideMenuCell_arrow"]];
        } else {
            if (isOpen) {
                [self.accessoryImageView setImage:[UIImage imageNamed:@"sideMenuCell_minus"]];
            } else {
                [self.accessoryImageView setImage:[UIImage imageNamed:@"sideMenuCell_plus"]];
            }
        }
        
        if (VALID_NOTEMPTY(category.imageUrl, NSString)) {
            
            iconImageWidth = 22.0f;
            iconImageMargin = 16.0f;
            
            [self.iconImageView setImageWithURL:[NSURL URLWithString:category.imageUrl]
                               placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
        }
        
        if (hasSeparator) {
            separatorHeight = 1.0f;
        }
    } else if (VALID_NOTEMPTY(category.level, NSNumber) && 2 == [category.level integerValue]) {
        
        clickableViewIsEnabled = YES;
        backgroundColor = [UIColor whiteColor];
        
        textTopOffset = 0.0f;
        leftMargin = 32.0f;
        font = [UIFont fontWithName:kFontRegularName size:12.0f];
        cellText = category.label;
        
        accessoryImageWidth = 22.0f;
        accessoryImageMargin = 16.0f;
        
        [self.accessoryImageView setImage:[UIImage imageNamed:@"sideMenuCell_arrow"]];
        
        if (hasSeparator) {
            separatorHeight = 1.0f;
        }
    }
    
    self.backgroundClickableView.backgroundColor = backgroundColor;
    [self.backgroundClickableView setFrame:CGRectMake(self.bounds.origin.x,
                                                      self.bounds.origin.y,
                                                      width,
                                                      height)];
    self.backgroundClickableView.enabled = clickableViewIsEnabled;
    
    [self.iconImageView setFrame:CGRectMake(leftMargin,
                                            (height - iconImageWidth)/2,//image is square so width=height,
                                            iconImageWidth,
                                            iconImageWidth)];
    
    [self.mainLabel setFrame:CGRectMake(leftMargin + iconImageWidth + iconImageMargin,
                                        self.backgroundClickableView.bounds.origin.y + textTopOffset,
                                        self.backgroundClickableView.bounds.size.width - leftMargin - accessoryImageWidth - accessoryImageMargin - iconImageWidth - iconImageMargin - rightMargin,
                                        height)];
    [self.mainLabel setText:cellText];
    [self.mainLabel setFont:font];
    [self.mainLabel setTextColor:textColor];
    
    [self.accessoryImageView setFrame:CGRectMake(self.backgroundClickableView.bounds.size.width - accessoryImageWidth - rightMargin,
                                                 (height - accessoryImageWidth)/2,//image is square so width=height
                                                 accessoryImageWidth,
                                                 accessoryImageWidth)];
    
    [self.separatorView setFrame:CGRectMake(leftMargin,
                                            height-separatorHeight,
                                            self.backgroundClickableView.bounds.size.width - leftMargin,
                                            separatorHeight)];
    
    if (RI_IS_RTL) {
        [self.backgroundClickableView flipAllSubviews];
        [self.accessoryImageView flipViewImage];
    }
}

+ (CGFloat)heightForCategory:(RICategory*)category
{
    CGFloat height = 0.0f;
    if (0 == [category.level integerValue]) {
        height = 64.0f;
    } else {
        height = 48.0f;
    }
    return height;
}

- (void)clickableViewWasPressed
{
    if (self.delegate && VALID_NOTEMPTY(self.category, RICategory) && [self.delegate respondsToSelector:@selector(categoryWasSelected:)]) {
        [self.delegate categoryWasSelected:self.category];
    }
}

@end
