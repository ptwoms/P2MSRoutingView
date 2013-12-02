//
//  Annotation.m
//  location
//
//  Created by PYAE PHYO MYINT SOE on 30/7/12.
//  Copyright (c) 2012 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation
@synthesize coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D) cor{
    self=[super init];
    if(self){
        coordinate =cor;
        _type = 'p'; // 'p' = pin , 'g' = green pin, 'b' = blue pin
    }
    return self;
}

@end
