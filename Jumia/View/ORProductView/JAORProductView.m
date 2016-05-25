//
//  JAORProductView.m
//  Jumia
//
//  Created by telmopinto on 17/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORProductView.h"
#import "UIImageView+WebCache.h"

@interface JAORProductView ()

@property (nonatomic, strong) UILabel *quantityLabel;

@end

@implementation JAORProductView

- (void)setupWithItemCollection:(RIItemCollection*)itemCollection
                          order:(RITrackOrder*)order;
{
    CGFloat currentY = 10.0f;
    
    CGSize imageSize = CGSizeMake(68.0f, 85.0f);
    
    //details inside itemCell
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f,
                                                                           currentY,
                                                                           imageSize.width,
                                                                           imageSize.height)];
    
    [imageView setImageWithURL:[NSURL URLWithString:itemCollection.imageURL]
              placeholderImage:[UIImage imageNamed:@"placeholder_list"]];
    [self addSubview:imageView];
    
    UILabel* brandLabel = [UILabel new];
    brandLabel.font = JABodyFont;
    brandLabel.textColor = JABlack800Color;
    brandLabel.textAlignment = NSTextAlignmentLeft;
    brandLabel.text = itemCollection.brand;
    [brandLabel sizeToFit];
    brandLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                  currentY,
                                  self.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                  brandLabel.frame.size.height);
    [self addSubview:brandLabel];
    
    currentY = CGRectGetMaxY(brandLabel.frame);
    
    UILabel* nameLabel = [UILabel new];
    nameLabel.font = JAHEADLINEFont;
    nameLabel.textColor = JABlackColor;
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.text = itemCollection.name;
    [nameLabel sizeToFit];
    nameLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                 currentY,
                                 self.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                 nameLabel.frame.size.height);
    [self addSubview:nameLabel];
    
    currentY = CGRectGetMaxY(nameLabel.frame);
    
    self.quantityLabel = [UILabel new];
    self.quantityLabel.font = JABodyFont;
    self.quantityLabel.textColor = JABlack800Color;
    self.quantityLabel.textAlignment = NSTextAlignmentLeft;
    self.quantityLabel.text = [NSString stringWithFormat:STRING_QUANTITY, [itemCollection.quantity stringValue]];
    [self.quantityLabel sizeToFit];
    self.quantityLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                     currentY,
                                     self.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                     self.quantityLabel.frame.size.height);
    [self addSubview:self.quantityLabel];
    
    currentY = CGRectGetMaxY(self.quantityLabel.frame);
    
    UILabel* orderNumberLabel = [UILabel new];
    orderNumberLabel.font = JABodyFont;
    orderNumberLabel.textColor = JABlackColor;
    orderNumberLabel.text = [NSString stringWithFormat:STRING_ORDER_NO, order.orderId];
    orderNumberLabel.textAlignment = NSTextAlignmentLeft;
    [orderNumberLabel sizeToFit];
    orderNumberLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 6.0f,
                                        currentY,
                                        self.frame.size.width - CGRectGetMaxX(imageView.frame) + 6.0f - 16.0f,
                                        orderNumberLabel.frame.size.height);
    [self addSubview:orderNumberLabel];
    
    currentY = CGRectGetMaxY(orderNumberLabel.frame) + 20.0f;
    
    currentY = MAX(currentY, imageView.frame.size.height + 20.0f);

    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            currentY);
}

- (void)setQtyToReturn:(NSString *)qtyToReturn
{
    _qtyToReturn = qtyToReturn;
    [self.quantityLabel setText:[NSString stringWithFormat:STRING_QUANTITY, qtyToReturn]];
}

@end