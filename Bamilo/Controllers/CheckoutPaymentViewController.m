//
//  CheckoutPaymentViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutPaymentViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "PlainTableViewHeaderCell.h"
#import "PaymentTypeTableViewCell.h"
#import "OnlinePaymentVariationTableViewCell.h"
#import "PayOnDeliveryTableViewCell.h"

typedef NS_OPTIONS(NSUInteger, PaymentMethods) {
    PAYMENT_METHOD_ONLINE = 1 << 0,
    PAYMENT_METHOD_ON_DELIVERY = 1 << 1
};

@interface CheckoutPaymentViewController () <RadioButtonViewControlDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CheckoutPaymentViewController {
@private
    NSMutableArray *_cellsIndexPaths;
    PaymentMethods _selectedPaymentMethod;
    int _indexForOnlineMethodVariation;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Header And Footer Cells
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    
    //PaymentTypeTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentTypeTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentTypeTableViewCell nibName]];
    
    //OnlinePaymentVariationTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[OnlinePaymentVariationTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[OnlinePaymentVariationTableViewCell nibName]];
    
    //PayOnDeliveryTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PayOnDeliveryTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PayOnDeliveryTableViewCell nibName]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _cellsIndexPaths = [NSMutableArray arrayWithObjects:
                        //Online Payment
                        [NSIndexPath indexPathForRow:0 inSection:0],
                        //[NSIndexPath indexPathForRow:1 inSection:0],
                        //Pay On Delivery
                        [NSIndexPath indexPathForRow:2 inSection:0],
                        [NSIndexPath indexPathForRow:3 inSection:0], nil];
    
    //Select Online Payment and Saman By Default
    _selectedPaymentMethod = PAYMENT_METHOD_ONLINE;
    _indexForOnlineMethodVariation = 0; //0=Saman, 1=Parsian
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Overrides
-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_PAYMENT_OPTION;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_cellsIndexPaths count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *_cellIndexPath = [_cellsIndexPaths objectAtIndex:indexPath.row];
                    
    switch (_cellIndexPath.row) {
        case 0: {
            PaymentTypeTableViewCell *onlinePaymentTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentTypeTableViewCell nibName] forIndexPath:indexPath];
            onlinePaymentTableViewCell.tag = PAYMENT_METHOD_ONLINE;
            onlinePaymentTableViewCell.delegate = self;
            
            PaymentTypeTableViewCellModel *model = [[PaymentTypeTableViewCellModel alloc] init];
            model.title = STRING_ONLINE_PAYMENT;
            model.isSelected = (_selectedPaymentMethod == PAYMENT_METHOD_ONLINE);
            [onlinePaymentTableViewCell updateWithModel:model];
            
            return onlinePaymentTableViewCell;
        }
            
        case 1: {
            OnlinePaymentVariationTableViewCell *onlinePaymentVariationTableViewCell = [tableView dequeueReusableCellWithIdentifier:[OnlinePaymentVariationTableViewCell nibName] forIndexPath:indexPath];
            return onlinePaymentVariationTableViewCell;
        }
        
        case 2: {
            PaymentTypeTableViewCell *payOnDeliveryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentTypeTableViewCell nibName] forIndexPath:indexPath];
            payOnDeliveryTableViewCell.tag = PAYMENT_METHOD_ON_DELIVERY;
            payOnDeliveryTableViewCell.delegate = self;
            
            PaymentTypeTableViewCellModel *model = [[PaymentTypeTableViewCellModel alloc] init];
            model.title = STRING_PAY_ON_DELIVERY;
            model.isSelected = (_selectedPaymentMethod == PAYMENT_METHOD_ON_DELIVERY);
            [payOnDeliveryTableViewCell updateWithModel:model];
            
            return payOnDeliveryTableViewCell;
        }
            
        case 3: {
            PayOnDeliveryTableViewCell *payOnDeliveryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PayOnDeliveryTableViewCell nibName] forIndexPath:indexPath];
            payOnDeliveryTableViewCell.descLabel.text = @"مبلغ سفارش را به صورت نقدی و با با کارت بانکی به پیک بامیلو پرداخت نمایید.";
            return payOnDeliveryTableViewCell;
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [PlainTableViewHeaderCell cellHeight];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
    plainTableViewHeaderCell.title = STRING_PAYMENT_OPTION;
    return plainTableViewHeaderCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

#pragma mark - RadioButtonViewControlDelegate
-(void)didSelectRadioButton:(id)sender {
    PaymentTypeTableViewCell *radioButtonPaymentTypeTableViewCell = (PaymentTypeTableViewCell *)sender;
    _selectedPaymentMethod = (PaymentMethods)radioButtonPaymentTypeTableViewCell.tag;
    [self.tableView reloadData];
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE]
    ];
}

@end
