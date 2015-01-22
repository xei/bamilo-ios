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
    self.layer.cornerRadius = 5.0f;
    
    CGFloat width = frame.size.width - 6.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    
    [self.otherOffersLabel setTextColor:UIColorFromRGB(0x666666)];

    self.titleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    [self.titleLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x,
                                         self.titleLabel.frame.origin.y,
                                         width,
                                         self.titleLabel.frame.size.height)];
    self.titleLabel.text = STRING_SAME_PRODUCT_FROM_OTHER_SELLERS;

    self.titleSeparator.translatesAutoresizingMaskIntoConstraints = YES;
    [self.titleSeparator setFrame:CGRectMake(self.titleSeparator.frame.origin.x,
                                             self.titleSeparator.frame.origin.y,
                                             width,
                                             self.titleSeparator.frame.size.height)];
    
    self.otherOffersClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.otherOffersClickableView setFrame:CGRectMake(self.otherOffersClickableView.frame.origin.x,
                                                       self.otherOffersClickableView.frame.origin.y,
                                                       width,
                                                       self.otherOffersClickableView.frame.size.height)];
    
    self.goToOtherOffersImageView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.goToOtherOffersImageView setFrame:CGRectMake(width - self.goToOtherOffersImageView.frame.size.width - 9.0f,
                                                       self.goToOtherOffersImageView.frame.origin.y,
                                                       self.goToOtherOffersImageView.frame.size.width,
                                                       self.goToOtherOffersImageView.frame.size.height)];
    
    /*
     Check if there are other offers
     */
    if (VALID_NOTEMPTY(product.offersTotal, NSNumber) && 0 < [product.offersTotal integerValue]) {
        
        self.otherOffersLabel.text = [NSString stringWithFormat:@"%@ (%d)", STRING_OTHER_SELLERS, [product.offersTotal integerValue]];
        
        self.fromLabel = [UILabel new];
        [self.fromLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.fromLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:9.0f]];
        self.fromLabel.text = [NSString stringWithFormat:@"%@ ", STRING_FROM];
        [self.fromLabel sizeToFit];
        [self.fromLabel setFrame:CGRectMake(self.otherOffersLabel.frame.origin.x,
                                            CGRectGetMaxY(self.otherOffersLabel.frame) - 2.0f,
                                            self.fromLabel.frame.size.width,
                                            self.fromLabel.frame.size.height)];
        [self.otherOffersClickableView addSubview:self.fromLabel];
        
        self.offerMinPriceLabel = [UILabel new];
        [self.offerMinPriceLabel setTextColor:UIColorFromRGB(0xcc0000)];
        [self.offerMinPriceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:9.0f]];
        self.offerMinPriceLabel.text = product.offersMinPriceFormatted;
        [self.offerMinPriceLabel sizeToFit];
        [self.offerMinPriceLabel setFrame:CGRectMake(CGRectGetMaxX(self.fromLabel.frame),
                                                     self.fromLabel.frame.origin.y,
                                                     self.offerMinPriceLabel.frame.size.width,
                                                     self.offerMinPriceLabel.frame.size.height)];
        [self.otherOffersClickableView addSubview:self.offerMinPriceLabel];
        
    }
}


@end
