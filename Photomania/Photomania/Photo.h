//
//  Photo.h
//  Photomania
//
//  Created by Rachel Lew on 3/10/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique_id;
@property (nonatomic, retain) Photographer *whoTook;

@end
