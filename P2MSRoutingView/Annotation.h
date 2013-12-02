//
//  Annotation.h
//  location
//
//  Created by PYAE PHYO MYINT SOE on 30/7/12.
//  Copyright (c) 2012 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Annotation : NSObject<MKAnnotation>{
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) char type;

-(id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end
