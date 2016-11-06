//
//  AppDataModel.h
//  IndividualProject_Kappenball
//
//  Created by Gabriel Teodor Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppDataModel : NSObject

/* Properties */
@property (assign) int noOfPlays;
@property (assign) int totalEnergy;

@property (assign) int score;
@property (assign) int avgEnergy;
@property (assign) int currentEnergy;

@property (assign) float xVelocity;
@property (assign) float acceleration;
@property (assign) float randomness;

@end
