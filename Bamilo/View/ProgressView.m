//
//  ProgressView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ProgressView.h"

#define cCIRCLE_INDICATOR_HEIGHT 15.0f

@interface ProgressView()
@property (weak, nonatomic) IBOutlet UIView *centerLineView;
@end

@implementation ProgressView {
@private
    NSArray<ProgressItemViewModel *> *_items;
    NSMutableArray *_progressItemViews;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    _progressItemViews = [NSMutableArray new];
}

-(void)updateWithModel:(NSArray<ProgressItemViewModel *> *)items {
    _items = items;
    
    [self updateProgressViewAppearance];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    float itemMarginX = self.centerLineView.frame.size.width / (_items.count - 1);
    float itemPositionX = self.centerLineView.frame.origin.x;
    
    for(ProgressItemView *itemView in _progressItemViews) {
        [itemView setCenter:CGPointMake(itemPositionX, self.centerLineView.frame.origin.y + cCIRCLE_INDICATOR_HEIGHT / 2)];
        itemPositionX += itemMarginX;
    }
}

#pragma mark - Helpers
-(void) updateProgressViewAppearance {
    for(UIView *view in _progressItemViews) {
        [view removeFromSuperview];
    }
    
    [_progressItemViews removeAllObjects];

    for(ProgressItemViewModel *model in _items) {
        ProgressItemView *_progressView = [[[NSBundle mainBundle] loadNibNamed:@"ProgressItemView" owner:self options:nil] lastObject];
        [_progressView updateWithModel:model];
        [_progressView setDelegate:self.delegate];
        [_progressView setTag:[_items indexOfObject:model] + 1];
        [_progressItemViews addObject:_progressView];
        [self addSubview:_progressView];
    }
    
    [self layoutIfNeeded];
}

@end
