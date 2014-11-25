//
//  JAOrderSummaryView.m
//  Jumia
//
//  Created by Telmo Pinto on 24/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAOrderSummaryView.h"
#import "RICartItem.h"

#define JAOrderSummaryViewTextMargin 6.0f

@interface JAOrderSummaryView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JAOrderSummaryView

- (void)loadWithCart:(RICart *)cart
{
    if (VALID_NOTEMPTY(cart, RICart) && VALID_NOTEMPTY(cart.cartItems, NSArray)) {
        
        CGFloat currentY = [self generalLoad];
        
        for (RICartItem* cartItem in cart.cartItems) {
            if (VALID_NOTEMPTY(cartItem, RICartItem)) {
                
                UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                               currentY,
                                                                               self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                               1.0f)];
                nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                nameLabel.textColor = UIColorFromRGB(0x4e4e4e);
                nameLabel.text = cartItem.name;
                nameLabel.numberOfLines = -1;
                [nameLabel sizeToFit];
                [self.scrollView addSubview:nameLabel];

                currentY += nameLabel.frame.size.height;
                
                UILabel* quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                                   currentY,
                                                                                   self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                                   1.0f)];
                quantityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                quantityLabel.textColor = UIColorFromRGB(0x4e4e4e);
                quantityLabel.numberOfLines = -1;
                NSString* priceString = cartItem.priceFormatted;
                if (VALID_NOTEMPTY(cartItem.specialPriceFormatted, NSString)) {
                    priceString = cartItem.specialPriceFormatted;
                }
                quantityLabel.text = [NSString stringWithFormat:@"%d x %@", [cartItem.quantity integerValue], priceString];
                [quantityLabel sizeToFit];
                [self.scrollView addSubview:quantityLabel];
                
                currentY += quantityLabel.frame.size.height;
            }
        }
        
        currentY += 15.0f;
        
        UILabel* VATLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                      currentY,
                                                                      self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                      1.0f)];
        VATLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        VATLabel.textColor = UIColorFromRGB(0x4e4e4e);
        VATLabel.text = STRING_VAT;
        [VATLabel sizeToFit];
        [self.scrollView addSubview:VATLabel];
        
        UILabel* VATValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                           currentY,
                                                                           self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                           VATLabel.frame.size.height)];
        VATValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        VATValueLabel.textColor = UIColorFromRGB(0x4e4e4e);
        VATValueLabel.text = cart.vatValueFormatted;
        VATValueLabel.textAlignment = NSTextAlignmentRight;
        [self.scrollView addSubview:VATValueLabel];
        
        currentY += VATLabel.frame.size.height + 7.0f;
        
        
        
        UILabel* subtotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                           currentY,
                                                                           self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                           1.0f)];
        subtotalLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        subtotalLabel.textColor = UIColorFromRGB(0x4e4e4e);
        subtotalLabel.text = STRING_SUBTOTAL;
        [subtotalLabel sizeToFit];
        [self.scrollView addSubview:subtotalLabel];
        
        UILabel* subtotalValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                                currentY,
                                                                                self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                                subtotalLabel.frame.size.height)];
        subtotalValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        subtotalValueLabel.textColor = UIColorFromRGB(0x4e4e4e);
        subtotalValueLabel.text = cart.cartValueFormatted;
        subtotalValueLabel.textAlignment = NSTextAlignmentRight;
        [self.scrollView addSubview:subtotalValueLabel];
        
        currentY += subtotalLabel.frame.size.height + 7.0f;
        
        
        
        UILabel* extraLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                        currentY,
                                                                        self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                        1.0f)];
        extraLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        extraLabel.textColor = UIColorFromRGB(0x4e4e4e);
        extraLabel.text = STRING_EXTRA_COSTS;
        [extraLabel sizeToFit];
        [self.scrollView addSubview:extraLabel];
        
        UILabel* extraValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(JAOrderSummaryViewTextMargin,
                                                                             currentY,
                                                                             self.scrollView.frame.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                             extraLabel.frame.size.height)];
        extraValueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        extraValueLabel.textColor = UIColorFromRGB(0x4e4e4e);
        extraValueLabel.text = cart.extraCostsFormatted;
        extraValueLabel.textAlignment = NSTextAlignmentRight;
        [self.scrollView addSubview:extraValueLabel];
        
        currentY += extraLabel.frame.size.height + 10.0f;
        
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 currentY);
        
        CGFloat readjustedHeight = MIN(self.scrollView.contentSize.height, self.frame.size.height);
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  readjustedHeight)];
        [self.scrollView setFrame:self.bounds];
    }
}

- (CGFloat)generalLoad
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5.0f;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:self.scrollView];
    
    CGFloat currentY = 0.0f;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x + JAOrderSummaryViewTextMargin,
                                                                    currentY,
                                                                    self.scrollView.bounds.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                    26.0f)];
    titleLabel.text = @"Order Summary";
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    titleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    [self.scrollView addSubview:titleLabel];
    
    currentY += titleLabel.frame.size.height;
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                                                self.scrollView.bounds.origin.y + titleLabel.frame.size.height,
                                                                self.scrollView.bounds.size.width,
                                                                1.0f)];
    lineView.backgroundColor = UIColorFromRGB(0xfaa41a);
    [self.scrollView addSubview:lineView];
    
    currentY += lineView.frame.size.height + 10.0f;
    
    UILabel* productsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.scrollView.bounds.origin.x + JAOrderSummaryViewTextMargin,
                                                                            currentY,
                                                                            self.scrollView.bounds.size.width - 2*JAOrderSummaryViewTextMargin,
                                                                            26.0f)];
    productsTitleLabel.text = STRING_PRODUCTS;
    productsTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
    productsTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    [self.scrollView addSubview:productsTitleLabel];
    
    currentY += productsTitleLabel.frame.size.height + 10.0f;
    
    return currentY;
}

@end
