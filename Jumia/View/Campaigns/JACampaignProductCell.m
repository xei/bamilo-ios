//
//  JACampaignProductCell.m
//  Jumia
//
//  Created by Telmo Pinto on 23/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignProductCell.h"
#import "JAClickableView.h"
#import "JAPriceView.h"
#import "JAPercentageBarView.h"
#import "UIImageView+WebCache.h"
#import "JAProductInfoPriceLine.h"
#import "JAProductInfoSubLine.h"
#import "JABottomBar.h"
#import "UIImage+WithColor.h"

#define kTopMargin 16.f
#define kLateralMargin 16.f

@interface JACampaignProductCell()

@property (nonatomic, assign) NSInteger elapsedTimeInSeconds;

@property (nonatomic, strong) RICampaignProduct *campaignProduct;

@property (nonatomic, strong) UILabel *discountLabel;

@property (nonatomic, strong) UILabel *titleBrandLabel;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *timerView;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *timerLabel;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel *offerEndedLabel;

@property (nonatomic, strong) JAClickableView *imageClickableView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *bottomContentView;

@property (nonatomic, strong) UIView *savingView;
@property (nonatomic, strong) UILabel *savingLabel;
@property (nonatomic, strong) UILabel *savingMoneyLabel;

@property (nonatomic, strong) JAPercentageBarView* percentageBarView;
@property (nonatomic, strong) JABottomBar *bottonBar;
@property (nonatomic, strong) UIButton *buyButton;

@property (nonatomic, strong) UIView *remainingStockView;
@property (nonatomic, strong) UILabel *remainingStockLabel;
@property (nonatomic, strong) UILabel *remainingStockValueLabel;


@property (nonatomic, strong) UIButton* sizeLine;


@property (nonatomic, strong) JAProductInfoPriceLine *priceLine;

@end

@implementation JACampaignProductCell

- (JAClickableView *)imageClickableView
{
    if (!VALID_NOTEMPTY(_imageClickableView, JAClickableView)) {
        _imageClickableView = [[JAClickableView alloc] initWithFrame:self.bounds];
        [_imageClickableView setBackgroundColor:[UIColor clearColor]];
        [_imageClickableView addTarget:self action:@selector(backViewPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageClickableView;
}

- (UILabel *)titleBrandLabel
{
    if (!VALID_NOTEMPTY(_titleBrandLabel, UILabel)) {
        _titleBrandLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.width - 2*kLateralMargin, 15)];
        _titleBrandLabel.font = JACaptionFont;
        _titleBrandLabel.textColor = JABlack800Color;
    }
    return _titleBrandLabel;
}

- (UILabel *)titleLabel
{
    if (!VALID_NOTEMPTY(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.titleBrandLabel.frame) + 10, self.width - 2*16, 15)];
        _titleLabel.font = JABody1Font;
        _titleLabel.textColor = JABlackColor;
    }
    return _titleLabel;
}

- (UILabel *)discountLabel
{
    if (!VALID_NOTEMPTY(_discountLabel, UILabel)) {
        _discountLabel = [[UILabel alloc] init];
        [_discountLabel setFont:JACaptionFont];
        [_discountLabel setTextColor:JAOrange1Color];
        [_discountLabel setTextAlignment:NSTextAlignmentCenter];
        _discountLabel.layer.borderColor = [JAOrange1Color CGColor];
        _discountLabel.layer.borderWidth = 1.0f;
    }
    return _discountLabel;
}

- (UIView *)timerView
{
    if (!VALID_NOTEMPTY(_timerView, UIView)) {
        _timerView = [[UIView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.titleLabel.frame) + 16.f, self.width - 2*kLateralMargin, 15)];
        [_timerView addSubview:self.endLabel];
        [_timerView addSubview:self.timerLabel];
    }
    return _timerView;
}

- (UILabel *)endLabel
{
    if (!VALID_NOTEMPTY(_endLabel, UILabel)) {
        _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.timerView.width, 15)];
        [_endLabel setFont:JABody2Font];
        [_endLabel setText:[STRING_CAMPAIGN_TIMER_END uppercaseString]];
        [_endLabel sizeToFit];
    }
    return _endLabel;
}

- (UILabel *)timerLabel
{
    if (!VALID_NOTEMPTY(_timerLabel, UILabel)) {
        _timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.endLabel.frame) + 2.f, 0, self.timerView.width, 15)];
        [_timerLabel setFont:JABody2Font];
        [_timerLabel setTextColor:[UIColor redColor]];
    }
    return _timerLabel;
}

- (UIImageView *)imageView
{
    if (!VALID_NOTEMPTY(_imageView, UIImageView)) {
        CGFloat width = 176.f;
        CGFloat height = 220.f;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - width)/2, CGRectGetMaxY(self.timerView.frame) + 16.f, width, height)];
    }
    return _imageView;
}

- (UILabel *)offerEndedLabel
{
    if (!VALID_NOTEMPTY(_offerEndedLabel, UILabel)) {
        _offerEndedLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, self.imageView.y + self.imageView.height/2 - 20, self.width - 2*kLateralMargin, 20)];
        [_offerEndedLabel setBackgroundColor:[UIColor whiteColor]];
        [_offerEndedLabel setFont:JABody2Font];
        [_offerEndedLabel setText:[STRING_CAMPAIGN_OFFER_ENDED uppercaseString]];
        [_offerEndedLabel sizeToFit];
        _offerEndedLabel.width += 2*8.f;
        _offerEndedLabel.height += 2*8.f;
        [_offerEndedLabel setTextAlignment:NSTextAlignmentCenter];
        [_offerEndedLabel.layer setBorderWidth:1.f];
        [_offerEndedLabel.layer setBorderColor:JABlack800Color.CGColor];
        [_offerEndedLabel setXCenterAligned];
        [_offerEndedLabel setHidden:YES];
        [self addSubview:_offerEndedLabel];
    }
    return _offerEndedLabel;
}

- (JAProductInfoPriceLine *)priceLine
{
    if (!VALID_NOTEMPTY(_priceLine, JAProductInfoPriceLine)) {
        _priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.imageView.frame) + 10.f, self.width - 2*kLateralMargin, 20.f)];
        [_priceLine setPriceSize:kPriceSizeSmall];
        [_priceLine setLineContentXOffset:0.f];
        [_priceLine.titleLabel setTextColor:[UIColor redColor]];
    }
    return _priceLine;
}

- (UIView *)savingView
{
    if (!VALID_NOTEMPTY(_savingView, UIView)) {
        _savingView = [[UIView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.priceLine.frame) + 10.f, self.width - 2*kLateralMargin, kProductInfoSingleLineHeight)];
        [_savingView addSubview:self.savingLabel];
        [_savingView addSubview:self.savingMoneyLabel];
    }
    return _savingView;
}

- (UILabel *)savingLabel
{
    if (!VALID_NOTEMPTY(_savingLabel, UILabel)) {
        _savingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.savingView.width, kProductInfoSingleLineHeight)];
        [_savingLabel setFont:JACaptionFont];
        [_savingLabel setText:STRING_CAMPAIGN_SAVE];
        [_savingLabel sizeToFit];
    }
    return _savingLabel;
}

- (UILabel *)savingMoneyLabel
{
    if (!VALID_NOTEMPTY(_savingMoneyLabel, UILabel)) {
        _savingMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.savingLabel.frame) + 6.f, self.savingLabel.y, self.savingView.width, kProductInfoSingleLineHeight)];
        [_savingMoneyLabel setFont:JABody2Font];
        [_savingMoneyLabel setTextColor:[UIColor greenColor]];
    }
    return _savingMoneyLabel;
}

- (UIButton *)sizeLine
{
    if (!VALID_NOTEMPTY(_sizeLine, UIButton)) {
        _sizeLine = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sizeLine setFrame:CGRectMake(kLateralMargin, self.savingView.y, self.width - 2*kLateralMargin, 20)];
        [_sizeLine.titleLabel setFont:JACaptionFont];
        [_sizeLine.titleLabel setTextColor:JABlackColor];
        [_sizeLine setTitleColor:JABlackColor forState:UIControlStateNormal];
        [_sizeLine setTitleColor:JABlackColor forState:UIControlStateDisabled];
        [_sizeLine setEnabled:NO];
        [_sizeLine addTarget:self action:@selector(sizeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sizeLine;
}

- (void)setChosenSize:(NSString *)chosenSize
{
    _chosenSize = chosenSize;
}

- (UIView *)bottomContentView
{
    if (!VALID_NOTEMPTY(_bottomContentView, UIView)) {
        _bottomContentView = [[UIView alloc] initWithFrame:CGRectMake(kLateralMargin, self.height - kTopMargin - 48, (self.width - 2*kLateralMargin), kBottomDefaultHeight)];
        [_bottomContentView setBackgroundColor:JABlack300Color];
        [_bottomContentView addSubview:self.bottonBar];
        [_bottomContentView addSubview:self.percentageBarView];
        [_bottomContentView addSubview:self.remainingStockView];
    }
    return _bottomContentView;
}

- (JABottomBar *)bottonBar
{
    if (!VALID_NOTEMPTY(_bottonBar, JABottomBar)) {
        _bottonBar = [[JABottomBar alloc] initWithFrame:CGRectMake(self.bottomContentView.width/2, 0, self.bottomContentView.width/2, self.bottomContentView.height)];
        self.buyButton = [_bottonBar addButton:[STRING_BUY uppercaseString] target:self action:@selector(buyButtonPressed)];
        [self.buyButton setBackgroundImage:[UIImage imageWithColor:[UIColor grayColor]] forState:UIControlStateDisabled];
        [self.buyButton setBackgroundImage:[UIImage imageWithColor:JAOrange1Color] forState:UIControlStateNormal];
    }
    return _bottonBar;
}

- (JAPercentageBarView *)percentageBarView
{
    if (!VALID_NOTEMPTY(_percentageBarView, JAPercentageBarView)) {
        _percentageBarView = [[JAPercentageBarView alloc] initWithFrame:CGRectMake(10.f, 10.f, self.bottomContentView.width/2 - 2*10.f, 6.f)];
    }
    return _percentageBarView;
}

- (UIView *)remainingStockView
{
    if (!VALID_NOTEMPTY(_remainingStockView, UIView)) {
        _remainingStockView = [[UIView alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(self.percentageBarView.frame) + 8.f, self.percentageBarView.width, 21)];
        [_remainingStockView addSubview:self.remainingStockLabel];
        [_remainingStockView addSubview:self.remainingStockValueLabel];
    }
    return _remainingStockView;
}

- (UILabel *)remainingStockLabel
{
    if (!VALID_NOTEMPTY(_remainingStockLabel, UILabel)) {
        _remainingStockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.remainingStockView.width, 21)];
        [_remainingStockLabel setFont:JACaptionFont];
        [_remainingStockLabel setTextColor:JABlackColor];
        [_remainingStockLabel setText:STRING_CAMPAIGN_REMAINING_STOCK];
        [_remainingStockLabel sizeToFit];
    }
    return _remainingStockLabel;
}

- (UILabel *)remainingStockValueLabel
{
    if (!VALID_NOTEMPTY(_remainingStockValueLabel, UILabel)) {
        _remainingStockValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.remainingStockView.width, 21)];
        [_remainingStockValueLabel setFont:JACaptionFont];
        [_remainingStockValueLabel setTextColor:JABlackColor];
    }
    return _remainingStockValueLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.imageClickableView];
        [self addSubview:self.titleBrandLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.discountLabel];
        [self addSubview:self.timerView];
        [self addSubview:self.imageView];
        [self addSubview:self.priceLine];
        [self addSubview:self.savingView];
        [self addSubview:self.sizeLine];
        [self addSubview:self.bottomContentView];
    }
    return self;
}

- (void)loadWithCampaignProduct:(RICampaignProduct*)campaignProduct
           elapsedTimeInSeconds:(NSInteger)elapsedTimeInSeconds
                     chosenSize:(NSString*)chosenSize
               capaignHasBanner:(BOOL)hasBanner
{
    self.campaignProduct = campaignProduct;
    self.chosenSize = chosenSize;
    self.onSelected = nil;
    
    [self.titleBrandLabel setText:campaignProduct.brand];
    [self.titleLabel setText:campaignProduct.name];
    
    self.discountLabel.text = [NSString stringWithFormat:STRING_FORMAT_OFF,[campaignProduct.maxSavingPercentage integerValue]];
    self.discountLabel.hidden = ![campaignProduct.maxSavingPercentage boolValue];
    
    if (VALID_NOTEMPTY(self.campaignProduct.remainingTime, NSNumber)) {
        if (ISEMPTY(self.timer)) {
            self.elapsedTimeInSeconds = elapsedTimeInSeconds--;
            [self updateTimeLabelText];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(updateTimeLabelText)
                                                        userInfo:nil
                                                         repeats:YES];
            
            [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
    }else{
        [self.timer invalidate];
        self.timer = nil;
        [self.timerView setHidden:YES];
        [self.offerEndedLabel setHidden:YES];
        self.imageClickableView.enabled = YES;
        [self.buyButton setUserInteractionEnabled:YES];
        self.imageView.alpha = 1.0f;
        [self.offerEndedLabel setHidden:YES];

    }
    
    [self.imageView setImageWithURL:[NSURL URLWithString:campaignProduct.imagesUrl]
                   placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]
     ];
    
    if (VALID_NOTEMPTY(campaignProduct.priceRange, NSString)) {
        [self.priceLine setPrice:campaignProduct.priceRange];
        [self.priceLine setOldPrice:nil];
        [self.savingView setHidden:YES];
    } else if (VALID_NOTEMPTY(campaignProduct.specialPrice, NSNumber)) {
        [self.priceLine setPrice:campaignProduct.specialPriceFormatted];
        [self.priceLine setOldPrice:campaignProduct.priceFormatted];
        [self.savingMoneyLabel setText:campaignProduct.savePriceFormatted];
        [self.savingView setHidden:NO];
        
    } else {
        [self.priceLine setPrice:campaignProduct.priceFormatted];
        [self.priceLine setOldPrice:nil];
        [self.savingView setHidden:YES];
    }
    
    if (campaignProduct.productSimples.count > 1) {
        [self.sizeLine setHidden:NO];
        [self.sizeLine setTitle:[NSString stringWithFormat:@"%@: %@",campaignProduct.variationName, campaignProduct.variationAvailableList] forState:UIControlStateNormal];
    }else{
        [self.sizeLine setHidden:YES];
    }
    
    [self.remainingStockValueLabel setText:[NSString stringWithFormat:@"%ld%%", (long)[campaignProduct.stockPercentage integerValue]]];
    
    [self reloadView];
    
    [self.percentageBarView loadWithPercentage:[campaignProduct.stockPercentage integerValue]];
    
}

- (void)reloadView
{
    [self.imageClickableView setWidth:self.width];
    
    if (self.titleBrandLabel.textAlignment != NSTextAlignmentLeft)
        [self.titleBrandLabel setTextAlignment:NSTextAlignmentLeft];
    
    [self.titleBrandLabel setWidth:self.width - 2*kLateralMargin];
    [self setForRTL:self.titleBrandLabel];
    
    
    if (self.titleLabel.textAlignment != NSTextAlignmentLeft)
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.titleLabel setWidth:self.width - 2*kLateralMargin];
    [self setForRTL:self.titleLabel];
    
    CGRect discountLabelRect = CGRectMake(self.discountLabel.superview.width - 60 - kLateralMargin, kTopMargin, 60, 19);
    if (!CGRectEqualToRect(discountLabelRect, self.discountLabel.frame)) {
        [self.discountLabel setFrame:discountLabelRect];
        [self setForRTL:self.discountLabel];
    }
    
    [self.timerView setYBottomOf:self.titleLabel at:16.f];
    
    [self.imageView setXCenterAligned];
    [self.imageView setYBottomOf:self.timerView at:16.f];
    
    [self.priceLine sizeToFit];
    [self.priceLine setYBottomOf:self.imageView at:10.f];
    [self.priceLine setXCenterAligned];
    [self setForRTL:self.priceLine];
    
    [self.savingMoneyLabel sizeToFit];
    [self.savingMoneyLabel setY:0.f];
    [self.savingLabel setX:0.f];
    [self.savingMoneyLabel setXRightOf:self.savingLabel at:6.f];
    [self.savingView setWidth:CGRectGetMaxX(self.savingMoneyLabel.frame)];
    [self.savingView setHeight:CGRectGetMaxY(self.savingMoneyLabel.frame)];
    [self.savingLabel setYCenterAligned];
    [self.savingView setXCenterAligned];
    [self.savingView setYBottomOf:self.priceLine at:10.f];
    [self setForRTL:self.savingView];
    
    [self.sizeLine setWidth:self.width - 2*kLateralMargin];
    [self.sizeLine setYBottomOf:self.savingView at:10.f];
    [self.sizeLine setXCenterAligned];
    
    CGFloat bottomContentViewWidth = self.width - 2*kLateralMargin;
    if (bottomContentViewWidth != self.bottomContentView.width) {
        [self.bottomContentView setWidth:bottomContentViewWidth];
        [self.bottonBar setWidth:self.bottomContentView.width/2];
        [self.bottonBar setX:self.bottomContentView.width/2];
    }
    
    [self.percentageBarView setX:10.f];
    [self.percentageBarView setWidth:self.bottomContentView.width/2 - 2*10.f];
    
    [self.remainingStockView setFrame:CGRectMake(10.f, CGRectGetMaxY(self.percentageBarView.frame) + 10.f, self.percentageBarView.width, CGRectGetMaxY(self.remainingStockValueLabel.frame))];
    
    [self.remainingStockValueLabel sizeToFit];
    [self.remainingStockValueLabel setY:0.f];
    [self.remainingStockValueLabel setXRightAligned:0.f];
    
    [self.remainingStockLabel setX:0.f];
    [self.remainingStockLabel setY:0.f];

    
    [self.bottonBar setXRightAligned:0.f];
    
    [self.bottomContentView setXCenterAligned];
    [self.bottomContentView setYBottomOf:self.sizeLine at:16.f];
    [self setForRTL:self.bottomContentView];
}

- (void)setForRTL:(UIView *)view
{
    if (RI_IS_RTL) {
        [view flipViewPositionInsideSuperview];
        [view flipAllSubviews];
        if ([view isKindOfClass:[UILabel class]] && [(UILabel *)view textAlignment] != NSTextAlignmentCenter) {
            [(UILabel *)view setTextAlignment:NSTextAlignmentRight];
        } else if ([view isKindOfClass:[UIButton class]] && [(UIButton*)view contentHorizontalAlignment] != UIControlContentHorizontalAlignmentCenter)
        {
            ((UIButton*)view).contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }
}

- (void)updateTimeLabelText
{
    self.elapsedTimeInSeconds++;
    
    if (ISEMPTY(self.campaignProduct.remainingTime)) {
        self.timerView.hidden = YES;
        [self.offerEndedLabel setHidden:YES];
    } else {
        self.timerView.hidden = NO;
        NSInteger remainingSeconds = [self.campaignProduct.remainingTime integerValue];
        remainingSeconds -= self.elapsedTimeInSeconds;

        if (0 > remainingSeconds) {
            remainingSeconds = 0;
            
            self.imageClickableView.enabled = NO;
            [self.buyButton setUserInteractionEnabled:NO];
            self.imageView.alpha = 0.6f;
            [self.offerEndedLabel setXCenterAligned];
            [self.offerEndedLabel setHidden:NO];
        }else{
            [self.offerEndedLabel setHidden:YES];
        }
        
        NSInteger days = remainingSeconds / (24 * 3600);
        remainingSeconds = remainingSeconds % (24 * 3600); //keep the remainder
        NSInteger hours = remainingSeconds / 3600;
        remainingSeconds = remainingSeconds % 3600; //keep the remainder
        NSInteger minutes = remainingSeconds / 60;
        remainingSeconds = remainingSeconds % 60; //keep the remainder
        
        NSString* timeString = [NSString stringWithFormat:@"%02ldH %02ldM %02ldS",(long)hours,(long)minutes,(long)remainingSeconds];
        
        if (days > 0) {
            timeString = [NSString stringWithFormat:@"%02ld:%@",(long)days,timeString];
        }
        
        [self.endLabel sizeToFit];
        [self.endLabel setX:0.f];
        self.timerLabel.text = [timeString uppercaseString];
        [self.timerLabel sizeToFit];
        [self.timerLabel setX:CGRectGetMaxX(self.endLabel.frame) + 2.f];
        [self.timerView setWidth:CGRectGetMaxX(self.timerLabel.frame)];
        [self.timerView setXCenterAligned];
        [self setForRTL:self.timerView];
    }
}

- (void)buyButtonPressed
{
    if (YES == self.offerEndedLabel.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pressedAddToCartForProduct:withProductSimple:)]) {
            
            NSString* simpleSku;
            if (self.campaignProduct.productSimples.count == 1) {
                RICampaignProductSimple* simple = [self.campaignProduct.productSimples firstObject];
                simpleSku = simple.sku;
            } else {
                if ([self.chosenSize isEqualToString:@""]) {
                    [self sizeButtonPressed];
                    __weak typeof(self) weakSelf = self;
                    self.onSelected = ^{
                        [weakSelf buyButtonPressed];
                    };
                    return;
                }
                for (RICampaignProductSimple* simple in self.campaignProduct.productSimples) {
                    if ([self.chosenSize isEqualToString:simple.variation]) {
                        //found it
                        simpleSku = simple.sku;
                    }
                }
            }
            [self.delegate pressedAddToCartForProduct:self.campaignProduct
                                    withProductSimple:simpleSku];
        }
    }
}

- (void)sizeButtonPressed
{
    if (YES == self.offerEndedLabel.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pressedSizeOnView:)]) {
            [self.delegate pressedSizeOnView:self];
        }
    }
}

- (void)backViewPressed
{
    if (YES == self.offerEndedLabel.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pressedCampaignProductWithTarget:)]) {
            [self.delegate pressedCampaignProductWithTarget:self.campaignProduct.targetString];
        }
    }
}


@end
