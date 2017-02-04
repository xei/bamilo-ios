//
//  AddressTableViewHeaderCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressTableViewHeaderCell.h"

@interface AddressTableViewHeaderCell()
@property (weak, nonatomic) IBOutlet UIButton *addAddressButton;
@end

@implementation AddressTableViewHeaderCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    //Add Addres Button Setup
    [self.addAddressButton applyStyle:kFontBoldName fontSize:12 color:[UIColor withRGBA:61 green:146 blue:243 alpha:1.0f]];
    self.addAddressButton.titleLabel.text = STRING_NEW_ADDRESS;
}

+(NSString *)nibName {
    return @"AddressTableViewHeaderCell";
}

#pragma mark - IBActions
- (IBAction)addAddressButtonTapped:(id)sender {
}

@end
