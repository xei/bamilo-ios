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
#import "RISeller.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoSingleLine.h"
#import "JAProductInfoSubLine.h"
#import "JAProductInfoPriceLine.h"
#import "JAProductInfoRatingLine.h"
#import "RISpecification.h"
#import "RISpecificationAttribute.h"
#import "JAPDVProductInfoSellerInfo.h"

@interface JAPDVProductInfo() {
    UILabel *_sizesLabel;
}

@property (nonatomic, strong) RIProduct* product;
@property (nonatomic) id variationsTarget;
@property (nonatomic) id sizeTarget;
@property (nonatomic) id reviewsTarget;
@property (nonatomic) id sellerReviewsTarget;
@property (nonatomic) id otherOffersTarget;
@property (nonatomic) id specificationsTarget;
@property (nonatomic) id descriptionTarget;
@property (nonatomic) SEL variationsSelector;
@property (nonatomic) SEL sizeSelector;
@property (nonatomic) SEL reviewsSelector;
@property (nonatomic) SEL sellerReviewsSelector;
@property (nonatomic) SEL otherOffersSelector;
@property (nonatomic) SEL specificationsSelector;
@property (nonatomic) SEL descriptionSelector;

@end

@implementation JAPDVProductInfo

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize
{
    [self setFrame:frame];
    
    BOOL isiPadInLandscape = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            isiPadInLandscape = YES;
        }
    }
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    [separator setBackgroundColor:[UIColor grayColor]];
    if (!isiPadInLandscape) {
        [self addSubview:separator];
    }
    
    CGFloat yOffset = 0;
    
    /*
     *  PRICE
     */
    
    JAProductInfoPriceLine *priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
    [priceLine setFashion:product.fashion];
    [priceLine setTitle:product.priceFormatted];
    if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString)) {
        [priceLine setOldPrice:product.priceFormatted];
        [priceLine setTitle:product.specialPriceFormatted];
    }
    if (VALID_NOTEMPTY(product.maxSavingPercentage, NSString)) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:product.maxSavingPercentage];
        [priceLine setPriceOff:myNumber.integerValue];
    }
    [self addSubview:priceLine];
    yOffset = CGRectGetMaxY(priceLine.frame);
    
    /*
     *  RATINGS
     */
    
    JAProductInfoRatingLine *ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
    [ratingLine setFashion:product.fashion];
    [ratingLine setTopSeparatorVisibility:YES];
    [ratingLine setRatingAverage:product.avr];
    [ratingLine setRatingSum:product.sum];
    [ratingLine addTarget:self action:@selector(tapReviewsLine) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ratingLine];
    yOffset = CGRectGetMaxY(ratingLine.frame);
    
    /*
     *  SPECIFICATIONS
     */
    
    if (VALID_NOTEMPTY(product.specifications, NSSet) && !product.fashion) {
        JAProductInfoHeaderLine *headerSpecifications = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
        [headerSpecifications setTitle:[STRING_SPECIFICATIONS uppercaseString]];
        
        [self addSubview:headerSpecifications];
        yOffset = CGRectGetMaxY(headerSpecifications.frame) + 16.f;
        
        BOOL needMoreSpecifications = NO;
        for (RISpecification *specification in product.specifications) {
            int i = 0;
            for (RISpecificationAttribute *attribute in specification.specificationAttributes) {
                if (!VALID_NOTEMPTY(attribute.key, NSString) || !VALID_NOTEMPTY(attribute.value, NSString) || [(NSString *)attribute.value isEqualToString:@""]) {
                    continue;
                }
                i++;
                if (i==5) {
                    needMoreSpecifications = YES;
                    UILabel *retLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, yOffset, frame.size.width - 32, 0)];
                    [retLabel setTextColor:JABlackColor];
                    [retLabel setFont:JACaptionFont];
                    retLabel.numberOfLines = 0;
                    [retLabel setText:[NSString stringWithFormat:@"..."]];
                    [retLabel sizeToFit];
                    [self addSubview:retLabel];
                    yOffset = CGRectGetMaxY(retLabel.frame);
                    break;
                }
                UILabel *specificationsContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, yOffset, frame.size.width - 32, 0)];
                [specificationsContentLabel setTextColor:JABlackColor];
                [specificationsContentLabel setFont:JACaptionFont];
                specificationsContentLabel.numberOfLines = 0;
                [specificationsContentLabel setText:[NSString stringWithFormat:@"%@:\n %@", attribute.key, attribute.value]];
                [specificationsContentLabel sizeToFit];
                [self addSubview:specificationsContentLabel];
                yOffset = CGRectGetMaxY(specificationsContentLabel.frame);
            }
        }
        yOffset += 16.f;
        if (needMoreSpecifications) {
            JAProductInfoSubLine *subSpecificationReadMore = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
            [subSpecificationReadMore setTopSeparatorVisibility:YES];
#warning TODO String
            [subSpecificationReadMore setTitle:@"More specifications"];
            [subSpecificationReadMore addTarget:self action:@selector(tapSpecificationsLine) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:subSpecificationReadMore];
            yOffset = CGRectGetMaxY(subSpecificationReadMore.frame);
        }
    }
    
    /*
     *  SIZES
     */
    
    if (VALID_NOTEMPTY(product.productSimples, NSOrderedSet) && product.productSimples.count > 1)
    {
        NSString *sizesText = @"";
        int i = 0;
        for (RIProductSimple *simple in product.productSimples) {
            sizesText = i==0?[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, simple.variation]:[NSString stringWithFormat:@"%@, %@", sizesText, simple.variation];
            i++;
        }
        JAProductInfoSingleLine *singleSizes = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
        [singleSizes setTopSeparatorVisibility:YES];
        [singleSizes setTitle:sizesText];
        _sizesLabel = singleSizes.label;
        [singleSizes addTarget:self action:@selector(tapSizeLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:singleSizes];
        yOffset = CGRectGetMaxY(singleSizes.frame);
    }
    
    /*
     *  VARIATIONS
     */
    
    if (VALID_NOTEMPTY(product.variations, NSOrderedSet)) {
        JAProductInfoSingleLine *singleVariations = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
        [singleVariations setTopSeparatorVisibility:YES];
        if (product.fashion) {
#warning TODO String
            [singleVariations setTitle:@"See other colors"];
        }else{
#warning TODO String
            [singleVariations setTitle:@"See other variations"];
        }
        [singleVariations addTarget:self action:@selector(tapVariationsLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:singleVariations];
        yOffset = CGRectGetMaxY(singleVariations.frame);
    }
    
    /*
     *  SELLER
     */
    
    if (VALID_NOTEMPTY(product.seller, RISeller)) {
        JAProductInfoHeaderLine *headerSeller = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
#warning TODO String translation
        [headerSeller setTitle:[@"Seller Information" uppercaseString]];
        [self addSubview:headerSeller];
        yOffset = CGRectGetMaxY(headerSeller.frame) + 16.f;
        
        JAPDVProductInfoSellerInfo *sellerInfoView = [[JAPDVProductInfoSellerInfo alloc] initWithFrame:CGRectMake(16, yOffset, self.width-32, 50)];
        [sellerInfoView setSeller:product.seller];
        [sellerInfoView addTarget:self action:@selector(tapSellerReviewsLine)];
        [self addSubview:sellerInfoView];
        
        yOffset = CGRectGetMaxY(sellerInfoView.frame);
    }
    
    /*
     *  OTHER OFFERS
     */
    
    if (VALID_NOTEMPTY(product.offersTotal, NSNumber) && product.offersTotal.integerValue > 0) {
        JAProductInfoSubLine *otherOffers = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSubLineHeight)];
#warning TODO String
        [otherOffers setTitle:[NSString stringWithFormat:@"Other sellers starting from: %@", product.offersMinPriceFormatted]];
        [otherOffers.label setYCenterAligned];
        [otherOffers setTopSeparatorVisibility:YES];
        [otherOffers setBottomSeparatorVisibility:NO];
        [otherOffers addTarget:self action:@selector(tapOffersLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:otherOffers];
        
        yOffset = CGRectGetMaxY(otherOffers.frame);
    }
    
    /*
     *  DESCRIPTION
     */
    
    if (VALID_NOTEMPTY(product.summary, NSString)) {
        JAProductInfoHeaderLine *headerDescription = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
        [headerDescription setTitle:[STRING_DESCRIPTION uppercaseString]];
        [self addSubview:headerDescription];
        yOffset = CGRectGetMaxY(headerDescription.frame) + 16.f;
        
        UILabel *descriptionContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, yOffset, frame.size.width - 32, 0)];
        [descriptionContentLabel setTextColor:JABlackColor];
        [descriptionContentLabel setFont:JACaptionFont];
        descriptionContentLabel.numberOfLines = 5;
        [descriptionContentLabel setText:product.summary];
        [descriptionContentLabel sizeToFit];
        [self addSubview:descriptionContentLabel];
        yOffset = CGRectGetMaxY(descriptionContentLabel.frame) + 16.f;
        
        JAProductInfoSubLine *singleDescriptionReadMore = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
        [singleDescriptionReadMore setTopSeparatorVisibility:YES];
#warning TODO String
        [singleDescriptionReadMore setTitle:@"Read more"];
        [singleDescriptionReadMore addTarget:self action:@selector(tapDescriptionLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:singleDescriptionReadMore];
        yOffset = CGRectGetMaxY(singleDescriptionReadMore.frame);
    }
    
    [self setHeight:yOffset];
}

- (void)setSizesText:(NSString *)sizesText
{
    _sizesText = sizesText;
    if (VALID_NOTEMPTY(_sizesLabel, UILabel)) {
        [_sizesLabel setText:sizesText];
        [_sizesLabel sizeToFit];
    }
}

- (int)lineCountForText:(UILabel *)label
{
    UIFont *font = label.font;
    
    CGRect rect = label.frame;
    
    return ceil(rect.size.height / font.lineHeight);
}

- (void)tapVariationsLine
{
    if (self.variationsTarget && [self.variationsTarget respondsToSelector:self.variationsSelector]) {
        ((void (*)(id, SEL))[self.variationsTarget methodForSelector:self.variationsSelector])(self.variationsTarget, self.variationsSelector);
    }
}

- (void)tapSizeLine
{
    if (self.sizeTarget && [self.sizeTarget respondsToSelector:self.sizeSelector]) {
        ((void (*)(id, SEL))[self.sizeTarget methodForSelector:self.sizeSelector])(self.sizeTarget, self.sizeSelector);
    }
}

- (void)tapReviewsLine
{
    if (self.reviewsTarget && [self.reviewsTarget respondsToSelector:self.reviewsSelector]) {
        ((void (*)(id, SEL))[self.reviewsTarget methodForSelector:self.reviewsSelector])(self.reviewsTarget, self.reviewsSelector);
    }
}

- (void)tapSellerReviewsLine
{
    if (self.sellerReviewsTarget && [self.sellerReviewsTarget respondsToSelector:self.sellerReviewsSelector]) {
        ((void (*)(id, SEL))[self.sellerReviewsTarget methodForSelector:self.sellerReviewsSelector])(self.sellerReviewsTarget, self.sellerReviewsSelector);
    }
}

- (void)tapOffersLine
{
    if (self.otherOffersTarget && [self.otherOffersTarget respondsToSelector:self.otherOffersSelector]) {
        ((void (*)(id, SEL))[self.otherOffersTarget methodForSelector:self.otherOffersSelector])(self.otherOffersTarget, self.otherOffersSelector);
    }
}

- (void)tapSpecificationsLine
{
    if (self.specificationsTarget && [self.specificationsTarget respondsToSelector:self.specificationsSelector]) {
        ((void (*)(id, SEL))[self.specificationsTarget methodForSelector:self.specificationsSelector])(self.specificationsTarget, self.specificationsSelector);
    }
}

- (void)tapDescriptionLine
{
    if (self.descriptionTarget && [self.descriptionTarget respondsToSelector:self.descriptionSelector]) {
        ((void (*)(id, SEL))[self.descriptionTarget methodForSelector:self.descriptionSelector])(self.descriptionTarget, self.descriptionSelector);
    }
}

- (void)addVariationsTarget:(id)target action:(SEL)action
{
    self.variationsTarget = target;
    self.variationsSelector = action;
}

- (void)addSizeTarget:(id)target action:(SEL)action
{
    self.sizeTarget = target;
    self.sizeSelector = action;
}

- (void)addReviewsTarget:(id)target action:(SEL)action
{
    self.reviewsTarget = target;
    self.reviewsSelector = action;
}

- (void)addSellerReviewsTarget:(id)target action:(SEL)action
{
    self.sellerReviewsTarget = target;
    self.sellerReviewsSelector = action;
}

- (void)addOtherOffersTarget:(id)target action:(SEL)action
{
    self.otherOffersTarget = target;
    self.otherOffersSelector = action;
}

- (void)addSpecificationsTarget:(id)target action:(SEL)action
{
    self.specificationsTarget = target;
    self.specificationsSelector = action;
}

- (void)addDescriptionTarget:(id)target action:(SEL)action
{
    self.descriptionTarget = target;
    self.descriptionSelector = action;
}

@end
