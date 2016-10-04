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

@property (nonatomic, strong) UILabel* nameLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (nonatomic, strong) UILabel* phoneTitleLabel;
@property (nonatomic, strong) UILabel* phoneLabel;
@property (nonatomic, strong) UILabel* invalidLabel;
@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) UIView *verticalSeparator;
@property (strong, nonatomic) UIView *horizontalSeparator;

@end

@implementation JAAddressCell

- (UIButton*)editAddressButton
{
    if (!_editAddressButton) {
        _editAddressButton = [UIButton new];
        UIImage* image = [UIImage imageNamed:@"editAddress"];
        [_editAddressButton setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
        [_editAddressButton setImage:image forState:UIControlStateNormal];
    }
    return _editAddressButton;
}

- (UIButton*)deleteAddressButton
{
    if (!_deleteAddressButton) {
        _deleteAddressButton = [UIButton new];
        UIImage* image = [UIImage imageNamed:@"deleteAddress"];
        [_deleteAddressButton setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
        [_deleteAddressButton setImage:image forState:UIControlStateNormal];
    }
    return _deleteAddressButton;
}

- (UIButton*)radioButton
{
    if (!_radioButton) {
        _radioButton = [UIButton new];
        UIImage* image = [UIImage imageNamed:@"editAddress"];
        [_radioButton setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
        [_radioButton setImage:image forState:UIControlStateNormal];
    }
    return _radioButton;
}

- (UILabel*)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        [_nameLabel setFont:JAListFont];
        [_nameLabel setTextColor:JABlackColor];
    }
    return _nameLabel;
}

-(UILabel*)addressLabel
{
    if (!_addressLabel) {
        _addressLabel = [UILabel new];
        [_addressLabel setFont:JABodyFont];
        [_addressLabel setTextColor:JABlack800Color];
    }
    return _addressLabel;
}

- (UILabel*)phoneTitleLabel
{
    if (!_phoneTitleLabel) {
        //        UIImage* phoneImage = [UIImage imageNamed:@"phone_icon_small"];
        _phoneTitleLabel = [UILabel new];
        [_phoneTitleLabel setText:@"تلفن :"];
        [_phoneTitleLabel setFont:JAListFont];
        [_phoneTitleLabel setTextColor:JABlack800Color];
    }
    return _phoneTitleLabel;
}

- (UILabel*)phoneLabel
{
    if (!_phoneLabel) {
        _phoneLabel = [UILabel new];
        [_phoneLabel setFont:JABodyFont];
        [_phoneLabel setTextColor:JABlack800Color];
    }
    return _phoneLabel;
}

- (UILabel*)invalidLabel
{
    if (!_invalidLabel) {
        _invalidLabel = [UILabel new];
        [_invalidLabel setFont:JACaptionFont];
        [_invalidLabel setTextColor:JARed1Color];
    }
    return _invalidLabel;
}

- (UIView*)verticalSeparator
{
    if (!_verticalSeparator) {
        _verticalSeparator = [UIView new];
        [_verticalSeparator setBackgroundColor:[UIColor colorWithWhite:0.94 alpha:1.0]];
    }
    return _verticalSeparator;
}

- (UIView*)horizontalSeparator
{
    if (!_horizontalSeparator) {
        _horizontalSeparator = [UIView new];
        [_horizontalSeparator setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    }
    return _horizontalSeparator;
}

- (UIView*)separator
{
    if (!_separator) {
        _separator = [UIView new];
        [_separator setBackgroundColor:[UIColor colorWithWhite:0.85 alpha:1.0]];
    }
    return _separator;
}

-(void)loadWithWidth:(CGFloat)width
             address:(RIAddress*)address
{
    self.frame = CGRectMake(0.0f, 0.0f, width, kAddressCellHeight);
    
    self.backgroundColor = JAWhiteColor;
    
    NSString* nameText = @"";
    
    if(VALID_NOTEMPTY(address.firstName, NSString) && VALID_NOTEMPTY(address.lastName, NSString)) {
        nameText = [NSString stringWithFormat:@"%@ %@", address.firstName, address.lastName];
    }
    else if(VALID_NOTEMPTY(address.firstName, NSString)) {
        nameText = address.firstName;
    }
    else if(VALID_NOTEMPTY(address.lastName, NSString)) {
        nameText = address.lastName;
    }
    
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self.nameLabel setText:nameText];
    [self.nameLabel sizeToFit];
    if(!self.fromCheckOut){
        [self.nameLabel setFrame:CGRectMake(16.0f,
                                            10.0f,
                                            self.frame.size.width - 16.0f - self.editAddressButton.frame.size.width,
                                            self.nameLabel.frame.size.height)];
    }
    else{
        [self.nameLabel setFrame:CGRectMake(30.0f,
                                            10.0f,
                                            self.frame.size.width - 30.0f - self.editAddressButton.frame.size.width,
                                            self.nameLabel.frame.size.height)];
    }
    [self addSubview:self.nameLabel];
    
    NSString *addressText = @"";
    
    if(VALID_NOTEMPTY(address.address, NSString)) {
        if(VALID_NOTEMPTY(addressText, NSString)) {
            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.address];
        } else {
            addressText = address.address;
        }
    }
    
    if(VALID_NOTEMPTY(address.address2, NSString)) {
        if(VALID_NOTEMPTY(addressText, NSString)) {
            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.address2];
        } else {
            addressText = address.address2;
        }
    }
    
    if(VALID_NOTEMPTY(address.city, NSString)) {
        if(VALID_NOTEMPTY(addressText, NSString)) {
            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.city];
        } else {
            addressText = address.city;
        }
    }
    
    if(VALID_NOTEMPTY(address.postcode, NSString)) {
        if(VALID_NOTEMPTY(addressText, NSString)) {
            addressText = [NSString stringWithFormat:@"%@ %@",addressText, address.postcode];
        } else {
            addressText = address.postcode;
        }
    }
    
    [self.addressLabel setText:addressText];
    self.addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.addressLabel.numberOfLines = 0;
    [self.addressLabel sizeToFit];
    if(!self.fromCheckOut){
        [self.addressLabel setFrame:CGRectMake(16.0f,
                                               CGRectGetMaxY(self.nameLabel.frame) + 4.0f,
                                               self.frame.size.width - 16.0f - self.editAddressButton.frame.size.width - 25,
                                               [self getLabelHeight:self.addressLabel])];
        
    }
    else{
        [self.addressLabel setFrame:CGRectMake(30.0f,
                                               CGRectGetMaxY(self.nameLabel.frame) + 4.0f,
                                               self.frame.size.width - 30.0f - self.editAddressButton.frame.size.width - 25,
                                               [self getLabelHeight:self.addressLabel])];
    }
    CGSize maximumLabelSize = CGSizeMake(296, 500);
    
    CGSize expectedLabelSize = [addressText sizeWithFont:self.addressLabel.font constrainedToSize:maximumLabelSize lineBreakMode:self.addressLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = self.addressLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    self.addressLabel.frame = newFrame;
    
    self.addressLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.addressLabel];
    
    self.editAddressButton.frame = CGRectMake(self.frame.size.width - self.editAddressButton.frame.size.width - 16.0f,
                                              self.nameLabel.frame.origin.y + 4.0f,
                                              self.editAddressButton.frame.size.width,
                                              self.editAddressButton.frame.size.height);
    [self addSubview:self.editAddressButton];
    self.radioButton.frame = CGRectMake(16.0f,
                                        self.frame.size.height/2,
                                        24.0f,
                                        24.0f);
    self.radioButton.center = CGPointMake(self.radioButton.frame.origin.x, self.center.y);
    [self addSubview:self.radioButton];
    
    [self.phoneTitleLabel sizeToFit];
    
    if(!self.fromCheckOut){
        [self.phoneTitleLabel setFrame:CGRectMake(16.0f + 1.0f,
                                                  CGRectGetMaxY(self.addressLabel.frame) + 4.0f,
                                                  self.phoneTitleLabel.frame.size.width,
                                                  self.phoneTitleLabel.frame.size.height)];
    }
    else{
        [self.phoneTitleLabel setFrame:CGRectMake(30.0f + 1.0f,
                                                  CGRectGetMaxY(self.addressLabel.frame) + 4.0f,
                                                  self.phoneTitleLabel.frame.size.width,
                                                  self.phoneTitleLabel.frame.size.height)];
    }
    self.phoneTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.phoneTitleLabel];
    
    self.phoneLabel.textAlignment = NSTextAlignmentLeft;
    NSString *phoneNumber =[self convertToPersianNumber:address.phone];
    [self.phoneLabel setText:phoneNumber];
    [self.phoneLabel sizeToFit];
    [self.phoneLabel setFrame:CGRectMake(CGRectGetMaxX(self.phoneTitleLabel.frame) + 4.0f,
                                         self.phoneTitleLabel.frame.origin.y,
                                         self.frame.size.width - CGRectGetMaxX(self.phoneTitleLabel.frame),
                                         self.phoneLabel.frame.size.height)];
    [self addSubview:self.phoneLabel];
    
    self.invalidLabel.textAlignment = NSTextAlignmentLeft;
    if ([address.isDefaultShipping isEqualToString:@"1"] || [address.isDefaultShipping isEqualToString:@"1"]) {
        [self.invalidLabel setText:STRING_INVALID_ADDRESS_BILLING_SHIPPING];
    } else {
        [self.invalidLabel setText:STRING_INVALID_ADDRESS_OTHER];
    }
    [self.invalidLabel sizeToFit];
    [self.invalidLabel setFrame:CGRectMake(16.0f,
                                           CGRectGetMaxY(self.phoneLabel.frame) + 4.0f,
                                           self.frame.size.width - 16.0f - self.editAddressButton.frame.size.width,
                                           self.invalidLabel.frame.size.height)];
    [self addSubview:self.invalidLabel];
    if (VALID_NOTEMPTY(address.isValid, NSString) && [address.isValid isEqualToString:@"1"]) {
        self.invalidLabel.hidden = YES;
    } else {
        self.invalidLabel.hidden = NO;
    }
    
    self.verticalSeparator.frame = CGRectMake(self.frame.size.width - self.editAddressButton.frame.size.width - 25.0f, 1.0f, 1.0f, self.frame.size.height);
    self.separator.frame = CGRectMake(0.0f, kAddressCellHeight - 1.0f, self.frame.size.width, 1.0f);
    [self addSubview:self.separator];
    
    [self addSubview:self.verticalSeparator];
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
    if(!self.fromCheckOut){
    self.horizontalSeparator.frame = CGRectMake(0.0f, kAddressCellHeight/2, self.verticalSeparator.frame.origin.x, 1.0f);
    [self addSubview:self.horizontalSeparator];
        self.deleteAddressButton.frame = CGRectMake(self.frame.size.width - self.editAddressButton.frame.size.width - 16.0f,
                                                  self.editAddressButton.frame.origin.y + 4.0f,
                                                  self.editAddressButton.frame.size.width,
                                                  self.editAddressButton.frame.size.height);
        [self addSubview:self.deleteAddressButton];
    }

}

-(NSString *) convertToPersianNumber:(NSString *) string {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"fa"];
    for (NSInteger i = 0; i < 10; i++) {
        NSNumber *num = @(i);
        string = [string stringByReplacingOccurrencesOfString:num.stringValue withString:[formatter stringFromNumber:num]];
    }
    return string;
}

- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}
@end
