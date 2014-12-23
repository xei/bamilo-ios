//
//  JAMyOrderCell.m
//  Jumia
//
//  Created by plopes on 22/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#define kJAMyOrderCellHeight 44.0f

#import "JAMyOrderCell.h"

@interface JAMyOrderCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *landscapeArrowImageView;

@end

@implementation JAMyOrderCell

- (void)awakeFromNib
{
    // Initialization code
    self.clickableView.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self.dateLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.orderNumberLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.priceLabel setTextColor:UIColorFromRGB(0x666666)];
    
    [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
}

- (void)setupWithOrder:(RITrackOrder*)order isInLandscape:(BOOL)isInLandscape
{
    if(isInLandscape)
    {
        [self.portraitArrowImageView setHidden:YES];
        [self.landscapeArrowImageView setHidden:NO];
    }
    else
    {
        [self.landscapeArrowImageView setHidden:YES];
        [self.portraitArrowImageView setHidden:NO];
    }
    
    [self.clickableView setFrame:CGRectMake(0.0f,
                                            0.0f,
                                            self.frame.size.width,
                                            kJAMyOrderCellHeight)];
    
    [self.dateLabel setText:order.creationDate];
    [self.priceLabel setText:order.totalFormatted];
    
    NSDictionary* baseAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"HelveticaNeue-Light" size:13], NSFontAttributeName,
                                         UIColorFromRGB(0x666666), NSForegroundColorAttributeName, nil];    NSString* orderNumberString = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_NUMBER, order.orderId];
    NSRange orderNumberLabelRange = [orderNumberString rangeOfString:STRING_ORDER_NUMBER];
    NSDictionary* highlightAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"HelveticaNeue" size:13], NSFontAttributeName,
                                         UIColorFromRGB(0x666666), NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString* finalString = [[NSMutableAttributedString alloc] initWithString:orderNumberString attributes:baseAttributes];
    [finalString setAttributes:highlightAttributes range:orderNumberLabelRange];
    
    [self.orderNumberLabel setAttributedText:finalString];
}

+ (CGFloat)getCellHeight
{
    return kJAMyOrderCellHeight;
}

@end
