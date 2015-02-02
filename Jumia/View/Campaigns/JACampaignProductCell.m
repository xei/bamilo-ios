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

@interface JACampaignProductCell()

@property (nonatomic, assign)NSInteger elapsedTimeInSeconds;

@property (nonatomic, strong)RICampaignProduct* campaignProduct;

@property (weak, nonatomic) IBOutlet UIView *backgroundContentView;

@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *discountBadge;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong)UIImageView* clockImageView;
@property (nonatomic, strong)UILabel* endLabel;
@property (nonatomic, strong)UILabel* timeLabel;

@property (weak, nonatomic) IBOutlet JAClickableView *imageClickableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
@property (nonatomic, strong)UIView* coverupView;
@property (nonatomic, strong)JAPriceView* priceView;
@property (weak, nonatomic) IBOutlet UILabel *savingLabel;
@property (nonatomic, strong)UILabel* savingMoneyLabel;
@property (nonatomic, strong)JAPercentageBarView* percentageBarView;
@property (weak, nonatomic) IBOutlet UILabel *remainingStockLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (nonatomic, strong)UIView* offerEndedContent;
@property (nonatomic, strong)UILabel* offerEndedLabel;

@property (nonatomic, strong)JAClickableView* sizeClickableView;
@property (nonatomic, strong)UILabel* sizeLabel;
@property (nonatomic, strong)UIView* sizeClickableViewSeparator;

@property (nonatomic, strong)NSTimer* timer;

@end

@implementation JACampaignProductCell

- (void)loadWithCampaignProduct:(RICampaignProduct*)campaignProduct
           elapsedTimeInSeconds:(NSInteger)elapsedTimeInSeconds
                     chosenSize:(NSString*)chosenSize;
{
    self.campaignProduct = campaignProduct;
    self.chosenSize = chosenSize;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.backgroundContentView.layer.cornerRadius = 5.0f;
    
    //TOP STUFF
    self.discountLabel.textColor = [UIColor whiteColor];
    if (VALID_NOTEMPTY(campaignProduct.maxSavingPercentage, NSNumber) && 0 < [campaignProduct.maxSavingPercentage integerValue]){
        self.discountBadge.hidden = NO;
        self.discountLabel.hidden = NO;
        self.discountLabel.text = [NSString stringWithFormat:STRING_FORMAT_OFF, [campaignProduct.maxSavingPercentage integerValue]];
    } else {
        self.discountBadge.hidden = YES;
        self.discountLabel.hidden = YES;
    }
    
    self.titleLabel.textColor = UIColorFromRGB(0x666666);
    self.titleLabel.text = campaignProduct.name;
    
    //IMAGE AREA
    [self.imageClickableView addTarget:self
                                action:@selector(backViewPressed)
                      forControlEvents:UIControlEventTouchUpInside];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:[campaignProduct.imagesUrls firstObject]]
                   placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
    
    //OFFER ENDED
    if (ISEMPTY(self.offerEndedLabel)) {
        self.offerEndedLabel = [UILabel new];
        self.offerEndedLabel.textAlignment = NSTextAlignmentCenter;
        self.offerEndedLabel.numberOfLines = -1;
        self.offerEndedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
        self.offerEndedLabel.textColor = UIColorFromRGB(0x4e4e4e);
        self.offerEndedLabel.text = STRING_CAMPAIGN_OFFER_ENDED;
        [self.offerEndedLabel sizeToFit];
    }
    
    CGFloat width = self.offerEndedLabel.frame.size.width;
    if (180.0f > width) {
        width = 180.0f;
    } else if (200.0f < width) {
        width = 200.0f;
    }
    CGFloat height = self.offerEndedLabel.frame.size.height;
    if (32.0f > height) {
        height = 32.0f;
    } else if (64.0f < height) {
        height = 64.0f;
    }
    
    if (ISEMPTY(self.offerEndedContent)) {
        self.offerEndedContent = [[UIView alloc] init];
        self.offerEndedContent.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        self.offerEndedContent.layer.cornerRadius = 5.0f;
        self.offerEndedContent.layer.borderColor = [[UIColor blackColor] CGColor];
        self.offerEndedContent.layer.borderWidth = 1.0f;
        [self.backgroundContentView addSubview:self.offerEndedContent];
    }
    self.offerEndedContent.frame = CGRectMake((self.backgroundContentView.bounds.size.width - width) / 2,
                                              (self.backgroundContentView.bounds.size.width - height) / 2,
                                              width,
                                              height);
    
    [self.offerEndedLabel setFrame:self.offerEndedContent.bounds];
    [self.offerEndedContent addSubview:self.offerEndedLabel];
    
    self.offerEndedContent.hidden = YES;
    
    //TIME COUNTER
    UIImage* clockImage = [UIImage imageNamed:@"ico_recentsearches_results"];
    if (ISEMPTY(self.clockImageView)) {
        self.clockImageView = [[UIImageView alloc] initWithImage:clockImage];
        [self.backgroundContentView addSubview:self.clockImageView];
    }

    if (ISEMPTY(self.endLabel)) {
        self.endLabel = [[UILabel alloc] init];
        self.endLabel.text = STRING_CAMPAIGN_TIMER_END;
        self.endLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        self.endLabel.textColor = UIColorFromRGB(0x666666);
        [self.endLabel sizeToFit];
        [self.backgroundContentView addSubview:self.endLabel];
    }
    
    CGFloat totalTimeWidth = clockImage.size.width + 5.0f + self.endLabel.frame.size.width;
    CGFloat xPosition = (self.backgroundContentView.frame.size.width - totalTimeWidth) / 2;
    
    [self.clockImageView setFrame:CGRectMake(xPosition,
                                             CGRectGetMaxY(self.titleLabel.frame) + 10.0f,
                                             clockImage.size.width,
                                             clockImage.size.height)];

    
    [self.endLabel setFrame:CGRectMake(CGRectGetMaxX(self.clockImageView.frame) + 10.0f,
                                       self.clockImageView.frame.origin.y,
                                       self.endLabel.frame.size.width,
                                       self.endLabel.frame.size.height)];
    
    if (ISEMPTY(self.timeLabel)) {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        self.timeLabel.textColor = UIColorFromRGB(0xcc0000);
        [self.timeLabel sizeToFit];
        [self.backgroundContentView addSubview:self.timeLabel];
    }
    [self.timeLabel setFrame:CGRectMake(CGRectGetMaxX(self.endLabel.frame) + 5.0f,
                                        self.endLabel.frame.origin.y,
                                        self.timeLabel.frame.size.width,
                                        self.timeLabel.frame.size.height)];
    
    //BOTTOM CONTENT
    if (ISEMPTY(self.coverupView)) {
        self.coverupView = [[UIView alloc] init];
        self.coverupView.backgroundColor = self.backgroundContentView.backgroundColor;
        [self.bottomContentView addSubview:self.coverupView];
    }
    self.coverupView.frame = CGRectMake(self.bottomContentView.bounds.origin.x,
                                        self.bottomContentView.bounds.origin.y,
                                        self.bottomContentView.bounds.size.width,
                                        10.0f);
    self.bottomContentView.layer.cornerRadius = self.backgroundContentView.layer.cornerRadius;
    self.bottomContentView.backgroundColor = UIColorFromRGB(0xfff7e6);
    
    [self.priceView removeFromSuperview]; //force reload;
    self.priceView = [[JAPriceView alloc] init];
    [self.bottomContentView addSubview:self.priceView];
    self.priceView.frame = CGRectMake(self.remainingStockLabel.frame.origin.x,
                                      self.bottomContentView.bounds.origin.y + self.coverupView.frame.size.height + 3.0f,
                                      self.remainingStockLabel.frame.size.width,
                                      self.remainingStockLabel.frame.size.height);
    if (VALID_NOTEMPTY(self.campaignProduct.specialPrice, NSNumber) && 0 != [self.campaignProduct.specialPrice integerValue]) {
        [self.priceView loadWithPrice:campaignProduct.priceFormatted
                         specialPrice:campaignProduct.specialPriceFormatted
                             fontSize:11.0f specialPriceOnTheLeft:NO];
    } else {
        [self.priceView loadWithPrice:campaignProduct.priceFormatted
                         specialPrice:nil
                             fontSize:11.0f specialPriceOnTheLeft:NO];
    }

    self.savingLabel.textColor = UIColorFromRGB(0x666666);
    self.savingLabel.text = STRING_CAMPAIGN_SAVE;
    [self.savingLabel sizeToFit];
    
    if (ISEMPTY(self.savingMoneyLabel)) {
        self.savingMoneyLabel = [[UILabel alloc] init];
        self.savingMoneyLabel.font = self.savingLabel.font;
        self.savingMoneyLabel.textColor = UIColorFromRGB(0x0a9f2a);
    }
    self.savingMoneyLabel.text = campaignProduct.savePriceFormatted;
    [self.savingMoneyLabel sizeToFit];
    self.savingMoneyLabel.frame = CGRectMake(CGRectGetMaxX(self.savingLabel.frame) + 4.0f,
                                             self.savingLabel.frame.origin.y + 4.0f,
                                             self.savingMoneyLabel.frame.size.width,
                                             self.savingMoneyLabel.frame.size.height);
    [self.bottomContentView addSubview:self.savingMoneyLabel];
    
    if (VALID_NOTEMPTY(campaignProduct.savePrice, NSNumber) && 0.0f < [campaignProduct.savePrice floatValue]) {
        [self.savingLabel setHidden:NO];
        [self.savingMoneyLabel setHidden:NO];
    } else {
        [self.savingLabel setHidden:YES];
        [self.savingMoneyLabel setHidden:YES];
    }
    
    if (ISEMPTY(self.percentageBarView)) {
        self.percentageBarView = [[JAPercentageBarView alloc] init];
        [self.bottomContentView addSubview:self.percentageBarView];
    }
    self.percentageBarView.frame = CGRectMake(self.remainingStockLabel.frame.origin.x,
                                              self.remainingStockLabel.frame.origin.y,
                                              150.0f,
                                              3.0f);
    [self.percentageBarView loadWithPercentage:[campaignProduct.stockPercentage integerValue]];

    
    self.remainingStockLabel.textColor = UIColorFromRGB(0x666666);
    self.remainingStockLabel.text = [NSString stringWithFormat:STRING_CAMPAIGN_REMAINING_STOCK, [campaignProduct.stockPercentage integerValue]];
    
    [self.buyButton setTitle:STRING_ADD_TO_SHOPPING_CART forState:UIControlStateNormal];
    [self.buyButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.buyButton addTarget:self action:@selector(buyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (campaignProduct.productSimples.count > 1) {

        if (VALID_NOTEMPTY(self.sizeClickableViewSeparator, UIView)) {
            [self.sizeClickableViewSeparator removeFromSuperview];
        }
        if (VALID_NOTEMPTY(self.sizeLabel, UILabel)) {
            [self.sizeLabel removeFromSuperview];
        }
        if (VALID_NOTEMPTY(self.sizeClickableView, JAClickableView)) {
            [self.sizeClickableView removeFromSuperview];
        }
        
        self.sizeClickableView = [[JAClickableView alloc] init];
        [self.sizeClickableView addTarget:self
                                   action:@selector(sizeButtonPressed)
                         forControlEvents:UIControlEventTouchUpInside];
        self.sizeClickableView.backgroundColor = [UIColor whiteColor];
        [self.backgroundContentView addSubview:self.sizeClickableView];
        self.sizeClickableView.frame = CGRectMake(self.backgroundContentView.bounds.origin.x,
                                                  self.bottomContentView.frame.origin.y + 10.0f - 44.0f,
                                                  self.backgroundContentView.bounds.size.width,
                                                  44.0f);
        
        self.sizeClickableViewSeparator = [[UIView alloc] init];
        self.sizeClickableViewSeparator.backgroundColor = JABackgroundGrey;
        [self.sizeClickableView addSubview:self.sizeClickableViewSeparator];
        self.sizeClickableViewSeparator.frame = CGRectMake(self.sizeClickableView.bounds.origin.x,
                                                           self.sizeClickableView.bounds.origin.y,
                                                           self.sizeClickableView.bounds.size.width,
                                                           1.0f);
        self.sizeLabel = [[UILabel alloc] init];
        self.sizeLabel.textColor = UIColorFromRGB(0x55a1ff);
        self.sizeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        [self.sizeClickableView addSubview:self.sizeLabel];
        [self.sizeLabel setFrame:CGRectMake(self.sizeClickableView.bounds.origin.x + 10.0f,
                                            self.sizeClickableView.bounds.origin.y,
                                            self.sizeClickableView.bounds.size.width - 10.0f * 2,
                                            self.sizeClickableView.bounds.size.height)];
        if (VALID_NOTEMPTY(self.chosenSize, NSString)) {
            self.sizeLabel.text = [NSString stringWithFormat:STRING_SIZE_WITH_VALUE, self.chosenSize];
        } else {
            self.sizeLabel.text = STRING_SIZE;
        }
    } else {
        [self.sizeClickableView removeFromSuperview];
        self.sizeClickableView = nil;
    }
    
    self.elapsedTimeInSeconds = elapsedTimeInSeconds--;
    [self updateTimeLabelText];
    if (ISEMPTY(self.timer)) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimeLabelText)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)updateTimeLabelText
{
    self.elapsedTimeInSeconds++;
    
    if (ISEMPTY(self.campaignProduct.remainingTime)) {
        self.clockImageView.hidden = YES;
        self.endLabel.hidden = YES;
        self.timeLabel.hidden = YES;
    } else {
        NSInteger remainingSeconds = [self.campaignProduct.remainingTime integerValue];
        remainingSeconds -= self.elapsedTimeInSeconds;
        
        if (0 > remainingSeconds) {
            remainingSeconds = 0;
            
            self.offerEndedContent.hidden = NO;
            self.imageClickableView.enabled = NO;
            self.buyButton.enabled = NO;
            self.imageView.alpha = 0.6f;
        }
        
        NSInteger days = remainingSeconds / (24 * 3600);
        remainingSeconds = remainingSeconds % (24 * 3600); //keep the remainder
        NSInteger hours = remainingSeconds / 3600;
        remainingSeconds = remainingSeconds % 3600; //keep the remainder
        NSInteger minutes = remainingSeconds / 60;
        remainingSeconds = remainingSeconds % 60; //keep the remainder
        
        NSString* timeString = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,remainingSeconds];
        
        if (days > 0) {
            timeString = [NSString stringWithFormat:@"%02d:%@",days,timeString];
        }
        
        self.timeLabel.text = timeString;
        [self.timeLabel sizeToFit];
    }
}

- (void)buyButtonPressed
{
    if (YES == self.offerEndedContent.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pressedAddToCartForProduct:withProductSimple:)]) {
            
            NSString* simpleSku;
            if (self.campaignProduct.productSimples.count == 1) {
                RICampaignProductSimple* simple = [self.campaignProduct.productSimples firstObject];
                simpleSku = simple.sku;
            } else {
                for (RICampaignProductSimple* simple in self.campaignProduct.productSimples) {
                    if ([self.chosenSize isEqualToString:simple.size]) {
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
    if (YES == self.offerEndedContent.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pressedSizeOnView:)]) {
            [self.delegate pressedSizeOnView:self];
        }
    }
}

- (void)backViewPressed
{
    if (YES == self.offerEndedContent.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pressedCampaignWithSku:)]) {
            [self.delegate pressedCampaignWithSku:self.campaignProduct.sku];
        }
    }
}


@end
