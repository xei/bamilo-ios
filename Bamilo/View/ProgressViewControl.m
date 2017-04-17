//
//  ProgressViewControl.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ProgressViewControl.h"
#import "ProgressView.h"

@interface ProgressViewControl()
@property (nonatomic, strong) ProgressView *progressView;
@end

@implementation ProgressViewControl

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    self.progressView = [ProgressView nibInstance];
    
    if(self.progressView) {
        [self addSubview:self.progressView];
        [self anchorMatch:self.progressView];
    }
}

-(void)updateWithModel:(NSArray<ProgressItemViewModel *> *)items {
    [self.progressView updateWithModel:items];
    [self.progressView setDelegate:self.delegate];
}

@end
