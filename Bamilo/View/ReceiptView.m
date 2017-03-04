//
//  ReceiptView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReceiptView.h"

@interface ReceiptView() <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ReceiptView {
@private
    NSArray<ReceiptItemModel *> *_items;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    [self.tableView registerNib:[UINib nibWithNibName:[ReceiptItemView nibName] bundle:nil] forCellReuseIdentifier:[ReceiptItemView nibName]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"ReceiptView";
}

- (void)updateWithModel:(id)model {
    _items = (NSArray *)model;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ReceiptItemView cellHeight];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ReceiptItemView *receiptItemView = [self.tableView dequeueReusableCellWithIdentifier:[ReceiptItemView nibName] forIndexPath:indexPath];
    [receiptItemView updateWithModel:[_items objectAtIndex:indexPath.row]];
    return receiptItemView;
}

@end
