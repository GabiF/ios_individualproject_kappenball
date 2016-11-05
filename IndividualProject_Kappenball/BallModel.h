//
//  BallModel.h
//  IndividualProject_Kappenball
//
//  Created by Gabriel Teodor Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BallModel : NSObject

/* Class constructor */
-(id)initWithX:(float)x Y:(float)y;

/* Properties */
@property (assign) float xCoord;
@property (assign) float yCoord;

@end
