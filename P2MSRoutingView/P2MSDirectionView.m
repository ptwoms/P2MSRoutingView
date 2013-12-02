//
//  P2MSDirectionView.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSDirectionView.h"

@implementation DirectionIndex
@end

@implementation P2MSDirectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setRouteOverview:(NSString *)routeOverview{
        _routeOverview = routeOverview;
        [self redrawOverview];
}

- (void)redrawOverview{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    NSArray *finalArr = [_routeOverview componentsSeparatedByString:@"##"];
    NSMutableString *finalStr = [NSMutableString string];
    
    UILabel *labelToShow = [[UILabel alloc]initWithFrame:self.bounds];
    labelToShow.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    labelToShow.textColor = [UIColor grayColor];
    labelToShow.backgroundColor = [UIColor clearColor];
    labelToShow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:labelToShow];
    NSString *basicString = @"       >";
    CGFloat basicWidth = [basicString sizeWithFont:labelToShow.font constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) lineBreakMode:labelToShow.lineBreakMode].width;
    CGFloat finalWidth = basicWidth * (finalArr.count-1) + 27;
    if (finalWidth >= self.bounds.size.width) {
        CGFloat width = 3, lastIndex = finalArr.count;
        for (int i = 0; i < lastIndex; i++) {
            NSString *curStr = [finalArr objectAtIndex:i];
            if (i < lastIndex-1) {
                [finalStr appendString:basicString];
            }
            CGFloat newWidth = [finalStr sizeWithFont:labelToShow.font constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) lineBreakMode:labelToShow.lineBreakMode].width + 3;
            //need to consider about three dots case
            if (newWidth < self.bounds.size.width) {
                NSArray *routeComponents = [curStr componentsSeparatedByString:@"#"];
                UIImageView *imgView = [self getImageViewForRoute:routeComponents];
                imgView.frame = CGRectMake(width, 4, imgView.frame.size.width, imgView.frame.size.height);
                [self addSubview:imgView];
            }
            width = newWidth;
            if (width > self.bounds.size.width)break;
        }
        labelToShow.text = finalStr;
    }else{
        int index = 0;
        NSMutableArray *indexArr = [NSMutableArray array];
        for (NSString *curStr in finalArr){
            NSArray *routeComponents = [curStr componentsSeparatedByString:@"#"];
            NSString *travel_mode = [routeComponents objectAtIndex:0];
            if ([travel_mode isEqualToString:@"TRANSIT"]) {
                NSString *transit_name = [routeComponents objectAtIndex:2];
                DirectionIndex *newIndex = [[DirectionIndex alloc]init];
                newIndex.index = index;
                newIndex.width = [transit_name sizeWithFont:labelToShow.font constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) lineBreakMode:labelToShow.lineBreakMode].width+3;
                [indexArr addObject:newIndex];
            }
            index++;
        }
        
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        if (indexArr.count) {
            [indexArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                DirectionIndex *indexOne = obj1;
                DirectionIndex *indexTwo = obj2;
                if (indexOne.width > indexTwo.width) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if (indexOne.width < indexTwo.width) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            for (DirectionIndex *curIndex in indexArr) {
                if (finalWidth + curIndex.width <= self.bounds.size.width){
                    finalWidth += curIndex.width;
                    [indexSet addIndex:curIndex.index];
                }else break;
            }
        }
        
        CGFloat width = 3, curIndex = 0, lastIndex = finalArr.count;
        int i;
        CGFloat centerY = (self.bounds.size.height-23)/2;
        for (i = 0; i < lastIndex; i++) {
            NSString *curStr = [finalArr objectAtIndex:i];
            NSArray *routeComponents = [curStr componentsSeparatedByString:@"#"];
            
            UIImageView *imgView = [self getImageViewForRoute:routeComponents];
            imgView.frame = CGRectMake(width, centerY, imgView.frame.size.width, imgView.frame.size.height);
            [self addSubview:imgView];
            
            if (i < lastIndex -1) {
                
                if ([indexSet containsIndex:curIndex]) {
                    NSString *transit_name = [routeComponents objectAtIndex:2];
                    [finalStr appendFormat:@"       %@ >", transit_name];
                }else
                    [finalStr appendString:basicString];
            }
            width = [finalStr sizeWithFont:labelToShow.font constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) lineBreakMode:labelToShow.lineBreakMode].width + 3;
            curIndex++;
        }
        labelToShow.text = finalStr;
    }
}

- (UIImageView *)getImageViewForRoute:(NSArray *)routeComponent{
    NSString *travel_mode = [routeComponent objectAtIndex:0];
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 23)];
    if ([travel_mode isEqualToString:@"WALKING"]) {
        [imgView setImage:[UIImage imageNamed:@"walk_icon"]];
    }else if ([travel_mode isEqualToString:@"TRANSIT"]){
        NSString *vehicleType = [routeComponent objectAtIndex:1];
        if ([vehicleType isEqualToString:@"BUS"]) {
            [imgView setImage:[UIImage imageNamed:@"bus_icon"]];
        }else if ([vehicleType isEqualToString:@"SUBWAY"]){
            [imgView setImage:[UIImage imageNamed:@"mrt_icon"]];
        }else if ([vehicleType isEqualToString:@"HEAVY_RAIL"]){
            [imgView setImage:[UIImage imageNamed:@"train_icon"]];
        }else if ([vehicleType isEqualToString:@"TRAM"]){
            [imgView setImage:[UIImage imageNamed:@"lrt_icon"]];
        }else{
            [imgView setImage:[UIImage imageNamed:@"no_icon"]];
        }
    }else if([travel_mode isEqualToString:@"DRIVING"]){
        [imgView setImage:[UIImage imageNamed:@"no_icon"]];
    }else{
        [imgView setImage:[UIImage imageNamed:@"no_icon"]];
    }
    return imgView;
}



@end
