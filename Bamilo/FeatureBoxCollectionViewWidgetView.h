//
//  FeatureBoxCollectionViewWidgetView.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FeatureBoxWidgetView.h"

@protocol FeatureBoxCollectionViewWidgetViewDelegate<NSObject>
- (void)moreButtonTappedInWidgetView:(id)widgetView; //self type
- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox;
@end

@interface FeatureBoxCollectionViewWidgetView : FeatureBoxWidgetView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *collectionItems;
@property (nonatomic, weak) id<FeatureBoxCollectionViewWidgetViewDelegate> delegate;

- (void)updateWithModel:(NSArray *)arrayModel;

@end
