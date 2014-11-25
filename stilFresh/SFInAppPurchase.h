//
//  SFInAppPurchase.h
//  stilFresh
//
//  Created by Liwei Zhang on 2014-11-22.
//  Copyright (c) 2014 Liwei Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <RMStore/RMStore.h>

@interface SFInAppPurchase : NSObject <SKProductsRequestDelegate, RMStoreObserver>

@property (nonatomic, strong) NSArray *products;

@end
