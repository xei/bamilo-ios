//
//  CheckoutConfirmationViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutConfirmationViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "PlainTableViewHeaderCell.h"
#import "FlexStackTableViewCell.h"
#import "AddressTableViewCell.h"
#import "DiscountSwitcherView.h"
#import "DiscountCodeView.h"
#import "BasicTableViewCell.h"

@interface CheckoutConfirmationViewController() <DiscountSwitcherViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) FlexStackTableViewCell *totalSumDiscountFlexTableViewCell;
@property (weak, nonatomic) FlexStackTableViewCell *totalSumReceiptFlexTableViewCell;
@end

@implementation CheckoutConfirmationViewController

-(FlexStackTableViewCell *)totalSumDiscountFlexTableViewCell {
    if(_totalSumDiscountFlexTableViewCell == nil) {
        _totalSumDiscountFlexTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:[FlexStackTableViewCell nibName]];
        _totalSumDiscountFlexTableViewCell.options = BOLD_SEPARATOR;
        
        DiscountSwitcherView *discountSwitcherView = [[[NSBundle mainBundle] loadNibNamed:[DiscountSwitcherView nibName] owner:self options:nil] lastObject];
        if(discountSwitcherView) {
            discountSwitcherView.delegate = self;
            [_totalSumDiscountFlexTableViewCell setUpperViewTo:discountSwitcherView];
        }
        
        DiscountCodeView *discountCodeView = [[[NSBundle mainBundle] loadNibNamed:[DiscountCodeView nibName] owner:self options:nil] lastObject];
        if(discountCodeView) {
            [_totalSumDiscountFlexTableViewCell setLowerViewTo:discountCodeView];
        }
        
        [_totalSumDiscountFlexTableViewCell update:LOWER_VIEW set:NO animated:NO];
    }
    
    return _totalSumDiscountFlexTableViewCell;
}

-(FlexStackTableViewCell *)totalSumReceiptFlexTableViewCell {
    if(_totalSumReceiptFlexTableViewCell == nil) {
        _totalSumReceiptFlexTableViewCell = [self.tableView dequeueReusableCellWithIdentifier:[FlexStackTableViewCell nibName]];
    }
    
    return _totalSumReceiptFlexTableViewCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    
    [self.tableView registerNib:[UINib nibWithNibName:[BasicTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[BasicTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[FlexStackTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[FlexStackTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[AddressTableViewCell nibName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overrides
-(NSString *)getNextStepViewControllerSegueIdentifier {
    return @"pushReviewToPayment";
}

-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_FINAL_REVIEW;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 3;
        //case 1: return 0;
        //case 2: return 1;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        //Total Sum Section
        case 0:
            switch (indexPath.row) {
                //Discount Cell
                case 0: return self.totalSumDiscountFlexTableViewCell;
                case 1: return self.totalSumReceiptFlexTableViewCell;
                case 2: {
                    BasicTableViewCell *deliveryTimeTableViewCell = [tableView dequeueReusableCellWithIdentifier:[BasicTableViewCell nibName] forIndexPath:indexPath];
                    if(deliveryTimeTableViewCell) {
                        deliveryTimeTableViewCell.titleLabel.text = @"زمان تحویل: ۶ - ۳ روز";
                    }
                    
                    return deliveryTimeTableViewCell;
                }
            }
        break;
          
        //Purchase Summary Section
        case 1:
        break;
            
        //Recipient Address Section
        case 2:
        break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
    
    switch (section) {
        case 0:
            plainTableViewHeaderCell.title = STRING_TOTAL_SUM;
        break;
            
        case 1:
            plainTableViewHeaderCell.title = STRING_PURCHASE_SUMMARY;
        break;
            
        case 2:
            plainTableViewHeaderCell.title = STRING_RECIPIENT_ADDRESS;
        break;
    }
    
    return plainTableViewHeaderCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 2: return 50.0f; //Delivery Time Cell
            }
        break;
    }
    
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

#pragma mark - DiscountSwitcherViewDelegate
-(void)discountSwitcherViewDidToggle:(BOOL)isOn {
    [self.tableView beginUpdates];
    [self.totalSumDiscountFlexTableViewCell update:LOWER_VIEW set:isOn animated:YES];
    [self.tableView endUpdates];
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING]
    ];
}

@end
