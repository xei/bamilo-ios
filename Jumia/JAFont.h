//
//  JAFont.h
//  Jumia
//
//  Created by Telmo Pinto on 17/03/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#ifndef Jumia_JAFont_h
#define Jumia_JAFont_h

#define kFontRegularNameKey @"kFontRegularNameKey"
#define kFontLightNameKey @"kFontLightNameKey"
#define kFontBoldNameKey @"kFontBoldNameKey"
#define kFontMediumNameKey @"kFontMediumNameKey"

#define kFontRegularName [[NSUserDefaults standardUserDefaults] objectForKey:kFontRegularNameKey]
#define kFontLightName [[NSUserDefaults standardUserDefaults] objectForKey:kFontLightNameKey]
#define kFontBoldName [[NSUserDefaults standardUserDefaults] objectForKey:kFontBoldNameKey]
#define kFontMediumName [[NSUserDefaults standardUserDefaults] objectForKey:kFontMediumNameKey]

#define JADisplay1Font      [UIFont fontWithName:kFontRegularName size:30]
#define JADisplay2Font      [UIFont fontWithName:kFontRegularName size:20]
#define JASystemTitleFont   [UIFont fontWithName:kFontRegularName size:17]
#define JADisplay3Font      [UIFont fontWithName:kFontRegularName size:16]
#define JATitleFont         [UIFont fontWithName:kFontMediumName size:14]
#define JAListFont          [UIFont fontWithName:kFontRegularName size:14]
#define JAHEADLINEFont      [UIFont fontWithName:kFontBoldName size:12]
#define JABodyFont          [UIFont fontWithName:kFontRegularName size:12]
#define JACaptionFont       [UIFont fontWithName:kFontRegularName size:10]
#define JABADGEFont         [UIFont fontWithName:kFontMediumName size:10]
#define JABUTTONFont        [UIFont fontWithName:kFontBoldName size:14]


#warning out of styleguide fonts

#define JACheckBoxTitle                     [UIFont fontWithName:kFontRegularName size:13.0f]

#define JAPickerDoneLabel                   [UIFont fontWithName:kFontRegularName size:13.0f]
#define JAPickerAttLabel                    [UIFont fontWithName:kFontLightName size:22.0f]

#define JAMainFilterCellSubLabel            [UIFont fontWithName:kFontLightName size:14.0f]
#define JAFilterCellCategoryTitle           [UIFont fontWithName:kFontBoldName size:16.0f]

#define JAOtherOffersFromLabel              [UIFont fontWithName:kFontRegularName size:9.0f]
#define JAOtherOffersMinPriceLabel          [UIFont fontWithName:kFontRegularName size:9.0f]

#define JASearchViewHighlightFont           [UIFont fontWithName:kFontLightName size:17.0f]
#define JASearchViewQueryFont               [UIFont fontWithName:kFontMediumName size:17.0f]

#define JASortingViewSortByLabel            [UIFont fontWithName:kFontLightName size:12.0f]
#define JASortingViewSortAttLabel           [UIFont fontWithName:kFontLightName size:17.0f]

#define JAUndefinedSearchNoResultsLabel     [UIFont fontWithName:kFontLightName size:14.0f]
#define JAUndefinedSearchQueryLabel         [UIFont fontWithName:kFontBoldName size:14.0f]
#define JAUndefinedTipsLabel                [UIFont fontWithName:kFontLightName size:13.0f]
#define JAUndefinedBrandLabel               [UIFont fontWithName:kFontLightName size:13.0f]
#define JAUndefinedTopTitles                [UIFont fontWithName:kFontRegularName size:11.0f]

#endif
