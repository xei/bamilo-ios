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

#define JADisplay1Font [UIFont fontWithName:kFontRegularName size:23]
#define JADisplay2Font [UIFont fontWithName:kFontRegularName size:19]
#define JAListFont [UIFont fontWithName:kFontBoldName size:16]
#define JAList1Font [UIFont fontWithName:kFontMediumName size:16]
#define JAList2Font [UIFont fontWithName:kFontRegularName size:16]
#define JAButtonFont [UIFont fontWithName:kFontMediumName size:15]
#define JABody1Font [UIFont fontWithName:kFontBoldName size:13]
#define JABody2Font [UIFont fontWithName:kFontMediumName size:13]
#define JABody3Font [UIFont fontWithName:kFontRegularName size:13]
#define JACaptionFont [UIFont fontWithName:kFontRegularName size:11]
#define JACaption2Font [UIFont fontWithName:kFontBoldName size:11]
#define JABadgeFont [UIFont fontWithName:kFontBoldName size:10]



#define JADisplay1NewFont [UIFont fontWithName:kFontRegularName size:30]
#define JADisplay2NewFont [UIFont fontWithName:kFontRegularName size:20]
#define JADisplay3NewFont [UIFont fontWithName:kFontRegularName size:16]
#define JATitleFont [UIFont fontWithName:kFontMediumName size:14]
#define JAListNewFont [UIFont fontWithName:kFontRegularName size:14]
#define JAHEADLINEFont [UIFont fontWithName:kFontBoldName size:12]
#define JABodyFont [UIFont fontWithName:kFontRegularName size:12]
#define JACaptionNewFont [UIFont fontWithName:kFontRegularName size:10]
#define JABADGENewFont [UIFont fontWithName:kFontMediumName size:10]
#define JABUTTONNewFont [UIFont fontWithName:kFontBoldName size:14]
#define JASystemTitleFont [UIFont fontWithName:kFontRegularName size:17]

#endif
