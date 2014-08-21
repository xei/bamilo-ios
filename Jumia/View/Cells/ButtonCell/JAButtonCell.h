//
//  JAButtonCell.h
//  Jumia
//
//  Created by Telmo Pinto on 20/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAButtonCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *button;

- (void)loadWithButtonName:(NSString*)buttonName;

@end
