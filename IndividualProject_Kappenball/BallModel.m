//
//  BallModel.m
//  IndividualProject_Kappenball
//
//  Created by Gabriel Teodor Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import "BallModel.h"

@implementation BallModel

/* Class constructor */
-(id)initWithX:(float)x Y:(float)y
{
    self = [super init];
    if(self)
    {
        _xCoord = x;
        _yCoord = y;
    }
    return self;
}


@end
