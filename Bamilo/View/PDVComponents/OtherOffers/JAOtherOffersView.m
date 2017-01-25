//
//  JAOtherOffersView.m
//  Jumia
//
//  Created by Telmo Pinto on 22/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAOtherOffersView.h"
#import "JAClickableView.h"

@interface JAOtherOffersView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleSeparator;
@property (weak, nonatomic) IBOutlet JAClickableView *otherOffersClickableView;
@property (weak, nonatomic) IBOutlet UILabel *otherOffersLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goToOtherOffersImageView;
@property (nonatomic, strong)UILabel* fromLabel;
@property (nonatomic, strong)UILabel* offerMinPriceLabel;

@property (nonatomic, strong)RIProduct* product;

@end

@implementation JAOtherOffersView

+ (JAOtherOffersView *)getNewOtherOffersView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAOtherOffersView_Landscape~iPad"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAOtherOffersView class]]) {
            JAOtherOffersView *object = (JAOtherOffersView *)obj;
            return object;
        }
    }
    
    return nil;
}

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product
{
    self.product = product;
    
    self.layer.cornerRadius = 5.0f;
    
    CGFloat width = frame.size.width - 6.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    
    [self.otherOffersLabel setTextColor:JAGreyColor];

    [self.titleLabel setX:6.f];
    self.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.titleLabel.font.pointSize];
    [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x,
                                         self.titleLabel.frame.origin.y,
                                         width,
                                         self.titleLabel.frame.size.height)];
    self.titleLabel.text = STRING_SAME_PRODUCT_FROM_OTHER_SELLERS;
    [self.titleLabel sizeToFit];

    [self.titleSeparator setFrame:CGRectMake(self.titleSeparator.frame.origin.x,
                                             self.titleSeparator.frame.origin.y,
                                             width,
                                             self.titleSeparator.frame.size.height)];
    
    [self.otherOffersClickableView setFrame:CGRectMake(self.otherOffersClickableView.frame.origin.x,
                                                       self.otherOffersClickableView.frame.origin.y,
                                                       width,
                                                       self.otherOffersClickableView.frame.size.height)];
    
    [self.goToOtherOffersImageView setFrame:CGRectMake(width - self.goToOtherOffersImageView.frame.size.width - 9.0f,
                                                       self.goToOtherOffersImageView.frame.origin.y,
                                                       self.goToOtherOffersImageView.frame.size.width,
                                                       self.goToOtherOffersImageView.frame.size.height)];
    
    [self.goToOtherOffersImageView setX:RI_IS_RTL?9.f:self.width - self.goToOtherOffersImageView.frame.size.width - 9.0f];
    /*
     Check if there are other offers
     */
    self.otherOffersLabel.font = [UIFont fontWithName:kFontRegularName size:self.otherOffersLabel.font.pointSize];
    if (VALID_NOTEMPTY(product.offersTotal, NSNumber) && 0 < [product.offersTotal integerValue]) {
        
        [self.otherOffersLabel setX:6.f];
        self.otherOffersLabel.text = [NSString stringWithFormat:@"%@ (%ld)", STRING_OTHER_SELLERS, [product.offersTotal longValue]];
        if (RI_IS_RTL) {
            self.otherOffersLabel.text = [NSString stringWithFormat:@"(%ld) %@", [product.offersTotal longValue], STRING_OTHER_SELLERS];
        }
        
        [self.otherOffersClickableView addTarget:self action:@selector(pressedOtherOffers) forControlEvents:UIControlEventTouchUpInside];
        
        self.fromLabel = [UILabel new];
        [self.fromLabel setTextColor:JAGreyColor];
        [self.fromLabel setFont:JAOtherOffersFromLabel];
        self.fromLabel.text = [NSString stringWithFormat:@"%@ ", STRING_FROM];
        [self.fromLabel sizeToFit];
        [self.fromLabel setFrame:CGRectMake(self.otherOffersLabel.frame.origin.x,
                                            CGRectGetMaxY(self.otherOffersLabel.frame) - 2.0f,
                                            self.fromLabel.frame.size.width,
                                            self.fromLabel.frame.size.height)];
        [self.otherOffersClickableView addSubview:self.fromLabel];
        
        self.offerMinPriceLabel = [UILabel new];
        [self.offerMinPriceLabel setTextColor:JARed1Color];
        [self.offerMinPriceLabel setFont:JAOtherOffersMinPriceLabel];
        self.offerMinPriceLabel.text = product.offersMinPriceFormatted;
        [self.offerMinPriceLabel sizeToFit];
        [self.offerMinPriceLabel setFrame:CGRectMake(CGRectGetMaxX(self.fromLabel.frame),
                                                     self.fromLabel.frame.origin.y,
                                                     self.offerMinPriceLabel.frame.size.width,
                                                     self.offerMinPriceLabel.frame.size.height)];
        [self.otherOffersClickableView addSubview:self.offerMinPriceLabel];
        
    }
    
    if (RI_IS_RTL) {
        [self.goToOtherOffersImageView flipViewImage];
        [self.goToOtherOffersImageView flipViewPositionInsideSuperview];
    }
}

- (void)pressedOtherOffers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenOtherOffers object:self.product];
}


@end
