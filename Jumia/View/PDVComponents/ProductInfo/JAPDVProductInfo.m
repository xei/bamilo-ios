//
//  JAPDVProductInfo.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVProductInfo.h"
#import "JAPriceView.h"
#import "RIProduct.h"
#import "RIProductSimple.h"

@interface JAPDVProductInfo()

@property (nonatomic, strong)JAPriceView* priceView;

@property (weak, nonatomic) IBOutlet JAClickableView *reviewsView;
@property (weak, nonatomic) IBOutlet UILabel *reviewsLabel;
@property (weak, nonatomic) IBOutlet UIView *reviewsSeparator;
@property (weak, nonatomic) IBOutlet UIView *productFeaturesView;
@property (weak, nonatomic) IBOutlet UILabel *productFeaturesLabel;
@property (weak, nonatomic) IBOutlet UIView *productFeaturesSeparator;
@property (weak, nonatomic) IBOutlet UILabel *productFeaturesText;
@property (weak, nonatomic) IBOutlet UIView *productDescriptionView;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIView *productDescriptionSeparator;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionText;
@property (weak, nonatomic) IBOutlet UIView *otherOffersTopSeparator;
@property (weak, nonatomic) IBOutlet UILabel *otherOffersLabel;
@property (strong, nonatomic) UILabel *fromLabel;
@property (strong, nonatomic) UILabel *offerMinPriceLabel;

@property (nonatomic, strong) RIProduct* product;

@end

@implementation JAPDVProductInfo

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVProductInfo *)getNewPDVProductInfoSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVProductInfo"
                                                 owner:nil
                                               options:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVProductInfo~iPad_Portrait"
                                            owner:nil
                                          options:nil];
    
    }
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVProductInfo class]]) {
            JAPDVProductInfo *object = (JAPDVProductInfo *)obj;
            return object;
        }
    }
    
    return nil;
}

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize
{
    self.product = product;
    
    self.oldPriceLabel.font = [UIFont fontWithName:kFontRegularName size:self.oldPriceLabel.font.pointSize];
    self.sizeLabel.font = [UIFont fontWithName:kFontRegularName size:self.sizeLabel.font.pointSize];
    self.numberOfReviewsLabel.font = [UIFont fontWithName:kFontRegularName size:self.numberOfReviewsLabel.font.pointSize];
    self.specificationsLabel.font = [UIFont fontWithName:kFontRegularName size:self.specificationsLabel.font.pointSize];
    self.reviewsLabel.font = [UIFont fontWithName:kFontRegularName size:self.reviewsLabel.font.pointSize];
    self.productFeaturesLabel.font = [UIFont fontWithName:kFontRegularName size:self.productFeaturesLabel.font.pointSize];
    self.productFeaturesText.font = [UIFont fontWithName:kFontRegularName size:self.productFeaturesText.font.pointSize];
    self.productDescriptionLabel.font = [UIFont fontWithName:kFontRegularName size:self.productDescriptionLabel.font.pointSize];
    self.productDescriptionText.font = [UIFont fontWithName:kFontRegularName size:self.productDescriptionText.font.pointSize];
    self.otherOffersLabel.font = [UIFont fontWithName:kFontRegularName size:self.otherOffersLabel.font.pointSize];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            [self setupForLandscape:frame product:product];
        }
        else
        {
            [self setupForPortrait:frame product:product preSelectedSize:preSelectedSize];
        }
    }
    else
    {
        [self setupForPortrait:frame product:product preSelectedSize:preSelectedSize];
    }
}

- (NSString*)ratingAndReviewString:(RIProduct*)product
{
    NSString* ratingString = @"";
    NSString* reviewString = @"";
    if (VALID_NOTEMPTY(product.ratingsTotal, NSNumber)) {
        if (1 == [product.ratingsTotal integerValue]) {
            ratingString = STRING_RATING;
        } else {
            ratingString = [NSString stringWithFormat:STRING_RATINGS, [product.ratingsTotal integerValue]];
        }
    }
    
    
    if (VALID_NOTEMPTY(product.reviewsTotal, NSNumber)) {
        if (1 == [product.reviewsTotal integerValue]) {
            reviewString = STRING_REVIEW;
        } else {
            reviewString = [NSString stringWithFormat:STRING_REVIEWS, [product.reviewsTotal integerValue]];
        }
    }
    
    
    NSString* finalString = @"";
    
    if (VALID_NOTEMPTY(ratingString, NSString)) {
        
        finalString = ratingString;
        
        if (VALID_NOTEMPTY(reviewString, NSString)) {
            
            finalString = [NSString stringWithFormat:@"%@ / %@", ratingString, reviewString];
            
            if (0 == [product.ratingsTotal integerValue] && 0 == [product.reviewsTotal integerValue]) {
                
                finalString = STRING_RATE_NOW;
            }
        } else {
            
            if (0 == [product.ratingsTotal integerValue]) {
                
                finalString = STRING_RATE_NOW;
            }
        }
    } else {
        
        if (VALID_NOTEMPTY(reviewString, NSString) &&  0 == [product.reviewsTotal integerValue]) {
            
            finalString = reviewString;
            
        } else {
            
            finalString = STRING_RATE_NOW;
        }
    }
    return finalString;
}

- (void)setupForPortrait:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize
{
    self.layer.cornerRadius = 5.0f;
    
    [self.sizeLabel setTextColor:UIColorFromRGB(0x55a1ff)];
    [self.numberOfReviewsLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.specificationsLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.otherOffersLabel setTextColor:UIColorFromRGB(0x666666)];
    
    CGFloat width = frame.size.width - 12.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    
    [self.priceSeparator setFrame:CGRectMake(self.priceSeparator.frame.origin.x,
                                             self.priceSeparator.frame.origin.y,
                                             width,
                                             self.priceSeparator.frame.size.height)];
    
    [self.sizeClickableView setFrame:CGRectMake(self.sizeClickableView.frame.origin.x,
                                                self.sizeClickableView.frame.origin.y,
                                                width,
                                                self.sizeClickableView.frame.size.height)];
    
    [self.sizeImageViewSeparator setFrame:CGRectMake(self.sizeImageViewSeparator.frame.origin.x,
                                                     self.sizeImageViewSeparator.frame.origin.y,
                                                     width,
                                                     self.sizeImageViewSeparator.frame.size.height)];
    
    [self.reviewsClickableView setFrame:CGRectMake(self.reviewsClickableView.frame.origin.x,
                                                   self.reviewsClickableView.frame.origin.y,
                                                   width,
                                                   self.reviewsClickableView.frame.size.height)];
    
    [self.goToReviewsImageView setFrame:CGRectMake(self.reviewsClickableView.frame.size.width - self.reviewsClickableView.frame.origin.x - self.goToReviewsImageView.frame.size.width - 9.0f,
                                                   self.goToReviewsImageView.frame.origin.y,
                                                   self.goToReviewsImageView.frame.size.width,
                                                   self.goToReviewsImageView.frame.size.height)];
    
    [self.ratingsSeparator setFrame:CGRectMake(self.ratingsSeparator.frame.origin.x,
                                               self.ratingsSeparator.frame.origin.y,
                                               width,
                                               self.ratingsSeparator.frame.size.height)];
    
    [self.specificationsClickableView setFrame:CGRectMake(self.specificationsClickableView.frame.origin.x,
                                                          self.specificationsClickableView.frame.origin.y,
                                                          width,
                                                          self.specificationsClickableView.frame.size.height)];
    
    [self.goToSpecificationsImageView setFrame:CGRectMake(self.sizeClickableView.frame.size.width - self.specificationsClickableView.frame.origin.x - self.goToSpecificationsImageView.frame.size.width - 9.0f,
                                                          self.goToSpecificationsImageView.frame.origin.y,
                                                          self.goToSpecificationsImageView.frame.size.width,
                                                          self.goToSpecificationsImageView.frame.size.height)];
    
    [self.otherOffersClickableView setFrame:CGRectMake(self.otherOffersClickableView.frame.origin.x,
                                                       self.otherOffersClickableView.frame.origin.y,
                                                       width,
                                                       self.otherOffersClickableView.frame.size.height)];
    
    [self.goToOtherOffersImageView setFrame:CGRectMake(self.otherOffersClickableView.frame.size.width - self.otherOffersClickableView.frame.origin.x - self.goToOtherOffersImageView.frame.size.width - 9.0f,
                                                          self.goToOtherOffersImageView.frame.origin.y,
                                                          self.goToOtherOffersImageView.frame.size.width,
                                                          self.goToOtherOffersImageView.frame.size.height)];
    
    for(UIView *subView in self.subviews)
    {
        [subView setFrame:CGRectMake(subView.frame.origin.x,
                                     subView.frame.origin.y,
                                     width,
                                     subView.frame.size.height)];
    }
    
    [self setPriceWithNewValue:product.specialPriceFormatted
                   andOldValue:product.priceFormatted];
    
    [self setNumberOfStars:[product.ratingAverage integerValue]];
    
    self.numberOfReviewsLabel.text = [self ratingAndReviewString:product];
    
    self.specificationsLabel.text = STRING_SPECIFICATIONS;
    
    /*
     Check if there is size
     
     if there is only one size: put that size and remove the action
     if there are more than one size, open the picker
     
     */
    if (ISEMPTY(product.productSimples))
    {
        [self removeSizeOptions];
    }
    else if (1 == product.productSimples.count)
    {
        [self.sizeClickableView setEnabled:NO];
        RIProductSimple *currentSimple = product.productSimples[0];
        
        if (VALID_NOTEMPTY(currentSimple.variation, NSString))
        {
            [self.sizeLabel setText:currentSimple.variation];
        }
        else
        {
            [self removeSizeOptions];
            [self layoutSubviews];
        }
    }
    else if (1 < product.productSimples.count)
    {
        [self.sizeClickableView setEnabled:YES];
        [self.sizeLabel setText:STRING_SIZE];
        
        if (VALID_NOTEMPTY(preSelectedSize, NSString))
        {
            for (RIProductSimple *simple in product.productSimples)
            {
                if ([simple.variation isEqualToString:preSelectedSize])
                {
                    [self.sizeLabel setText:simple.variation];
                    break;
                }
            }
        }
    }
    
    
    /*
     Check if there are other offers
     */
    if (NO == VALID_NOTEMPTY(product.offersTotal, NSNumber) || 0 >= [product.offersTotal integerValue]) {
        [self removeOtherOffers];
    } else {
        self.otherOffersLabel.text = [NSString stringWithFormat:@"%@ (%ld)", STRING_OTHER_SELLERS, [product.offersTotal longValue]];

        [self.otherOffersClickableView addTarget:self action:@selector(pressedOtherOffers) forControlEvents:UIControlEventTouchUpInside];
        
        self.fromLabel = [UILabel new];
        [self.fromLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.fromLabel setFont:[UIFont fontWithName:kFontRegularName size:9.0f]];
        self.fromLabel.text = [NSString stringWithFormat:@"%@ ", STRING_FROM];
        [self.fromLabel sizeToFit];
        [self.fromLabel setFrame:CGRectMake(self.otherOffersLabel.frame.origin.x,
                                            CGRectGetMaxY(self.otherOffersLabel.frame) - 2.0f,
                                            self.fromLabel.frame.size.width,
                                            self.fromLabel.frame.size.height)];
        [self.otherOffersClickableView addSubview:self.fromLabel];
        
        self.offerMinPriceLabel = [UILabel new];
        [self.offerMinPriceLabel setTextColor:UIColorFromRGB(0xcc0000)];
        [self.offerMinPriceLabel setFont:[UIFont fontWithName:kFontRegularName size:9.0f]];
        self.offerMinPriceLabel.text = product.offersMinPriceFormatted;
        [self.offerMinPriceLabel sizeToFit];
        [self.offerMinPriceLabel setFrame:CGRectMake(CGRectGetMaxX(self.fromLabel.frame),
                                                     self.fromLabel.frame.origin.y,
                                                     self.offerMinPriceLabel.frame.size.width,
                                                     self.offerMinPriceLabel.frame.size.height)];
        [self.otherOffersClickableView addSubview:self.offerMinPriceLabel];

    }
}

- (void)pressedOtherOffers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenOtherOffers object:self.product];
}

- (void)setupForLandscape:(CGRect)frame product:(RIProduct*)product
{
    self.layer.cornerRadius = 5.0f;
    CGFloat startingY = 0.0f;
    
    [self.sizeLabel setTextColor:UIColorFromRGB(0x55a1ff)];
    [self.numberOfReviewsLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.specificationsLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.otherOffersLabel setTextColor:UIColorFromRGB(0x666666)];
    
    CGFloat width = frame.size.width - 12.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              90.0f)];
    
    
    [self.reviewsClickableView setFrame:CGRectMake(self.reviewsClickableView.frame.origin.x,
                                                   startingY,
                                                   width,
                                                   self.reviewsClickableView.frame.size.height)];
    
    [self.goToReviewsImageView setFrame:CGRectMake(self.reviewsClickableView.frame.size.width - self.reviewsClickableView.frame.origin.x - self.goToReviewsImageView.frame.size.width - 9.0f,
                                                   self.goToReviewsImageView.frame.origin.y,
                                                   self.goToReviewsImageView.frame.size.width,
                                                   self.goToReviewsImageView.frame.size.height)];
    
    [self.ratingsSeparator setFrame:CGRectMake(self.ratingsSeparator.frame.origin.x,
                                               45.0f,
                                               width,
                                               self.ratingsSeparator.frame.size.height)];
    
    [self.specificationsClickableView setFrame:CGRectMake(self.specificationsClickableView.frame.origin.x,
                                                          46.0f,
                                                          width,
                                                          self.specificationsClickableView.frame.size.height)];
    
    [self.goToSpecificationsImageView setFrame:CGRectMake(self.reviewsClickableView.frame.size.width - self.reviewsClickableView.frame.origin.x - self.goToReviewsImageView.frame.size.width - 9.0f,
                                                          self.goToSpecificationsImageView.frame.origin.y,
                                                          self.goToSpecificationsImageView.frame.size.width,
                                                          self.goToSpecificationsImageView.frame.size.height)];
    

    
    for(UIView *subView in self.subviews)
    {
        [subView setFrame:CGRectMake(subView.frame.origin.x,
                                     subView.frame.origin.y,
                                     width,
                                     subView.frame.size.height)];
    }
    
    [self setPriceWithNewValue:product.specialPriceFormatted
                   andOldValue:product.priceFormatted];
    
    [self setNumberOfStars:[product.ratingAverage integerValue]];
    
    self.numberOfReviewsLabel.text = [self ratingAndReviewString:product];
    
    self.specificationsLabel.text = STRING_SPECIFICATIONS;
    
    [self.sizeClickableView removeFromSuperview];
    [self.sizeImageViewSeparator removeFromSuperview];
    
    [self.otherOffersClickableView removeFromSuperview];
    [self.otherOffersTopSeparator removeFromSuperview];
    
    [self.priceView removeFromSuperview];
    [self.priceSeparator removeFromSuperview];
    
}

- (void)setPriceWithNewValue:(NSString *)newValue
                 andOldValue:(NSString *)oldValue
{
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:oldValue
                     specialPrice:newValue
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(6.0f,
                                      14.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self addSubview:self.priceView];
    
    [self layoutSubviews];
}

- (void)removeOtherOffers
{
    [self.otherOffersClickableView removeFromSuperview];
    [self.otherOffersTopSeparator removeFromSuperview];
    
    CGRect frame = self.frame;
    frame.size.height -= 44.0f;
    
    self.frame = frame;
}

- (void)removeSizeOptions
{
    [self.sizeClickableView removeFromSuperview];
    
    CGRect reviewFrame = self.reviewsClickableView.frame;
    reviewFrame.origin.y -= 44.0f;
    self.reviewsClickableView.frame = reviewFrame;
    
    CGRect buttonFrame = self.specificationsClickableView.frame;
    buttonFrame.origin.y -= 44.0f;
    self.specificationsClickableView.frame = buttonFrame;
    
    CGRect otherOffersFrame = self.otherOffersClickableView.frame;
    otherOffersFrame.origin.y -= 44.0f;
    self.otherOffersClickableView.frame = otherOffersFrame;
    
    CGRect frame = self.frame;
    frame.size.height -= 44.0f;
    
    self.frame = frame;
}

- (void)setNumberOfStars:(NSInteger)stars
{
    self.star1.image = stars < 1 ? [self getEmptyStar] : [self getFilledStar];
    self.star2.image = stars < 2 ? [self getEmptyStar] : [self getFilledStar];
    self.star3.image = stars < 3 ? [self getEmptyStar] : [self getFilledStar];
    self.star4.image = stars < 4 ? [self getEmptyStar] : [self getFilledStar];
    self.star5.image = stars < 5 ? [self getEmptyStar] : [self getFilledStar];
}

- (UIImage *)getEmptyStar
{
    return [UIImage imageNamed:@"img_rating_star_big_empty"];
}

- (UIImage *)getFilledStar
{
    return [UIImage imageNamed:@"img_rating_star_big_full"];
}

@end
