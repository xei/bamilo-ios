//
//  JASwitchCell.h
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASwitchCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UISwitch *switchView;

-(void)loadWithText:(NSString*)text  isLastRow:(BOOL)isLastRow;

@end
