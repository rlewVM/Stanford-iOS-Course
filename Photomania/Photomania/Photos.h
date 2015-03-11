//
//  Photos.h
//  Photomania
//
//  Created by Rachel Lew on 3/4/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographers;

@interface Photos : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) Photographers *whoTook;

@end
