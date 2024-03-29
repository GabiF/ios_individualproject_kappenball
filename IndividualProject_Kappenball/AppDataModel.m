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
        _noOfPlays = 0;
        _totalEnergy = 0;
        _score = 0;
        _avgEnergy = 0;
        _currentEnergy = 0;
        _xVelocity = 0.0;
        _acceleration = 0.0;
        _randomness = 0.0;
        _makeGameDifficult = NO;
        _gameDifficulty = GameDifficultyLevel0;
    }
    return self;
}

@end
