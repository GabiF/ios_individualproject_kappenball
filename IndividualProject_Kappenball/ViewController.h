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
// Define a flag to check if game is running
@property (assign) BOOL gameRunning;

// Define the background image views (tiles)
// walls
@property (weak) IBOutlet UIView* viewWallLeft;
@property (weak) IBOutlet UIView* viewGoalLeftWallLeft;
@property (weak) IBOutlet UIView* viewGoalRightWallLeft;
@property (weak) IBOutlet UIView* viewWallRight;
@property (weak) IBOutlet UIView* viewGoalLeftWallRight;
@property (weak) IBOutlet UIView* viewGoalRightWallRight;
// spikes
@property (weak) IBOutlet UIView* viewSpikesLeft;
@property (weak) IBOutlet UIView* viewSpikesCenter;
@property (weak) IBOutlet UIView* viewSpikesRight;
// goals
@property (weak) IBOutlet UIView* viewGoalLeft;
@property (weak) IBOutlet UIView* viewGoalRight;

// Define the timer objects
@property (strong) NSTimer* movementTimer;
@property (strong) NSTimer* energyTimer;

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
// Configure UI Elements
-(void)configureUIElements;

// Slider actions
-(IBAction)randSliderChanged;

// Buttons actions
-(IBAction)resetBtnPressed;
-(IBAction)pauseBtnPressed;
-(IBAction)highscoresBtnPressed;

// Timer methods
-(void)startMovementTimer;
-(void)stopMovementTimer;
-(void)startEnergyTimer;
-(void)stopEnergyTimer;

// Initialization method
-(void)initializeGame;

// Reset method
-(void)resetGame;

// Start game method
-(void)startGame;

// Game won method
-(void)wonGame;

// Game lost method
-(void)lostGame;

// Increment energy
-(void)incrementEnergy;

// Calculate average energy method
-(void)calculateAvgEnergy;

// Ball movement method
-(void)moveBall;

@end

