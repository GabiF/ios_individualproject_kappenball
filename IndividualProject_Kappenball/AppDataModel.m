//
//  AppDataModel.m
//  IndividualProject_Kappenball
//
//  Created by Gabriel Teodor Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import "AppDataModel.h"

@implementation AppDataModel

/* Class constructor */
-(id)init
{
    self = [super init];
    if(self)
    {
        _score = 0;
        _avgEnergy = 0;
        _currentEnergy = 0;
        _randomness = 0.0;
    }
    return self;
}

@end
