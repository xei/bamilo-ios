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
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVProductInfo~iPad_Landscape"
                                                owner:nil
                                              options:nil];
        }
    }
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVProductInfo class]]) {
            JAPDVProductInfo *object = (JAPDVProductInfo *)obj;
            return object;
        }
    }
    
    return nil;
}

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize numberOfRatings:(NSString*)numberOfRatings
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            [self setupForLandscape:frame product:product numberOfRatings:numberOfRatings];
        }
        else
        {
            [self setupForPortrait:frame product:product preSelectedSize:preSelectedSize numberOfRatings:numberOfRatings];
        }
    }
    else
    {
        [self setupForPortrait:frame product:product preSelectedSize:preSelectedSize numberOfRatings:numberOfRatings];
    }
}

- (void)setupForPortrait:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize numberOfRatings:(NSString*)numberOfRatings
{
    self.layer.cornerRadius = 5.0f;
    
    [self.sizeLabel setTextColor:UIColorFromRGB(0x55a1ff)];
    
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
    
    for(UIView *subView in self.subviews)
    {
        [subView setFrame:CGRectMake(subView.frame.origin.x,
                                     subView.frame.origin.y,
                                     width,
                                     subView.frame.size.height)];
    }
    
    [self setPriceWithNewValue:product.specialPriceFormatted
                   andOldValue:product.priceFormatted];
    
    [self setNumberOfStars:[product.avr integerValue]];
    
    if (VALID_NOTEMPTY(numberOfRatings, NSString) && [numberOfRatings integerValue] > 0)
    {
        self.numberOfReviewsLabel.text = [NSString stringWithFormat:STRING_REVIEWS, numberOfRatings];
    }
    else
    {
        self.numberOfReviewsLabel.text = STRING_RATE_NOW;
    }
    
    self.specificationsLabel.text = STRING_SPECIFICATIONS;
    [self.specificationsLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    
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
}

- (void)setupForLandscape:(CGRect)frame product:(RIProduct*)product numberOfRatings:(NSString*)numberOfRatings
{
    CGFloat width = frame.size.width - 12.0f;
    
    self.reviewsView.layer.cornerRadius = 5.0f;
    [self.reviewsLabel setText:STRING_REVIEWS_LABEL];
    [self.reviewsLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.reviewsSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self setNumberOfStars:[product.avr integerValue]];
    
    if (VALID_NOTEMPTY(numberOfRatings, NSString) && [numberOfRatings integerValue] > 0)
    {
        self.numberOfReviewsLabel.text = [NSString stringWithFormat:STRING_REVIEWS, numberOfRatings];
    }
    else
    {
        self.numberOfReviewsLabel.text = STRING_RATE_NOW;
    }
    
    [self.reviewsClickableView setFrame:CGRectMake(self.reviewsClickableView.frame.origin.x,
                                                   self.reviewsClickableView.frame.origin.y,
                                                   width,
                                                   self.reviewsClickableView.frame.size.height)];
    
    [self.goToReviewsImageView setFrame:CGRectMake(self.reviewsClickableView.frame.size.width - self.reviewsClickableView.frame.origin.x - self.goToReviewsImageView.frame.size.width - 9.0f,
                                                   self.goToReviewsImageView.frame.origin.y,
                                                   self.goToReviewsImageView.frame.size.width,
                                                   self.goToReviewsImageView.frame.size.height)];
    
    self.productFeaturesView.translatesAutoresizingMaskIntoConstraints = YES;
    self.productFeaturesView.layer.cornerRadius = 5.0f;
    [self.productFeaturesLabel setText:STRING_PRODUCT_FEATURES];
    [self.productFeaturesLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.productFeaturesSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    self.productFeaturesText.translatesAutoresizingMaskIntoConstraints = YES;
    [self.productFeaturesText setText:product.attributeShortDescription];

    [self.productFeaturesText setTextColor:UIColorFromRGB(0x666666)];
    [self.productFeaturesText setFrame:CGRectMake(self.productFeaturesText.frame.origin.x,
                                                  self.productFeaturesText.frame.origin.y,
                                                  width - (self.productFeaturesText.frame.origin.x * 2),
                                                  self.productFeaturesText.frame.size.height)];
    
    CGRect productFeaturesTextRect = [self.productFeaturesText.text boundingRectWithSize:CGSizeMake(self.productFeaturesText.frame.size.width, 1000.0f)
                                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                                              attributes:@{NSFontAttributeName:self.productFeaturesText.font} context:nil];
    if(productFeaturesTextRect.size.height > self.productFeaturesText.frame.size.height)
    {
        [self.productFeaturesMore setTitle:STRING_MORE forState:UIControlStateNormal];
        [self.productFeaturesMore setBackgroundColor:[UIColor clearColor]];
        [self.productFeaturesMore setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [self.productFeaturesMore setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    }
    else
    {
        [self.productFeaturesMore removeFromSuperview];
        
        [self.productFeaturesText setFrame:CGRectMake(self.productFeaturesText.frame.origin.x,
                                                      self.productFeaturesText.frame.origin.y,
                                                      self.productFeaturesText.frame.size.width,
                                                      productFeaturesTextRect.size.height)];
        
        [self.productFeaturesView setFrame:CGRectMake(self.productFeaturesView.frame.origin.x,
                                                      self.productFeaturesView.frame.origin.y,
                                                      self.productFeaturesView.frame.size.width,
                                                      self.productFeaturesText.frame.origin.y +  productFeaturesTextRect.size.height + 6.0f)];
    }
    
    self.productDescriptionView.translatesAutoresizingMaskIntoConstraints = YES;
    self.productDescriptionView.layer.cornerRadius = 5.0f;
    
    [self.productDescriptionView setFrame:CGRectMake(self.productDescriptionView.frame.origin.x,
                                                     CGRectGetMaxY(self.productFeaturesView.frame) + 6.0f,
                                                     self.productDescriptionView.frame.size.width,
                                                     self.productDescriptionView.frame.size.height)];
    
    [self.productDescriptionLabel setText:STRING_PRODUCT_DESCRIPTION];
    [self.productDescriptionLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.productDescriptionSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    self.productDescriptionText.translatesAutoresizingMaskIntoConstraints = YES;
    [self.productDescriptionText setText:product.descriptionString];
    [self.productDescriptionText setTextColor:UIColorFromRGB(0x666666)];
    
    [self.productDescriptionText setFrame:CGRectMake(self.productDescriptionText.frame.origin.x,
                                                     self.productDescriptionText.frame.origin.y,
                                                     width - (self.productDescriptionText.frame.origin.x * 2),
                                                     self.productDescriptionText.frame.size.height)];
    
    CGRect productDescriptionTextRect = [self.productDescriptionText.text boundingRectWithSize:CGSizeMake(self.productDescriptionText.frame.size.width, 1000.0f)
                                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                                    attributes:@{NSFontAttributeName:self.productDescriptionText.font} context:nil];
    if(productDescriptionTextRect.size.height > self.productDescriptionText.frame.size.height)
    {
        [self.productDescriptionMore setTitle:STRING_MORE forState:UIControlStateNormal];
        [self.productDescriptionMore setBackgroundColor:[UIColor clearColor]];
        [self.productDescriptionMore setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [self.productDescriptionMore setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    }
    else
    {
        [self.productDescriptionMore removeFromSuperview];
        
        [self.productDescriptionText setFrame:CGRectMake(self.productDescriptionText.frame.origin.x,
                                                         self.productDescriptionText.frame.origin.y,
                                                         self.productDescriptionText.frame.size.width,
                                                         productDescriptionTextRect.size.height)];
        
        [self.productDescriptionView setFrame:CGRectMake(self.productDescriptionView.frame.origin.x,
                                                         self.productDescriptionView.frame.origin.y,
                                                         self.productDescriptionView.frame.size.width,
                                                         self.productDescriptionText.frame.origin.y +  productDescriptionTextRect.size.height + 6.0f)];
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              CGRectGetMaxY(self.productDescriptionView.frame))];
    
    
    for(UIView *subView in self.subviews)
    {
        [subView setFrame:CGRectMake(subView.frame.origin.x,
                                     subView.frame.origin.y,
                                     width,
                                     subView.frame.size.height)];
    }
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

- (void)removeSizeOptions
{
    [self.sizeClickableView removeFromSuperview];
    
    CGRect reviewFrame = self.reviewsClickableView.frame;
    reviewFrame.origin.y -= 44.0f;
    self.reviewsClickableView.frame = reviewFrame;
    
    CGRect buttonFrame = self.specificationsClickableView.frame;
    buttonFrame.origin.y -= 44.0f;
    self.specificationsClickableView.frame = buttonFrame;
    
    CGRect frame = self.frame;
    frame.size.height -= 44.0f;
    
    self.frame = frame;
}

- (void)setNumberOfStars:(NSInteger)stars
{
    switch (stars) {
        case 0: {
            
            self.star1.image = [self getEmptyStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 1: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 2: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 3: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 4: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getFilledStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 5: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getFilledStar];
            self.star5.image = [self getFilledStar];
            
        }
            break;
            
        default: {
            
            self.star1.image = [self getEmptyStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
    }
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
