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

@interface JAPDVProductInfo()

@property (nonatomic, strong) RIProduct* product;
@property (nonatomic) id variationsTarget;
@property (nonatomic) id sizeTarget;
@property (nonatomic) id reviewsTarget;
@property (nonatomic) id sellerReviewsTarget;
@property (nonatomic) id otherOffersTarget;
@property (nonatomic) id specificationsTarget;
@property (nonatomic) SEL variationsSelector;
@property (nonatomic) SEL sizeSelector;
@property (nonatomic) SEL reviewsSelector;
@property (nonatomic) SEL sellerReviewsSelector;
@property (nonatomic) SEL otherOffersSelector;
@property (nonatomic) SEL specificationsSelector;

@end

@implementation JAPDVProductInfo

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize
{
    [self setFrame:frame];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 1)];
    [separator setBackgroundColor:[UIColor grayColor]];
    [self addSubview:separator];
    
    CGFloat yOffset = 0;
    
    
    JAProductInfoPriceLine *priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
    [priceLine.label setText:product.priceFormatted];
    if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString)) {
        [priceLine setOldPrice:product.priceFormatted];
        [priceLine.label setText:product.specialPriceFormatted];
    }
    if (VALID_NOTEMPTY(product.maxSavingPercentage, NSString)) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:product.maxSavingPercentage];
        [priceLine setPriceOff:myNumber.integerValue];
    }
    [self addSubview:priceLine];
    yOffset = CGRectGetMaxY(priceLine.frame);
    
    JAProductInfoRatingLine *ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
    [ratingLine setTopSeparatorVisibility:YES];
    [ratingLine setRatingAverage:product.avr];
    [ratingLine setRatingSum:product.sum];
    [ratingLine addTarget:self action:@selector(tapReviewsLine) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ratingLine];
    yOffset = CGRectGetMaxY(ratingLine.frame);
    
    
    if (VALID_NOTEMPTY(product.seller, RISeller)) {
        
        JAProductInfoHeaderLine *headerSeller = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
#warning TODO String translation
        [headerSeller.label setText:[@"Seller Information" uppercaseString]];
        [headerSeller.label sizeToFit];
        [self addSubview:headerSeller];
        yOffset = CGRectGetMaxY(headerSeller.frame) + 16.f;
        
        JAPDVProductInfoSellerInfo *sellerInfoView = [[JAPDVProductInfoSellerInfo alloc] initWithFrame:CGRectMake(16, yOffset, self.width-32, 50)];
        [sellerInfoView setSeller:product.seller];
        [sellerInfoView addTarget:self action:@selector(tapSellerReviewsLine)];
        [self addSubview:sellerInfoView];
        
        yOffset = CGRectGetMaxY(sellerInfoView.frame);
    }
    
    if (VALID_NOTEMPTY(product.offersTotal, NSNumber) && product.offersTotal.integerValue > 0) {
        JAProductInfoSubLine *otherOffers = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSubLineHeight)];
#warning TODO String
        [otherOffers.label setText:[NSString stringWithFormat:@"Other sellers starting from: %@", product.offersMinPriceFormatted]];
        [otherOffers.label sizeToFit];
        [otherOffers.label setYCenterAligned];
        [otherOffers setTopSeparatorVisibility:YES];
        [otherOffers setBottomSeparatorVisibility:NO];
        [otherOffers addTarget:self action:@selector(tapOffersLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:otherOffers];
        
        yOffset = CGRectGetMaxY(otherOffers.frame);
    }
    
    if (VALID_NOTEMPTY(product.specifications, NSSet)) {
        JAProductInfoHeaderLine *headerSpecifications = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
        [headerSpecifications.label setText:[STRING_SPECIFICATIONS uppercaseString]];
        [headerSpecifications.label sizeToFit];
        [self addSubview:headerSpecifications];
        yOffset = CGRectGetMaxY(headerSpecifications.frame) + 16.f;
        
        BOOL needMoreSpecifications = NO;
        for (RISpecification *specification in product.specifications) {
            if ([specification.headLabel isEqualToString:@"details"]) {
                int i = 0;
                for (RISpecificationAttribute *attribute in specification.specificationAttributes) {
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
        }
        yOffset += 16.f;
        if (needMoreSpecifications) {
            JAProductInfoSubLine *subSpecificationReadMore = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
            [subSpecificationReadMore setTopSeparatorVisibility:YES];
#warning TODO String
            [subSpecificationReadMore.label setText:@"More specifications"];
            [subSpecificationReadMore addTarget:self action:@selector(tapSpecificationsLine) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:subSpecificationReadMore];
            yOffset = CGRectGetMaxY(subSpecificationReadMore.frame);
        }
    }
    
    if (VALID_NOTEMPTY(product.variations, NSOrderedSet)) {
        JAProductInfoSingleLine *singleVariations = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
        [singleVariations setTopSeparatorVisibility:YES];
#warning TODO String
        [singleVariations.label setText:@"See other variations"];
        [singleVariations.label sizeToFit];
        [singleVariations addTarget:self action:@selector(tapVariationsLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:singleVariations];
        yOffset = CGRectGetMaxY(singleVariations.frame);
    }
    
    if (VALID_NOTEMPTY(product.summary, NSString)) {
        JAProductInfoHeaderLine *headerDescription = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
        [headerDescription.label setText:[STRING_DESCRIPTION uppercaseString]];
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
        [singleDescriptionReadMore.label setText:@"Read more"];
        [singleDescriptionReadMore addTarget:self action:@selector(tapSpecificationsLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:singleDescriptionReadMore];
        yOffset = CGRectGetMaxY(singleDescriptionReadMore.frame);
    }
    
    [self setHeight:yOffset];
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

@end
