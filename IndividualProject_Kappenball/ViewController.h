//
//  ViewController.h
//  IndividualProject_Kappenball
//
//  Created by Gabriel Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BallModel.h"
#import "AppDataModel.h"

@interface ViewController : UIViewController

/* Properties */

// Define the timer object
@property (strong) NSTimer* movementTimer;

// Define the model objects
@property (strong) BallModel* ball;
@property (strong) AppDataModel* appData;

// Define the storyboard objects to be interacted with
// view objects
@property (weak) IBOutlet UIView* viewTop;
@property (weak) IBOutlet UIView* viewCenter;
@property (weak) IBOutlet UIView* viewBottom;

// define the blob object
@property (strong) UIImageView* blobImageView;

// imageview objects
@property (strong) UIImageView* backgroundImageView;
@property (strong) UIImageView* ballImageView;

@property (weak) IBOutlet UILabel* scoreLabel;
@property (weak) IBOutlet UILabel* avgEnergyLabel;
@property (weak) IBOutlet UILabel* currEnergyLabel;

@property (weak) IBOutlet UISlider* randSlider;

@property (weak) IBOutlet UIButton* resetBtn;
@property (weak) IBOutlet UIButton* pauseBtn;
@property (weak) IBOutlet UIButton* highscoresBtn;

/* Instance methods */
// Slider actions
-(IBAction)randSliderChanged;

// Buttons actions
-(IBAction)resetBtnPressed;
-(IBAction)pauseBtnPressed;
-(IBAction)highscoresBtnPressed;

// Timer methods
-(void)startMovementTimer;
-(void)stopMovementTimer;

// Initialization method
-(void)initializeVariables;

// Ball movement method
-(void)moveBall;

@end

