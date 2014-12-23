//
//  JAMyOrderDetailView.m
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyOrderDetailView.h"

#define kNormalFont [UIFont fontWithName:@"HelveticaNeue-Light" size:13]
#define kHighlightedFont [UIFont fontWithName:@"HelveticaNeue" size:13]

@implementation JAMyOrderDetailView

- (void)setupWithOrder:(RITrackOrder*)order maxWidth:(CGFloat)maxWidth
{
    for(UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
    
    // add top margin
    CGFloat currentY = 10.0f;
    CGFloat horizontalMargin = 6.0f;
    maxWidth -= (horizontalMargin * 2);
    
    NSDictionary* baseAttributes = [NSDictionary dictionaryWithObjectsAndKeys:kNormalFont, NSFontAttributeName, nil];
    NSDictionary* highlightAttributes = [NSDictionary dictionaryWithObjectsAndKeys:kHighlightedFont,NSFontAttributeName, nil];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [dateLabel setNumberOfLines:0];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [dateLabel setFont:kNormalFont];
    [dateLabel setTextColor:UIColorFromRGB(0x666666)];
    
    NSString* orderDateString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_DATE, order.creationDate];
    NSRange orderDateLabelRange = [orderDateString rangeOfString:STRING_ORDER_DATE];
    NSMutableAttributedString* finalString = [[NSMutableAttributedString alloc] initWithString:orderDateString attributes:baseAttributes];
    [finalString setAttributes:highlightAttributes range:orderDateLabelRange];
    [dateLabel setAttributedText:finalString];
    
    CGRect dateLabelRect = [orderDateString boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
    [dateLabel setFrame:CGRectMake(horizontalMargin,
                                   currentY,
                                   maxWidth,
                                   ceilf(dateLabelRect.size.height))];
    [self addSubview:dateLabel];
    currentY += ceilf(dateLabelRect.size.height);
    
    UILabel *paymentMethodLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [paymentMethodLabel setNumberOfLines:0];
    [paymentMethodLabel setBackgroundColor:[UIColor clearColor]];
    [paymentMethodLabel setFont:kNormalFont];
    [paymentMethodLabel setTextColor:UIColorFromRGB(0x666666)];
    
    NSString* paymentMethodString = [NSString stringWithFormat:@"%@ %@", STRING_PAYMENT_METHOD, order.paymentMethod];
    NSRange paymentMethodLabelRange = [paymentMethodString rangeOfString:STRING_PAYMENT_METHOD];
    NSMutableAttributedString* paymentMethodFinalString = [[NSMutableAttributedString alloc] initWithString:paymentMethodString attributes:baseAttributes];
    [paymentMethodFinalString setAttributes:highlightAttributes range:paymentMethodLabelRange];
    [paymentMethodLabel setAttributedText:paymentMethodFinalString];
    
    CGRect paymentLabelRect = [paymentMethodString boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
    [paymentMethodLabel setFrame:CGRectMake(horizontalMargin,
                                            currentY,
                                            maxWidth,
                                            ceilf(paymentLabelRect.size.height))];
    [self addSubview:paymentMethodLabel];
    currentY += ceilf(paymentLabelRect.size.height);
    
    if(VALID_NOTEMPTY(order.paymentReference, NSString))
    {
        UILabel *paymentReferenceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [paymentReferenceLabel setNumberOfLines:0];
        [paymentReferenceLabel setBackgroundColor:[UIColor clearColor]];
        [paymentReferenceLabel setFont:kNormalFont];
        [paymentReferenceLabel setTextColor:UIColorFromRGB(0x666666)];
        
        NSString* paymentReferenceString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_PAYMENT_REFERENCE, order.paymentReference];
        NSRange paymentReferenceLabelRange = [paymentReferenceString rangeOfString:STRING_ORDER_PAYMENT_REFERENCE];
        NSMutableAttributedString* paymentReferenceFinalString = [[NSMutableAttributedString alloc] initWithString:paymentReferenceString attributes:baseAttributes];
        [paymentReferenceFinalString setAttributes:highlightAttributes range:paymentReferenceLabelRange];
        [paymentReferenceLabel setAttributedText:paymentReferenceFinalString];
        
        CGRect paymentReferenceLabelRect = [paymentReferenceString boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
        [paymentReferenceLabel setFrame:CGRectMake(horizontalMargin,
                                                   currentY,
                                                   maxWidth,
                                                   ceilf(paymentReferenceLabelRect.size.height))];
        [self addSubview:paymentReferenceLabel];
        currentY += ceilf(paymentReferenceLabelRect.size.height);
    }
    
    if(VALID_NOTEMPTY(order.paymentDescription, NSString))
    {
        UILabel *paymentStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [paymentStatusLabel setNumberOfLines:0];
        [paymentStatusLabel setBackgroundColor:[UIColor clearColor]];
        [paymentStatusLabel setFont:kNormalFont];
        [paymentStatusLabel setTextColor:UIColorFromRGB(0x666666)];
        
        NSString* paymentStatusString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_PAYMENT_STATUS, order.paymentDescription];
        NSRange paymentStatusLabelRange = [paymentStatusString rangeOfString:STRING_ORDER_PAYMENT_STATUS];
        NSMutableAttributedString* paymentStatusFinalString = [[NSMutableAttributedString alloc] initWithString:paymentStatusString attributes:baseAttributes];
        [paymentStatusFinalString setAttributes:highlightAttributes range:paymentStatusLabelRange];
        [paymentStatusLabel setAttributedText:paymentStatusFinalString];
        
        CGRect paymentStatusLabelRect = [paymentStatusString boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
        [paymentStatusLabel setFrame:CGRectMake(horizontalMargin,
                                                currentY,
                                                maxWidth,
                                                ceilf(paymentStatusLabelRect.size.height))];
        [self addSubview:paymentStatusLabel];
        currentY += ceilf(paymentStatusLabelRect.size.height);
    }
    
    currentY += 20.0f;
    
    if(VALID_NOTEMPTY(order.itemCollection, NSArray))
    {
        UILabel *productsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [productsLabel setNumberOfLines:0];
        [productsLabel setBackgroundColor:[UIColor clearColor]];
        [productsLabel setFont:kHighlightedFont];
        [productsLabel setTextColor:UIColorFromRGB(0x666666)];
        [productsLabel setText:STRING_PRODUCTS];
        
        CGRect productsLabelRect = [STRING_PRODUCTS boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
        [productsLabel setFrame:CGRectMake(horizontalMargin,
                                           currentY,
                                           maxWidth,
                                           ceilf(productsLabelRect.size.height))];
        [self addSubview:productsLabel];
        currentY += ceilf(productsLabelRect.size.height);
        
        currentY += 20.0f;
        
        for(int i = 0; i < [order.itemCollection count]; i++)
        {
            RIItemCollection *product = [order.itemCollection objectAtIndex:i];
            
            UILabel *productNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [productNameLabel setNumberOfLines:0];
            [productNameLabel setBackgroundColor:[UIColor clearColor]];
            [productNameLabel setFont:kNormalFont];
            [productNameLabel setTextColor:UIColorFromRGB(0x666666)];
            [productNameLabel setText:product.name];
            
            CGRect productNameLabelRect = [product.name boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:kNormalFont} context:nil];
            [productNameLabel setFrame:CGRectMake(horizontalMargin,
                                                  currentY,
                                                  maxWidth,
                                                  ceilf(productNameLabelRect.size.height))];
            [self addSubview:productNameLabel];
            currentY += ceilf(productNameLabelRect.size.height);
            
            UILabel *productQuantityLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [productQuantityLabel setNumberOfLines:0];
            [productQuantityLabel setBackgroundColor:[UIColor clearColor]];
            [productQuantityLabel setFont:kHighlightedFont];
            [productQuantityLabel setTextColor:UIColorFromRGB(0x666666)];
            
            NSString *quantityString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_QUANTITY, [product.quantity stringValue]];
            [productQuantityLabel setText:quantityString];
            
            CGRect productQuantityLabelRect = [quantityString boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
            [productQuantityLabel setFrame:CGRectMake(horizontalMargin,
                                                      currentY,
                                                      maxWidth,
                                                      ceilf(productQuantityLabelRect.size.height))];
            [self addSubview:productQuantityLabel];
            currentY += ceilf(productQuantityLabelRect.size.height);
            
            UILabel *productPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [productPriceLabel setNumberOfLines:0];
            [productPriceLabel setBackgroundColor:[UIColor clearColor]];
            [productPriceLabel setFont:kNormalFont];
            [productPriceLabel setTextColor:UIColorFromRGB(0x666666)];
            [productPriceLabel setText:product.totalFormatted];
            
            CGRect productPriceLabelRect = [product.totalFormatted boundingRectWithSize:CGSizeMake(maxWidth, 1000.0f)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName:kNormalFont} context:nil];
            [productPriceLabel setFrame:CGRectMake(horizontalMargin,
                                                   currentY,
                                                   maxWidth,
                                                   ceilf(productPriceLabelRect.size.height))];
            [self addSubview:productPriceLabel];
            currentY += ceilf(productPriceLabelRect.size.height);
            
            // If it is the last product than it shouldn't have separator
            if(i < ([order.itemCollection count] - 1))
            {
                // Space betweeen separator and last product
                currentY += 10.0f;
                
                // Separator
                UIView *productSeparator = [[UIView alloc] initWithFrame:CGRectMake(horizontalMargin,
                                                                                    currentY,
                                                                                    maxWidth,
                                                                                    1.0f)];
                [productSeparator setBackgroundColor:UIColorFromRGB(0xcccccc)];
                [self addSubview:productSeparator];
                currentY += productSeparator.frame.size.height;
                
                // Space betweeen separator and next product
                currentY += 10.0f;
            }
        }
        
        // Space betweeen list of products and cell separator
        currentY += 10.0f;
    }
}

+ (CGFloat)getOrderDetailViewHeight:(RITrackOrder*)order maxWidth:(CGFloat)maxWidth
{
    // add top margin
    CGFloat currentY = 10.0f;
    CGFloat horizontalMargin = 6.0f;
    
    NSString* orderDateString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_DATE, order.creationDate];
    CGRect dateLabelRect = [orderDateString boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
    
    currentY += ceilf(dateLabelRect.size.height);
    
    NSString* paymentMethodString = [NSString stringWithFormat:@"%@ %@", STRING_PAYMENT_METHOD, order.paymentMethod];
    CGRect paymentMethodLabelRect = [paymentMethodString boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                   attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
    currentY += ceilf(paymentMethodLabelRect.size.height);
    
    if(VALID_NOTEMPTY(order.paymentReference, NSString))
    {
        NSString* paymentReferenceString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_PAYMENT_REFERENCE, order.paymentReference];
        CGRect paymentReferenceLabelRect = [paymentReferenceString boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
        currentY += ceilf(paymentReferenceLabelRect.size.height);
    }
    
    if(VALID_NOTEMPTY(order.paymentDescription, NSString))
    {
        NSString* paymentStatusString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_PAYMENT_STATUS, order.paymentDescription];
        CGRect paymentStatusLabelRect = [paymentStatusString boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                                       attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
        currentY += ceilf(paymentStatusLabelRect.size.height);
    }
    
    currentY += 20.0f;
    
    if(VALID_NOTEMPTY(order.itemCollection, NSArray))
    {
        CGRect productsLabelRect = [STRING_PRODUCTS boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
        currentY += ceilf(productsLabelRect.size.height);
        
        currentY += 20.0f;
        
        for(int i = 0; i < [order.itemCollection count]; i++)
        {
            RIItemCollection *product = [order.itemCollection objectAtIndex:i];
            
            CGRect productNameLabelRect = [product.name boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                                  attributes:@{NSFontAttributeName:kNormalFont} context:nil];
            currentY += ceilf(productNameLabelRect.size.height);
            
            NSString *quantityString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_QUANTITY, [product.quantity stringValue]];
            CGRect productQuantityLabelRect = [quantityString boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                                        attributes:@{NSFontAttributeName:kHighlightedFont} context:nil];
            currentY += ceilf(productQuantityLabelRect.size.height);
            
            CGRect productPriceLabelRect = [product.totalFormatted boundingRectWithSize:CGSizeMake(maxWidth - horizontalMargin * 2, 1000.0f)
                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                             attributes:@{NSFontAttributeName:kNormalFont} context:nil];
            currentY += ceilf(productPriceLabelRect.size.height);
            
            if(i < ([order.itemCollection count] - 1))
            {
                // Space betweeen separator and last product
                currentY += 10.0f;

                // Separator
                currentY += 1.0f;
                
                // Space betweeen separator and next product
                currentY += 10.0f;
            }
        }
        
        // Space betweeen list of products and cell separator
        currentY += 10.0f;
    }
    
    return currentY;
}

@end
