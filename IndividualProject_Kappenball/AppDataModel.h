//
//  AppDataModel.h
//  IndividualProject_Kappenball
//
//  Created by Gabriel Teodor Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataModel : NSObject

typedef NS_ENUM( NSUInteger, GameDifficultyLevels )
{
    GameDifficultyLevel0,
    GameDifficultyLevel1,
    GameDifficultyLevel2,
    GameDifficultyLevel3,
    GameDifficultyLevel4,
    GameDifficultyLevel5,
};

/* Properties */
@property (assign) int noOfPlays;
@property (assign) int totalEnergy;

@property (assign) int score;
@property (assign) int avgEnergy;
@property (assign) int currentEnergy;

@property (assign) float xVelocity;
@property (assign) float acceleration;
@property (assign) float randomness;

// extra features properties
@property (assign) BOOL makeGameDifficult;
@property (assign) GameDifficultyLevels gameDifficulty;

@end
