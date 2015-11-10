//
//  JAGenericMenuCell.m
//  Jumia
//
//  Created by Telmo Pinto on 23/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAGenericMenuCell.h"
#import "UIImageView+WebCache.h"

@interface JAGenericMenuCell()

@property (nonatomic, strong) UILabel* mainLabel;
@property (nonatomic, strong) UIImageView* accessoryImageView;
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UIView* separatorView;

@end

@implementation JAGenericMenuCell

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

- (void)setupWithStyle:(JAGenericMenuCellStyle)style
                 width:(CGFloat)width
              cellText:(NSString*)cellText
          iconImageURL:(NSString*)iconImageUrl
    accessoryImageName:(NSString*)accessoryImageName
          hasSeparator:(BOOL)hasSeparator;
{
    //SETUP DEFAULT VARIABLES
    
    CGFloat height = [JAGenericMenuCell heightForStyle:style];
    UIColor* backgroundColor = [UIColor whiteColor];
    BOOL clickableViewIsEnabled = YES;
    CGFloat textTopOffset = 0.0f;
    CGFloat leftMargin = 16.0f;
    CGFloat rightMargin = 16.0f;
    UIFont* font = [UIFont fontWithName:kFontMediumName size:17.0f];
    UIColor* textColor = [UIColor blackColor];
    NSString* text = cellText;
    CGFloat accessoryImageWidth = 22.0f;
    CGFloat accessoryImageMargin = 16.0f;
    [self.accessoryImageView setImage:[UIImage imageNamed:accessoryImageName]];
    CGFloat iconImageWidth = 0.0f;
    CGFloat iconImageMargin = 0.0f;
    if (VALID_NOTEMPTY(iconImageUrl, NSString)) {
        
        iconImageWidth = 22.0f;
        iconImageMargin = 16.0f;
        
        [self.iconImageView setImageWithURL:[NSURL URLWithString:iconImageUrl]
                           placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    }
    CGFloat separatorHeight = 0.0f;
    if (hasSeparator) {
        separatorHeight = 1.0f;
    }
    
    
    //CHANGE VARIABLES ACCORDING TO STYLE
    
    if (JAGenericMenuCellStyleHeader == style) {
        backgroundColor = UIColorFromRGB(0xf0f0f0);
        clickableViewIsEnabled = NO;
        textTopOffset = 3.0f;
        
        text = [cellText uppercaseString];
        
        accessoryImageWidth = 0.0f;
        accessoryImageMargin = 0.0f;
        
        separatorHeight = 0.0f; //force this to have no separator
    } else if (JAGenericMenuCellStyleLevelOne == style) {
        leftMargin = 32.0f;
        font = [UIFont fontWithName:kFontRegularName size:12.0f];
    }

    
    //SET VIEWS USING VARIABLES
    
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
    [self.mainLabel setText:text];
    [self.mainLabel setFont:font];
    [self.mainLabel setTextColor:textColor];
    [self.mainLabel setTextAlignment:NSTextAlignmentLeft];
    
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

+ (CGFloat)heightForStyle:(JAGenericMenuCellStyle)style
{
    CGFloat height = 0.0f;
    if (JAGenericMenuCellStyleHeader == style) {
        height = 64.0f;
    } else {
        height = 48.0f;
    }
    return height;
}

- (void)clickableViewWasPressed
{
//VIRTUAL, SHOULD BE IMPLEMENTED IN THE SUBCLASSES
}

@end
