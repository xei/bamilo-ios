//
//  RIConfiguration.h
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT BOOL const RI_REQUEST_LOGGER;
FOUNDATION_EXPORT BOOL const RI_RESPONSE_LOGGER;

FOUNDATION_EXPORT BOOL const RI_IS_RTL;

FOUNDATION_EXPORT NSString *const RI_USERNAME;
FOUNDATION_EXPORT NSString *const RI_PASSWORD;

FOUNDATION_EXPORT BOOL RI_MOBAPI_HEADERS_ENABLED;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_VERSION_NAME;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_VERSION_VALUE;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_LANG_NAME;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_LANG_VALUE;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_TOKEN_NAME;
FOUNDATION_EXPORT NSString *const RI_MOBAPI_VERSION_HEADER_TOKEN_VALUE;

FOUNDATION_EXPORT NSString *const RI_HTTP_METHOD_POST;
FOUNDATION_EXPORT NSString *const RI_HTTP_METHOD_GET;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_NAME;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_FORM_DATA_VALUE;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_JSON_VALUE;
FOUNDATION_EXPORT NSString *const RI_HTTP_CONTENT_TYPE_HEADER_PLIST_VALUE;

FOUNDATION_EXPORT BOOL RI_HTTP_REQUEST_SHOULD_RETRY;
FOUNDATION_EXPORT NSInteger RI_HTTP_REQUEST_NUMBER_OF_RETRIES;
FOUNDATION_EXPORT NSInteger RI_HTTP_REQUEST_TIMEOUT;

FOUNDATION_EXPORT NSString *const RI_HTTP_USER_AGENT_HEADER_NAME;
FOUNDATION_EXPORT NSString *const RI_HTTP_USER_AGENT_HEADER_IPHONE_VALUE;
FOUNDATION_EXPORT NSString *const RI_HTTP_USER_AGENT_HEADER_IPAD_VALUE;

FOUNDATION_EXPORT NSString *const RI_HTTP_USER_LANGUAGE_HEADER_NAME;

FOUNDATION_EXPORT NSString *const RI_COUNTRIES_URL_JUMIA;
FOUNDATION_EXPORT NSString *const RI_COUNTRIES_URL_JUMIA_STAGING;
FOUNDATION_EXPORT NSString *const RI_COUNTRIES_URL_DARAZ;
FOUNDATION_EXPORT NSString *const RI_COUNTRIES_URL_DARAZ_STAGING;

FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_URL_SHOP;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_URL_SHOP_STAGING;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_SHOP;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_NAME_SHOP;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_ISO_SHOP;

FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_URL_BAMILO;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_URL_BAMILO_STAGING;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_URL_BAMILO_INTEGRATION_MOBILE;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_BAMILO;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_USER_AGENT_INJECTION_BAMILO_INTEGRATION_MOBILE;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_NAME_BAMILO;
FOUNDATION_EXPORT NSString *const RI_UNIQUE_COUNTRY_ISO_BAMILO;

FOUNDATION_EXPORT NSString *const RI_MOBAPI_PREFIX;
FOUNDATION_EXPORT NSString *const RI_API_VERSION;
FOUNDATION_EXPORT NSString *const RI_API_VERSION15;
FOUNDATION_EXPORT NSString *const RI_CATALOG_CATEGORIES;
FOUNDATION_EXPORT NSString *const RI_API_CATALOG;
FOUNDATION_EXPORT NSString *const RI_FORMS_INDEX;
FOUNDATION_EXPORT NSString *const RI_API_INFO;
FOUNDATION_EXPORT NSString *const RI_API_IMAGE_RESOLUTIONS;
FOUNDATION_EXPORT NSString *const RI_API_GET_TEASERS;
FOUNDATION_EXPORT NSString *const RI_API_GET_STATICBLOCKS;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_REGISTER_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_LOGIN_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_FACEBOOK_LOGIN_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_LOGOUT_CUSTOMER;
FOUNDATION_EXPORT NSString *const RI_API_GET_ORDERS;
FOUNDATION_EXPORT NSString *const RI_API_TRACK_ORDER;
FOUNDATION_EXPORT NSString *const RI_API_SEARCH_SUGGESTIONS;
FOUNDATION_EXPORT NSString *const RI_API_COUNTRY_CONFIGURATION;
FOUNDATION_EXPORT NSString *const RI_API_ADD_ORDER;
FOUNDATION_EXPORT NSString *const RI_API_ADD_MULTIPLE_ORDER;
FOUNDATION_EXPORT NSString *const RI_API_GET_CART_DATA;
FOUNDATION_EXPORT NSString *const RI_API_GET_CART_CHANGE;
FOUNDATION_EXPORT NSString *const RI_API_REMOVE_FROM_CART;
FOUNDATION_EXPORT NSString *const RI_API_ADD_VOUCHER_TO_CART;
FOUNDATION_EXPORT NSString *const RI_API_REMOVE_VOUCHER_FROM_CART;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER_ADDRESS_LIST;
FOUNDATION_EXPORT NSString *const RI_API_GET_CUSTOMER_SELECT_DEFAULT;
FOUNDATION_EXPORT NSString *const RI_API_GET_MULTISTEP_ADDRESSES;
FOUNDATION_EXPORT NSString *const RI_API_GET_SHIPPING_METHODS_FORM;
FOUNDATION_EXPORT NSString *const RI_API_GET_PAYMENT_METHODS_FORM;
FOUNDATION_EXPORT NSString *const RI_API_FINISH_CHECKOUT;
FOUNDATION_EXPORT NSString *const RI_API_PROMOTIONS_URL;
FOUNDATION_EXPORT NSString *const RI_RATE_CONVERSION;
FOUNDATION_EXPORT NSString *const RI_GET_CAMPAIGN;
FOUNDATION_EXPORT NSString *const RI_API_BUNDLE;
FOUNDATION_EXPORT NSString *const RI_API_ADD_BUNDLE;
FOUNDATION_EXPORT NSString *const RI_API_GET_WISHLIST;
FOUNDATION_EXPORT NSString *const RI_API_ADD_TO_WISHLIST;
FOUNDATION_EXPORT NSString *const RI_API_REMOVE_FOM_WISHLIST;
FOUNDATION_EXPORT NSString *const RI_API_PRODUCT_OFFERS;
FOUNDATION_EXPORT NSString *const RI_API_SELLER_RATING;
FOUNDATION_EXPORT NSString *const RI_API_PROD_RATING;
FOUNDATION_EXPORT NSString *const RI_API_PROD_VALIDATE;

FOUNDATION_EXPORT NSString *const RI_API_PRODUCT_DETAIL;
FOUNDATION_EXPORT NSString *const RI_API_CATALOG_HASH;
FOUNDATION_EXPORT NSString *const RI_API_CATALOG_BRAND;
FOUNDATION_EXPORT NSString *const RI_API_CATALOG_SELLER;
FOUNDATION_EXPORT NSString *const RI_API_CAMPAIGN_PAGE;
FOUNDATION_EXPORT NSString *const RI_API_STATIC_PAGE;
FOUNDATION_EXPORT NSString *const RI_API_FORMS_GET;
FOUNDATION_EXPORT NSString *const RI_API_FORMS_ADDRESS_EDIT;
FOUNDATION_EXPORT NSString *const RI_API_PROD_RATING_DETAILS;

FOUNDATION_EXPORT NSString *const RI_API_RICH_RELEVANCE;
FOUNDATION_EXPORT NSString *const RI_API_RICH_RELEVANCE_CLICK;
