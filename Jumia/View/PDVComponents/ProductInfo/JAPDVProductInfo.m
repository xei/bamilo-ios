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
#import "JAProductInfoSubLine.h"
#import "JAProductInfoPriceLine.h"
#import "JAProductInfoRatingLine.h"
#import "RISpecification.h"
#import "RISpecificationAttribute.h"
#import "JAPDVProductInfoSellerInfo.h"
#import "JAProductInfoSISLine.h"
#import "JAProductInfoSizeLine.h"

@interface JAPDVProductInfo() {
    UILabel *_sizesLabel;
    JAProductInfoPriceLine *_priceLine;
    JAProductInfoBaseLine *_priceBackgroundLine;
    CGFloat _sellerYPosition;
}

@property (nonatomic, strong) RIProduct* product;
@property (nonatomic) id variationsTarget;
@property (nonatomic) id sizeTarget;
@property (nonatomic) id reviewsTarget;
@property (nonatomic) id sellerCatalogTarget;
@property (nonatomic) id sellerLinkTarget;
@property (nonatomic) id sellerReviewsTarget;
@property (nonatomic) id otherOffersTarget;
@property (nonatomic) id specificationsTarget;
@property (nonatomic) id descriptionTarget;
@property (nonatomic) id sisTarget;
@property (nonatomic) SEL variationsSelector;
@property (nonatomic) SEL sizeSelector;
@property (nonatomic) SEL reviewsSelector;
@property (nonatomic) SEL sellerCatalogSelector;
@property (nonatomic) SEL sellerLinkSelector;
@property (nonatomic) SEL sellerReviewsSelector;
@property (nonatomic) SEL otherOffersSelector;
@property (nonatomic) SEL specificationsSelector;
@property (nonatomic) SEL descriptionSelector;
@property (nonatomic) SEL sisSelector;

@end

@implementation JAPDVProductInfo

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize
{
    [self setFrame:frame];
    
    if (product == nil) {
        return;
    }
    
    BOOL isiPadInLandscape = NO;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            isiPadInLandscape = YES;
        }
    }
    
    CGFloat yOffset = 0;
    
    /*
     *  PRICE
     */
    CGFloat priceBackgroundLineHeight = kProductInfoSingleLineHeight + 1.0f;
    if (product.freeShippingPossible) {
        priceBackgroundLineHeight += 20.0f;
    }
    _priceBackgroundLine = [[JAProductInfoBaseLine alloc] initWithFrame:CGRectMake(0.0f, yOffset, frame.size.width, priceBackgroundLineHeight)];
    if (!isiPadInLandscape) {
        [_priceBackgroundLine setTopSeparatorVisibility:YES];
    }
    [self addSubview:_priceBackgroundLine];
    
    _priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(0.0f, 1.0f, frame.size.width, kProductInfoSingleLineHeight)];

    if (VALID_NOTEMPTY(product.priceRange, NSString)) {
        [_priceLine setPrice:product.priceRange];
    } else {
        [self setSpecialPrice:product.specialPriceFormatted andPrice:product.priceFormatted andMaxSavingPercentage:product.maxSavingPercentage shouldForceFlip:NO];
    }
    [_priceBackgroundLine addSubview:_priceLine];

    if (product.freeShippingPossible) {
        
        UIImage* freeShippingImage = [UIImage imageNamed:@"freeShipping"];
        UIImageView* freeShippingImageView = [[UIImageView alloc] initWithImage:freeShippingImage];
        [_priceBackgroundLine addSubview:freeShippingImageView];
        [freeShippingImageView setFrame:CGRectMake(17.0f,
                                                   CGRectGetMaxY(_priceLine.frame) - 6.0f,
                                                   freeShippingImage.size.width,
                                                   freeShippingImage.size.height)];
        
        
        UILabel* freeShippingLabel = [UILabel new];
        [freeShippingLabel setFont:JACaptionItalicFont];
        [freeShippingLabel setTextColor:JABlack800Color];
        [freeShippingLabel setText:STRING_FREE_SHIPPING_POSSIBLE];
        [freeShippingLabel sizeToFit];
        
        [_priceBackgroundLine addSubview:freeShippingLabel];
        [freeShippingLabel setFrame:CGRectMake(CGRectGetMaxX(freeShippingImageView.frame) + 4.0f,
                                               freeShippingImageView.frame.origin.y,
                                               freeShippingLabel.frame.size.width,
                                               freeShippingLabel.frame.size.height)];
        
    }
    
    yOffset = CGRectGetMaxY(_priceBackgroundLine.frame);
    
    /*
     *  RATINGS
     */
    
    JAProductInfoRatingLine *ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
    [ratingLine setTopSeparatorVisibility:YES];
    [ratingLine setBottomSeparatorVisibility:NO];
    [ratingLine setImageRatingSize:kImageRatingSizeBig];
    [ratingLine setRatingAverage:product.avr];
    [ratingLine setRatingSum:product.sum shortVersion:NO];
    [ratingLine addTarget:self action:@selector(tapReviewsLine) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ratingLine];
    
    yOffset = CGRectGetMaxY(ratingLine.frame);
    
    /*
     *  SPECIFICATIONS
     */
    
    CGFloat preSpecificationOffset = yOffset;
    if (VALID_NOTEMPTY(product.specifications, NSOrderedSet)) {
        JAProductInfoHeaderLine *headerSpecifications = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
        [headerSpecifications setTitle:[STRING_SPECIFICATIONS uppercaseString]];
        
        [self addSubview:headerSpecifications];
        yOffset = CGRectGetMaxY(headerSpecifications.frame) + 16.f;
        
        int i = 0;
        BOOL needMoreSpecifications = NO;
        for (RISpecification *specification in product.specifications) {
            for (RISpecificationAttribute *attribute in specification.specificationAttributes) {
                if (!VALID_NOTEMPTY(attribute.key, NSString) || !VALID_NOTEMPTY(attribute.value, NSString) || [(NSString *)attribute.value isEqualToString:@""]) {
                    continue;
                }
                i++;
                if (i==5) {
                    needMoreSpecifications = YES;
                    UILabel *retLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, yOffset, frame.size.width - 32, 0)];
                    [retLabel setTextColor:JABlackColor];
                    [retLabel setFont:JABodyFont];
                    retLabel.numberOfLines = 0;
                    [retLabel setText:[NSString stringWithFormat:@"..."]];
                    [retLabel sizeToFit];
                    [self addSubview:retLabel];
                    yOffset = CGRectGetMaxY(retLabel.frame);
                    break;
                }
                UILabel *specificationsContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, yOffset, frame.size.width - 32, 0)];
                [specificationsContentLabel setTextColor:JABlackColor];
                [specificationsContentLabel setFont:JABodyFont];
                specificationsContentLabel.numberOfLines = 0;
                [specificationsContentLabel setText:[NSString stringWithFormat:@"- %@: %@", attribute.key, attribute.value]];
                [specificationsContentLabel sizeToFit];
                [self addSubview:specificationsContentLabel];
                yOffset = CGRectGetMaxY(specificationsContentLabel.frame);
            }
            
            if (i==5)
                break;
        }
        yOffset += 16.f;
        
        if (i == 0) {
            [headerSpecifications removeFromSuperview];
            yOffset = preSpecificationOffset;
        }else{
            if (needMoreSpecifications) {
                JAProductInfoSubLine *subSpecificationReadMore = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
                [subSpecificationReadMore setTopSeparatorVisibility:YES];
                [subSpecificationReadMore setTitle:STRING_READ_MORE];
                [subSpecificationReadMore addTarget:self action:@selector(tapSpecificationsLine) forControlEvents:UIControlEventTouchUpInside];
                [subSpecificationReadMore.label setTextColor:JABlue1Color];
                [self addSubview:subSpecificationReadMore];
                yOffset = CGRectGetMaxY(subSpecificationReadMore.frame);
            }
        }
    }
    
    /*
     *  SIZES
     */
    
    if (VALID_NOTEMPTY(product.productSimples, NSArray) && product.productSimples.count > 1)
    {
        NSString *sizesText = @"";
        if (VALID_NOTEMPTY(preSelectedSize, NSString)) {
            sizesText = [NSString stringWithFormat:STRING_SIZE_WITH_VALUE, preSelectedSize];
        } else {
            int i = 0;
            for (RIProductSimple *simple in product.productSimples) {
                sizesText = i==0?[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, simple.variation]:[NSString stringWithFormat:@"%@, %@", sizesText, simple.variation];
                i++;
            }
        }
        JAProductInfoSizeLine *singleSizes = [[JAProductInfoSizeLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
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
    
    if (VALID_NOTEMPTY(product.variations, NSArray)) {
        JAProductInfoSubLine *singleVariations = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSubLineHeight)];
        [singleVariations setTopSeparatorVisibility:YES];
        if (product.fashion) {
            [singleVariations setTitle:STRING_SEE_OTHER_COLORS];
        }else{
            [singleVariations setTitle:STRING_SEE_OTHER_VARIATIONS];
        }
        [singleVariations addTarget:self action:@selector(tapVariationsLine) forControlEvents:UIControlEventTouchUpInside];
        [singleVariations.label setTextColor:JABlue1Color];
        [self addSubview:singleVariations];
        yOffset = CGRectGetMaxY(singleVariations.frame);
    }
    
    /*
     *  SIS
     */
    
    if (VALID_NOTEMPTY(product.brandTarget, NSString)) {
        JAProductInfoSISLine *sis = [[JAProductInfoSISLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSISLineHeight)];
        [sis setTitle:[NSString stringWithFormat:STRING_VISIT_THE_OFFICIAL_BRAND_STORE, product.brand]];
        if (product.brandImage) {
            NSString* sisImageUrl = product.brandImage;
            
            __weak JAProductInfoSISLine *weakSis = sis;
            [sis.sisImageView setImageWithURL:[NSURL URLWithString:sisImageUrl] placeholderImage:nil success:^(UIImage *image, BOOL cached) {
                [weakSis.sisImageView setWidth:image.size.width*weakSis.sisImageView.height/image.size.height];
                weakSis.lineContentXOffset = CGRectGetMaxX(weakSis.sisImageView.frame) + 8.f;
                [weakSis setTitle:weakSis.title];
            } failure:nil];
        }
        
        [sis addTarget:self action:@selector(tapSisLine) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sis];
        yOffset = CGRectGetMaxY(sis.frame);
    }
    
    /*
     *  SELLER
     */
    
    if (VALID_NOTEMPTY(product.seller, RISeller)) {
        _sellerYPosition = yOffset;
        JAProductInfoHeaderLine *headerSeller = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoHeaderLineHeight)];
        [headerSeller setTitle:[STRING_SELLER_INFORMATION uppercaseString]];
        [self addSubview:headerSeller];
        yOffset = CGRectGetMaxY(headerSeller.frame);
        
        JAPDVProductInfoSellerInfo *sellerInfoView = [[JAPDVProductInfoSellerInfo alloc] initWithFrame:CGRectMake(0, yOffset, self.width, 50)];
        [sellerInfoView setIsShopFirst:product.shopFirst];
        [sellerInfoView setShopFirstOverlayText:product.shopFirstOverlayText];
        [sellerInfoView setSeller:product.seller];
        [self addTargetToSellerInfoView:sellerInfoView seller:product.seller];

        [self addSubview:sellerInfoView];
        yOffset = CGRectGetMaxY(sellerInfoView.frame);
    }
    
    /*
     *  OTHER OFFERS
     */
    
    if (VALID_NOTEMPTY(product.offersTotal, NSNumber) && product.offersTotal.integerValue > 0) {
        JAProductInfoSubLine *otherOffers = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSubLineHeight)];
        [otherOffers setTopSeparatorVisibility:YES];
        [otherOffers setTitle:[NSString stringWithFormat:STRING_OTHER_SELLERS_STARTING_FROM, product.offersMinPriceFormatted]];
        [otherOffers.label setYCenterAligned];
        [otherOffers addTarget:self action:@selector(tapOffersLine) forControlEvents:UIControlEventTouchUpInside];
        [otherOffers.label setTextColor:JABlue1Color];
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
        [descriptionContentLabel setFont:JABodyFont];
        descriptionContentLabel.numberOfLines = 5;
        [descriptionContentLabel setText:product.summary];
        [descriptionContentLabel sizeToFit];
        [self addSubview:descriptionContentLabel];
        yOffset = CGRectGetMaxY(descriptionContentLabel.frame) + 16.f;
        
        JAProductInfoSubLine *singleDescriptionReadMore = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, yOffset, frame.size.width, kProductInfoSingleLineHeight)];
        [singleDescriptionReadMore setTopSeparatorVisibility:YES];
        [singleDescriptionReadMore setTitle:STRING_READ_MORE];
        [singleDescriptionReadMore addTarget:self action:@selector(tapDescriptionLine) forControlEvents:UIControlEventTouchUpInside];
        [singleDescriptionReadMore.label setTextColor:JABlue1Color];
        [self addSubview:singleDescriptionReadMore];
        yOffset = CGRectGetMaxY(singleDescriptionReadMore.frame);
    }
    
    [self setHeight:yOffset];
}

- (void)addTargetToSellerInfoView:(JAPDVProductInfoSellerInfo *)sellerInfoView seller:(RISeller*)seller
{
    if (VALID_NOTEMPTY(seller.targetString, NSString)) {
        [sellerInfoView addTarget:self action:@selector(tapSellerCatalogLine)];
        [sellerInfoView addLinkTarget:self action:@selector(tapSellerLink)];
    }
}


- (void)setSizesText:(NSString *)sizesText
{
    _sizesText = sizesText;
    if (VALID_NOTEMPTY(_sizesLabel, UILabel)) {
        [_sizesLabel setText:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, sizesText]];
    }
}

- (void)setSpecialPrice:(NSString*)special andPrice:(NSString*)price andMaxSavingPercentage:(NSString*)maxSavingPercentage shouldForceFlip:(BOOL)forceFlip
{
    [_priceLine setPrice:price];
    
    if (VALID_NOTEMPTY(special, NSString)) {
        [_priceLine setOldPrice:price];
        [_priceLine setPrice:special];
    } else {
        [_priceLine setOldPrice:@""];
    }
    if (VALID_NOTEMPTY(maxSavingPercentage, NSString)) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:maxSavingPercentage];
        [_priceLine setPriceOff:myNumber.integerValue];
    }
    
    if (RI_IS_RTL) {
        if (forceFlip) {
            [_priceLine flipAllSubviews];
        }
    }
}

- (CGFloat)getSellerInfoYPosition
{
    return _sellerYPosition;
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

- (void)tapSellerCatalogLine
{
    if (self.sellerCatalogTarget && [self.sellerCatalogTarget respondsToSelector:self.sellerCatalogSelector]) {
        ((void (*)(id, SEL))[self.sellerCatalogTarget methodForSelector:self.sellerCatalogSelector])(self.sellerCatalogTarget, self.sellerCatalogSelector);
    }
}

- (void)tapSellerLink
{
    if (self.sellerLinkTarget && [self.sellerLinkTarget respondsToSelector:self.sellerLinkSelector]) {
        ((void (*)(id, SEL))[self.sellerLinkTarget methodForSelector:self.sellerLinkSelector])(self.sellerLinkTarget, self.sellerLinkSelector);
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

- (void)tapSisLine
{
    if (self.sisTarget && [self.sisTarget respondsToSelector:self.sisSelector]) {
        ((void (*)(id, SEL))[self.sisTarget methodForSelector:self.sisSelector])(self.sisTarget, self.sisSelector);
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

- (void)addSellerCatalogTarget:(id)target action:(SEL)action
{
    self.sellerCatalogTarget = target;
    self.sellerCatalogSelector = action;
}

- (void)addSellerLinkTarget:(id)target action:(SEL)action
{
    self.sellerLinkTarget = target;
    self.sellerLinkSelector = action;
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

- (void)addSisTarget:(id)target action:(SEL)action
{
    self.sisTarget = target;
    self.sisSelector = action;
}

@end
