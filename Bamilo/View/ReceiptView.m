//
//  ReceiptView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReceiptView.h"
#import "ReceiptItemView.h"

@interface ReceiptView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *receiptCollectionView;
@end

@implementation ReceiptView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self.receiptCollectionView registerNib:[UINib nibWithNibName:[ReceiptItemView nibName] bundle:nil] forCellWithReuseIdentifier:[ReceiptItemView nibName]];
    
    self.receiptCollectionView.delegate = self;
    self.receiptCollectionView.dataSource = self;
}

-(void)resizeToFitItems {
    [self setFrame:CGRectMake(0, 0, 0, self.items.count * [ReceiptItemView cellHeight])];
}

#pragma mark - Overrides
+(NSString *)nibName {
    return @"ReceiptView";
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ReceiptItemView *receiptItemView = [self.receiptCollectionView dequeueReusableCellWithReuseIdentifier:[ReceiptItemView nibName] forIndexPath:indexPath];
    [receiptItemView updateWithModel:[self.items objectAtIndex:indexPath.row]];
    return receiptItemView;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.width, [ReceiptItemView cellHeight]);
}

@end
