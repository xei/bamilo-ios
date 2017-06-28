//
//  JAGenericMenuCell.m
//  Jumia
//
//  Created by Telmo Pinto on 23/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAGenericMenuCell.h"
#import "UIImageView+WebCache.h"

#define kLeftIPadMargin 24.f
#define kCellLevelOneMargin 52.f
#define kCellLevelOneIPadMargin 60.f
#define kHeaderHeight 0.f
#define kCellHeight 40.f
#define kIconImageWidthAndHeight 16.f
#define kIconImageRightMargin 10.f
#define kAcessoryImageWidthAndHeight 11.f
#define kLeftAndRightMargin 16.f
#define kSeparatorHeight 1.f

#define kCellLevelTwoMargin 80.f
#define kCellLevelTwoIPadMargin 88.f

@interface JAGenericMenuCell()

@property (nonatomic, strong) UILabel* mainLabel;
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UIView* separatorView;

@end

@implementation JAGenericMenuCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
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
        [self.separatorView setBackgroundColor:[Theme color:kColorExtraExtraLightGray]];
        [self.backgroundClickableView addSubview:self.separatorView];
    }
    return self;
}

- (void)setupWithStyle:(JAGenericMenuCellStyle)style width:(CGFloat)width cellText:(NSString*)cellText iconImageURL:(NSString*)iconImageUrl accessoryImageName:(NSString*)accessoryImageName hasSeparator:(BOOL)hasSeparator {
    
    //SETUP DEFAULT VARIABLES
    CGFloat height = [JAGenericMenuCell heightForStyle:style];
    UIColor* backgroundColor = [UIColor whiteColor];
    BOOL clickableViewIsEnabled = YES;
    CGFloat textTopOffset = 0.0f;
    CGFloat leftMargin = kLeftAndRightMargin;
    CGFloat rightMargin = kLeftAndRightMargin;
    UIFont* font = [Theme font:kFontVariationRegular size:12];
    UIColor* textColor = [Theme color:kColorExtraDarkGray];
    NSString* text = cellText;
    
    CGFloat accessoryImageWidth = kAcessoryImageWidthAndHeight;
    CGFloat accessoryImageMargin = kLeftAndRightMargin;
    if (VALID_NOTEMPTY(accessoryImageName, NSString)) {
        [self.accessoryImageView setImage:[UIImage imageNamed:accessoryImageName]];
    }
    
    CGFloat iconImageWidth = 0.0f;
    CGFloat iconImageRightMargin = 0.0f;
    if (VALID_NOTEMPTY(iconImageUrl, NSString)) {
        iconImageWidth = kIconImageWidthAndHeight;
        iconImageRightMargin = kIconImageRightMargin;
        
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:iconImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    }
    
    CGFloat separatorHeight = 0.0f;
    if (hasSeparator) {
        separatorHeight = kSeparatorHeight;
    }
    
    //CHANGE VARIABLES ACCORDING TO STYLE
    if (JAGenericMenuCellStyleHeader == style) {
        backgroundColor = JABlack300Color;
        clickableViewIsEnabled = NO;
        textTopOffset = 2.0f;
        
        text = [cellText uppercaseString];
        font = JAHEADLINEFont;
        
        accessoryImageWidth = accessoryImageMargin = iconImageWidth = iconImageRightMargin = separatorHeight = 0.0f;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            leftMargin = kLeftIPadMargin;
        }
    } else if (style == JAGenericMenuCellStyleLevelOne) {
        leftMargin = kCellLevelOneMargin;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            leftMargin = kCellLevelOneIPadMargin;
        }
    } else if(style == JAGenericMenuCellStyleLevelTwo) {
        leftMargin = kCellLevelTwoMargin;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            leftMargin = kCellLevelTwoIPadMargin;
        }
    }
    
    //SET VIEWS USING VARIABLES
    self.backgroundClickableView.backgroundColor = backgroundColor;
    [self.backgroundClickableView setFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, width, height)];
    self.backgroundClickableView.enabled = clickableViewIsEnabled;
    
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.iconImageView setFrame:CGRectMake(leftMargin, (height - iconImageWidth)/2, iconImageWidth, iconImageWidth)];
    
    [self.mainLabel setFrame:CGRectMake(leftMargin + iconImageWidth + iconImageRightMargin, self.backgroundClickableView.bounds.origin.y + textTopOffset, self.backgroundClickableView.bounds.size.width - leftMargin - accessoryImageWidth - accessoryImageMargin - iconImageWidth - iconImageRightMargin - rightMargin, height)];
    
    [self.mainLabel setText:text];
    [self.mainLabel setFont:font];
    [self.mainLabel setTextColor:textColor];
    [self.mainLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self.accessoryImageView setFrame:CGRectMake(self.backgroundClickableView.bounds.size.width - accessoryImageWidth - rightMargin, (height - accessoryImageWidth)/2, accessoryImageWidth, accessoryImageWidth)]; //image is square so width=height
    
    CGFloat leftSepratorViewMargin = (style == JAGenericMenuCellStyleLevelTwo || iconImageWidth == 0) ? leftMargin : leftMargin + 28;
    [self.separatorView setFrame:CGRectMake(leftSepratorViewMargin, height-separatorHeight, self.backgroundClickableView.bounds.size.width - leftMargin, separatorHeight)];
    
    if (RI_IS_RTL) {
        [self.backgroundClickableView flipAllSubviews];
        [self.accessoryImageView flipViewImage];
    }
}

+ (CGFloat)heightForStyle:(JAGenericMenuCellStyle)style {
    CGFloat height = kCellHeight;
    if (JAGenericMenuCellStyleHeader == style) {
        height = kHeaderHeight;
    }
    return height;
}

- (void)clickableViewWasPressed {
//VIRTUAL, SHOULD BE IMPLEMENTED IN THE SUBCLASSES
}

@end
