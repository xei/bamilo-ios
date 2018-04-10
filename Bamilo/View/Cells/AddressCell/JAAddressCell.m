////
////  JAAddressCell.m
////  Jumia
////
////  Created by Pedro Lopes on 04/09/14.
////  Copyright (c) 2014 Rocket Internet. All rights reserved.
////
//
//#import "JAAddressCell.h"
//#import "JAClickableView.h"
//#import "RIAddress.h"
//
//@interface JAAddressCell ()
//
//@property (nonatomic, strong) UILabel* nameLabel;
//@property (strong, nonatomic) UILabel *addressLabel;
//@property (nonatomic, strong) UIImageView* phoneImageView;
//@property (nonatomic, strong) UILabel* phoneLabel;
//@property (nonatomic, strong) UILabel* invalidLabel;
//@property (strong, nonatomic) UIView *separator;
//
//@end
//
//@implementation JAAddressCell
//
//- (UIButton*)editAddressButton
//{
//    if (!_editAddressButton) {
//        _editAddressButton = [UIButton new];
//        UIImage* image = [UIImage imageNamed:@"editAddress"];
//        [_editAddressButton setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
//        [_editAddressButton setImage:image forState:UIControlStateNormal];
//    }
//    return _editAddressButton;
//}
//
//- (UILabel*)nameLabel
//{
//    if (!_nameLabel) {
//        _nameLabel = [UILabel new];
//        [_nameLabel setFont:JAListFont];
//        [_nameLabel setTextColor:JABlackColor];
//    }
//    return _nameLabel;
//}
//
//-(UILabel*)addressLabel
//{
//    if (!_addressLabel) {
//        _addressLabel = [UILabel new];
//        [_addressLabel setFont:JABodyFont];
//        [_addressLabel setTextColor:JABlack800Color];
//    }
//    return _addressLabel;
//}
//
//- (UIImageView*)phoneImageView
//{
//    if (!_phoneImageView) {
//        UIImage* phoneImage = [UIImage imageNamed:@"phone_icon_small"];
//        _phoneImageView = [[UIImageView alloc] initWithImage:phoneImage];
//        [_phoneImageView setFrame:CGRectMake(0.0f, 0.0f, phoneImage.size.width, phoneImage.size.height)];
//    }
//    return _phoneImageView;
//}
//
//- (UILabel*)phoneLabel
//{
//    if (!_phoneLabel) {
//        _phoneLabel = [UILabel new];
//        [_phoneLabel setFont:JABodyFont];
//        [_phoneLabel setTextColor:JABlack800Color];
//    }
//    return _phoneLabel;
//}
//
//- (UILabel*)invalidLabel
//{
//    if (!_invalidLabel) {
//        _invalidLabel = [UILabel new];
//        [_invalidLabel setFont:JACaptionFont];
//        [_invalidLabel setTextColor:JARed1Color];
//    }
//    return _invalidLabel;
//}
//
//- (UIView*)separator
//{
//    if (!_separator) {
//        _separator = [UIView new];
//        [_separator setBackgroundColor:JABlack300Color];
//    }
//    return _separator;
//}
//
//-(void)loadWithWidth:(CGFloat)width
//             address:(RIAddress*)address
//{
//    self.frame = CGRectMake(0.0f, 0.0f, width, kAddressCellHeight);
//    
//    self.backgroundColor = JAWhiteColor;
//    
//    NSString* nameText = @"";
//    
//    if(VALID_NOTEMPTY(address.firstName, NSString) && VALID_NOTEMPTY(address.lastName, NSString)) {
//        nameText = [NSString stringWithFormat:@"%@ %@", address.firstName, address.lastName];
//    }
//    else if(VALID_NOTEMPTY(address.firstName, NSString)) {
//        nameText = address.firstName;
//    }
//    else if(VALID_NOTEMPTY(address.lastName, NSString)) {
//        nameText = address.lastName;
//    }
//    
//    self.nameLabel.textAlignment = NSTextAlignmentLeft;
//    [self.nameLabel setText:nameText];
//    [self.nameLabel sizeToFit];
//    [self.nameLabel setFrame:CGRectMake(16.0f,
//                                        10.0f,
//                                        self.frame.size.width - 16.0f - self.editAddressButton.frame.size.width,
//                                        self.nameLabel.frame.size.height)];
//    [self addSubview:self.nameLabel];
//    
//    NSString *addressText = @"";
//    
//    if(VALID_NOTEMPTY(address.address, NSString)) {
//        if(VALID_NOTEMPTY(addressText, NSString)) {
//            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.address];
//        } else {
//            addressText = address.address;
//        }
//    }
//    
//    if(VALID_NOTEMPTY(address.address2, NSString)) {
//        if(VALID_NOTEMPTY(addressText, NSString)) {
//            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.address2];
//        } else {
//            addressText = address.address2;
//        }
//    }
//    
//    if(VALID_NOTEMPTY(address.city, NSString)) {
//        if(VALID_NOTEMPTY(addressText, NSString)) {
//            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.city];
//        } else {
//            addressText = address.city;
//        }
//    }
//    
//    if(VALID_NOTEMPTY(address.postcode, NSString)) {
//        if(VALID_NOTEMPTY(addressText, NSString)) {
//            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.postcode];
//        } else {
//            addressText = address.postcode;
//        }
//    }
//    
//    [self.addressLabel setText:addressText];
//    [self.addressLabel sizeToFit];
//    [self.addressLabel setFrame:CGRectMake(16.0f,
//                                           CGRectGetMaxY(self.nameLabel.frame) + 4.0f,
//                                           self.frame.size.width - 16.0f - self.editAddressButton.frame.size.width,
//                                           self.addressLabel.frame.size.height)];
//    self.addressLabel.textAlignment = NSTextAlignmentLeft;
//    [self addSubview:self.addressLabel];
//    
//    self.editAddressButton.frame = CGRectMake(self.frame.size.width - self.editAddressButton.frame.size.width - 16.0f,
//                                              self.nameLabel.frame.origin.y + 4.0f,
//                                              self.editAddressButton.frame.size.width,
//                                              self.editAddressButton.frame.size.height);
//    [self addSubview:self.editAddressButton];
//    
//    
//    [self.phoneImageView setFrame:CGRectMake(16.0f + 1.0f,
//                                             CGRectGetMaxY(self.addressLabel.frame) + 4.0f,
//                                             self.phoneImageView.frame.size.width,
//                                             self.phoneImageView.frame.size.height)];
//    [self addSubview:self.phoneImageView];
//    
//    self.phoneLabel.textAlignment = NSTextAlignmentLeft;
//    [self.phoneLabel setText:address.phone];
//    [self.phoneLabel sizeToFit];
//    [self.phoneLabel setFrame:CGRectMake(CGRectGetMaxX(self.phoneImageView.frame) + 4.0f,
//                                         self.phoneImageView.frame.origin.y,
//                                         self.frame.size.width - CGRectGetMaxX(self.phoneImageView.frame),
//                                         self.phoneLabel.frame.size.height)];
//    [self addSubview:self.phoneLabel];
//    
//    self.invalidLabel.textAlignment = NSTextAlignmentLeft;
//    if ([address.isDefaultShipping isEqualToString:@"1"] || [address.isDefaultShipping isEqualToString:@"1"]) {
//        [self.invalidLabel setText:STRING_INVALID_ADDRESS_BILLING_SHIPPING];
//    } else {
//        [self.invalidLabel setText:STRING_INVALID_ADDRESS_OTHER];
//    }
//    [self.invalidLabel sizeToFit];
//    [self.invalidLabel setFrame:CGRectMake(16.0f,
//                                           CGRectGetMaxY(self.phoneLabel.frame) + 4.0f,
//                                           self.frame.size.width - 16.0f - self.editAddressButton.frame.size.width,
//                                           self.invalidLabel.frame.size.height)];
//    [self addSubview:self.invalidLabel];
//    if (VALID_NOTEMPTY(address.isValid, NSString) && [address.isValid isEqualToString:@"1"]) {
//        self.invalidLabel.hidden = YES;
//    } else {
//        self.invalidLabel.hidden = NO;
//    }
//    
//    self.separator.frame = CGRectMake(0.0f, kAddressCellHeight - 1.0f, self.frame.size.width, 1.0f);
//    [self addSubview:self.separator];
//    
//    if (RI_IS_RTL) {
//        [self flipAllSubviews];
//    }
//}
//
//@end
