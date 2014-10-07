//
//  JACampaignSingleView.m
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignSingleView.h"
#import "JAAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "JAPriceView.h"
#import "JAPercentageBarView.h"

@interface JACampaignSingleView()

@property (nonatomic, strong)RICampaign* campaign;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (weak, nonatomic) IBOutlet UILabel *offLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong)UIImageView* clockImageView;
@property (nonatomic, strong)UILabel* endLabel;
@property (nonatomic, strong)UILabel* timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *bottomContentView;
@property (nonatomic, strong)JAPriceView* priceView;
@property (weak, nonatomic) IBOutlet UILabel *savingLabel;
@property (nonatomic, strong)UILabel* savingMoneyLabel;
@property (nonatomic, strong)JAPercentageBarView* percentageBarView;
@property (weak, nonatomic) IBOutlet UILabel *remainingStockLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (nonatomic, strong)UIView* offerEndedContent;
@property (nonatomic, strong)UILabel* offerEndedLabel;

@property (nonatomic, strong)UIControl* sizeControl;
@property (nonatomic, strong)UILabel* sizeLabel;

@end

@implementation JACampaignSingleView

@synthesize chosenSize=_chosenSize;
- (void)setChosenSize:(NSString *)chosenSize
{
    _chosenSize = chosenSize;
    if (VALID_NOTEMPTY(self.sizeLabel, UILabel)) {
        self.sizeLabel.text = [NSString stringWithFormat:@"%@: %@", STRING_SIZE, chosenSize];
    }
}

+ (JACampaignSingleView *)getNewJACampaignSingleView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JACampaignSingleView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JACampaignSingleView class]]) {
            JACampaignSingleView *temp = (JACampaignSingleView *)obj;
            temp.frame = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame;
            return temp;
        }
    }
    
    return nil;
}

- (void)loadWithCampaign:(RICampaign*)campaign
{
    self.campaign = campaign;
    
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.layer.cornerRadius = 5.0f;
    
    //TOP STUFF
    self.discountLabel.textColor = [UIColor whiteColor];
    self.discountLabel.text = [NSString stringWithFormat:@"%d%%", [campaign.maxSavingPercentage integerValue]];
    self.offLabel.textColor = [UIColor whiteColor];
    self.offLabel.text = STRING_OFF;
    
    self.titleLabel.textColor = UIColorFromRGB(0x666666);
    self.titleLabel.text = campaign.name;

    //IMAGE AREA
    [self.imageView setImageWithURL:[NSURL URLWithString:[campaign.imagesUrls firstObject]]
                 placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
    
    UIControl* backClickArea = [[UIControl alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x,
                                                                           self.imageView.frame.origin.y,
                                                                           self.contentView.bounds.size.width,
                                                                           self.imageView.frame.size.height)];
    [self.contentView addSubview:backClickArea];
    [self.contentView sendSubviewToBack:self.contentView];
    [backClickArea addTarget:self
                      action:@selector(backViewPressed)
            forControlEvents:UIControlEventTouchUpInside];
    
    //OFFER ENDED
    self.offerEndedLabel = [UILabel new];
    self.offerEndedLabel.textAlignment = NSTextAlignmentCenter;
    self.offerEndedLabel.numberOfLines = -1;
    self.offerEndedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
    self.offerEndedLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.offerEndedLabel.text = STRING_CAMPAIGN_OFFER_ENDED;
    [self.offerEndedLabel sizeToFit];
    
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
    
    self.offerEndedContent = [[UIView alloc] initWithFrame:CGRectMake((self.contentView.bounds.size.width - width) / 2,
                                                                      (self.contentView.bounds.size.width - height) / 2,
                                                                      width,
                                                                      height)];
    self.offerEndedContent.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    self.offerEndedContent.layer.cornerRadius = 5.0f;
    self.offerEndedContent.layer.borderColor = [[UIColor blackColor] CGColor];
    self.offerEndedContent.layer.borderWidth = 1.0f;
    [self.contentView addSubview:self.offerEndedContent];
    
    [self.offerEndedLabel setFrame:self.offerEndedContent.bounds];
    [self.offerEndedContent addSubview:self.offerEndedLabel];
    
    self.offerEndedContent.hidden = YES;
    
    //TIME COUNTER
    UIImage* clockImage = [UIImage imageNamed:@"ico_recentsearches_results"];
    self.clockImageView = [[UIImageView alloc] initWithImage:clockImage];
    
    self.endLabel = [[UILabel alloc] init];
    self.endLabel.text = STRING_CAMPAIGN_TIMER_END;
    self.endLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    self.endLabel.textColor = UIColorFromRGB(0x666666);
    [self.endLabel sizeToFit];
    
    CGFloat totalTimeWidth = clockImage.size.width + 5.0f + self.endLabel.frame.size.width;
    CGFloat xPosition = (self.contentView.frame.size.width - totalTimeWidth) / 2;
    
    [self.clockImageView setFrame:CGRectMake(xPosition,
                                             CGRectGetMaxY(self.titleLabel.frame) + 10.0f,
                                             clockImage.size.width,
                                             clockImage.size.height)];
    [self.contentView addSubview:self.clockImageView];
    
    [self.endLabel setFrame:CGRectMake(CGRectGetMaxX(self.clockImageView.frame) + 10.0f,
                                       self.clockImageView.frame.origin.y,
                                       self.endLabel.frame.size.width,
                                       self.endLabel.frame.size.height)];
    [self.contentView addSubview:self.endLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    [self updateTimeLabelText:0];
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    self.timeLabel.textColor = UIColorFromRGB(0xcc0000);
    [self.timeLabel sizeToFit];
    [self.timeLabel setFrame:CGRectMake(CGRectGetMaxX(self.endLabel.frame) + 5.0f,
                                        self.endLabel.frame.origin.y,
                                        self.timeLabel.frame.size.width,
                                        self.timeLabel.frame.size.height)];
    [self.contentView addSubview:self.timeLabel];
    
    //BOTTOM CONTENT
    self.bottomContentView.layer.cornerRadius = self.contentView.layer.cornerRadius;
    UIView* coverupView = [[UIView alloc] initWithFrame:CGRectMake(self.bottomContentView.bounds.origin.x,
                                                                   self.bottomContentView.bounds.origin.y,
                                                                   self.bottomContentView.bounds.size.width,
                                                                   10.0f)];
    coverupView.backgroundColor = self.contentView.backgroundColor;
    [self.bottomContentView addSubview:coverupView];
    
    self.bottomContentView.backgroundColor = UIColorFromRGB(0xfff7e6);
    
    self.priceView = [[JAPriceView alloc] initWithFrame:CGRectMake(self.remainingStockLabel.frame.origin.x,
                                                                   self.bottomContentView.bounds.origin.y + coverupView.frame.size.height + 3.0f,
                                                                   self.remainingStockLabel.frame.size.width,
                                                                   self.remainingStockLabel.frame.size.height)];
    [self.priceView loadWithPrice:campaign.priceFormatted
                     specialPrice:campaign.specialPriceFormatted
                         fontSize:11.0f specialPriceOnTheLeft:NO];
    [self.bottomContentView addSubview:self.priceView];
    
    self.savingLabel.textColor = UIColorFromRGB(0x666666);
    self.savingLabel.text = STRING_CAMPAIGN_SAVE;
    [self.savingLabel sizeToFit];
    
    self.savingMoneyLabel = [[UILabel alloc] init];
    self.savingMoneyLabel.font = self.savingLabel.font;
    self.savingMoneyLabel.textColor = UIColorFromRGB(0x0a9f2a);
    self.savingMoneyLabel.text = campaign.savePriceFormatted;
    [self.savingMoneyLabel sizeToFit];
    self.savingMoneyLabel.frame = CGRectMake(CGRectGetMaxX(self.savingLabel.frame) + 4.0f,
                                             self.savingLabel.frame.origin.y + 4.0f,
                                             self.savingMoneyLabel.frame.size.width,
                                             self.savingMoneyLabel.frame.size.height);
    [self.bottomContentView addSubview:self.savingMoneyLabel];
    
    self.percentageBarView = [[JAPercentageBarView alloc] initWithFrame:CGRectMake(self.remainingStockLabel.frame.origin.x,
                                                                                   self.remainingStockLabel.frame.origin.y,
                                                                                   150.0f,
                                                                                   3.0f)];
    [self.percentageBarView loadWithPercentage:[campaign.stockPercentage integerValue]];
    [self.bottomContentView addSubview:self.percentageBarView];
    
    self.remainingStockLabel.textColor = UIColorFromRGB(0x666666);
    self.remainingStockLabel.text = [NSString stringWithFormat:STRING_CAMPAIGN_REMAINING_STOCK, [campaign.stockPercentage integerValue]];
    
    [self.buyButton setTitle:STRING_ADD_TO_SHOPPING_CART forState:UIControlStateNormal];
    [self.buyButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.buyButton addTarget:self action:@selector(buyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if (campaign.productSimples.count > 1) {
        self.sizeControl = [[UIControl alloc] initWithFrame:CGRectMake(self.contentView.bounds.origin.x,
                                                                       self.bottomContentView.frame.origin.y + 10.0f - 44.0f,
                                                                       self.contentView.bounds.size.width,
                                                                       44.0f)];
        self.sizeControl.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.sizeControl];
        
        [self.sizeControl addTarget:self
                             action:@selector(sizeButtonPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        
        UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(self.sizeControl.bounds.origin.x,
                                                                         self.sizeControl.bounds.origin.y,
                                                                         self.sizeControl.bounds.size.width,
                                                                         1.0f)];
        separatorView.backgroundColor = JABackgroundGrey;
        [self.sizeControl addSubview:separatorView];
        
        self.sizeLabel = [[UILabel alloc] init];
        self.sizeLabel.text = STRING_SIZE;
        self.sizeLabel.textColor = UIColorFromRGB(0x55a1ff);
        self.sizeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        [self.sizeLabel setFrame:CGRectMake(self.sizeControl.bounds.origin.x + 10.0f,
                                            self.sizeControl.bounds.origin.y,
                                            self.sizeControl.bounds.size.width - 10.0f * 2,
                                            self.sizeControl.bounds.size.height)];
        [self.sizeControl addSubview:self.sizeLabel];
    }
}

- (void)updateTimeLabelText:(NSInteger)elapsedTimeInSeconds
{
    NSInteger remainingSeconds = [self.campaign.remainingTime integerValue];
    remainingSeconds -= elapsedTimeInSeconds;
    
    if (0 > remainingSeconds) {
        remainingSeconds = 0;
        
        self.offerEndedContent.hidden = NO;
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

- (void)buyButtonPressed
{
    if (YES == self.offerEndedContent.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(addToCartForProduct:withProductSimple:)]) {
            
            NSString* simpleSku;
            if (self.campaign.productSimples.count == 1) {
                RICampaignProductSimple* simple = [self.campaign.productSimples firstObject];
                simpleSku = simple.sku;
            } else {
                for (RICampaignProductSimple* simple in self.campaign.productSimples) {
                    if ([self.chosenSize isEqualToString:simple.size]) {
                        //found it
                        simpleSku = simple.sku;
                    }
                }
            }
            [self.delegate addToCartForProduct:self.campaign
                             withProductSimple:simpleSku];
        }
    }
}

- (void)sizeButtonPressed
{
    if (YES == self.offerEndedContent.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sizePressedOnView:)]) {
            [self.delegate sizePressedOnView:self];
        }
    }
}

- (void)backViewPressed
{
    if (YES == self.offerEndedContent.hidden) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pressedCampaignWithSku:)]) {
            [self.delegate pressedCampaignWithSku:self.campaign.sku];
        }
    }
}

@end
