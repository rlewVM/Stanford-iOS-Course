//
//  Photo+MKAnnotation.m
//  Photomania
//
//  Created by Rachel Lew on 3/10/15.
//  Copyright (c) 2015 Rachel Lew. All rights reserved.
//

#import "Photo+MKAnnotation.h"

@implementation Photo (MKAnnotation)

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    
    coordinate.longitude = [self.longitude doubleValue];
    coordinate.latitude = [self.latitude doubleValue];
    
    return coordinate;
}

@end
