//
//  JAAddressCell.m
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddressCell.h"
#import "JAClickableView.h"
#import "RIAddress.h"

@interface JAAddressCell ()

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation JAAddressCell

-(void)loadWithAddress:(RIAddress*)address
{
    self.backgroundColor = UIColorFromRGB(0xffffff);
    
    self.clickableView.translatesAutoresizingMaskIntoConstraints = YES;
    self.clickableView.frame = self.bounds;
    
    NSString *addressText = @"";
    
    if(VALID_NOTEMPTY(address.firstName, NSString) && VALID_NOTEMPTY(address.lastName, NSString))
    {
        addressText = [NSString stringWithFormat:@"%@ %@", address.firstName, address.lastName];
    }
    else if(VALID_NOTEMPTY(address.firstName, NSString))
    {
        addressText = address.firstName;
    }
    else if(VALID_NOTEMPTY(address.lastName, NSString))
    {
        addressText = address.lastName;
    }
    
    if(VALID_NOTEMPTY(address.address, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.address];
        }
        else
        {
            addressText = address.address;
        }
    }
    
    if(VALID_NOTEMPTY(address.address2, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.address2];
        }
        else
        {
            addressText = address.address2;
        }
    }
    
    if(VALID_NOTEMPTY(address.city, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.city];
        }
        else
        {
            addressText = address.city;
        }
    }
    
    if(VALID_NOTEMPTY(address.postcode, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.postcode];
        }
        else
        {
            addressText = address.postcode;
        }
    }
    
    if(VALID_NOTEMPTY(address.phone, NSString))
    {
        if(VALID_NOTEMPTY(addressText, NSString))
        {
            addressText = [NSString stringWithFormat:@"%@\n%@",addressText, address.phone];
        }
        else
        {
            addressText = address.phone;
        }
    }
    
    self.separator.translatesAutoresizingMaskIntoConstraints = YES;
    self.separator.frame = CGRectMake(0.0f, 99.0f, self.frame.size.width, 1.0f);
    
    self.editAddressButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.editAddressButton.frame = CGRectMake(self.frame.size.width - self.editAddressButton.frame.size.width,
                                              100.0f - self.editAddressButton.frame.size.height,
                                              self.editAddressButton.frame.size.width,
                                              self.editAddressButton.frame.size.height);
    
    self.checkMark.translatesAutoresizingMaskIntoConstraints = YES;
    self.checkMark.frame = CGRectMake(self.frame.size.width - self.checkMark.frame.size.width - 14.0f,
                                      (100.0f - self.checkMark.frame.size.height) / 2,
                                      self.checkMark.frame.size.width,
                                      self.checkMark.frame.size.height);
    [self.checkMark setHidden:YES];
    
    self.addressLabel.textAlignment = NSTextAlignmentLeft;
    self.addressLabel.frame = CGRectMake(17.0f,
                                         6.0f,
                                         self.frame.size.width - self.editAddressButton.frame.size.width - 30.0f,
                                         100.0f - 12.0f);
    [self.addressLabel setText:addressText];
    
    if (RI_IS_RTL) {
        [self.clickableView flipAllSubviews];
        self.editAddressButton.frame = CGRectMake(0.0f,
                                                  self.editAddressButton.frame.origin.y,
                                                  self.editAddressButton.frame.size.width,
                                                  self.editAddressButton.frame.size.height);
    }
}

-(void)selectAddress
{
    [self.checkMark setHidden:NO];
}

-(void)deselectAddress
{
    [self.checkMark setHidden:YES];
}

@end
