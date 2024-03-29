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

// Define the timer objects
@property (strong) NSTimer* movementTimer;
@property (strong) NSTimer* energyTimer;
@property (strong) NSTimer* animationTimer;

// Define the model objects
@property (strong) BallModel* ball;
@property (strong) AppDataModel* appData;

/* Define the storyboard objects to be interacted with */

// Background image views (tiles)
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

// Visible view objects
@property (weak) IBOutlet UIView* viewTop;
@property (weak) IBOutlet UIView* viewCenter;
@property (weak) IBOutlet UIView* viewBottom;

// Imageview objects
@property (strong) UIImageView* backgroundImageView;
@property (strong) UIImageView* ballImageView;
@property (strong) UIImageView* blobImageView;

// Labels
@property (weak) IBOutlet UILabel* scoreLabel;
@property (weak) IBOutlet UILabel* avgEnergyLabel;
@property (weak) IBOutlet UILabel* currEnergyLabel;
@property (weak) IBOutlet UILabel* difficultyLabel;

// Switch
@property (weak) IBOutlet UISwitch* gameSwitch;

// Slider
@property (weak) IBOutlet UISlider* randSlider;

// Buttons
@property (weak) IBOutlet UIButton* resetBtn;
@property (weak) IBOutlet UIButton* pauseBtn;
@property (weak) IBOutlet UIButton* highscoresBtn;

/*** Instance methods ***/
// Configure UI Elements
-(void)configureUIElements;

// Switch actions
-(IBAction)gameSwitchChanged;

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
-(void)startAnimationTimer;
-(void)stopAnimationTimer;

// Initialization method
-(void)initializeGame;

// Game reset method
-(void)resetGame;
// Game start method
-(void)startGame;
// Game won method
-(void)wonGame;
// Game lost method
-(void)lostGame;
// Determine game difficulty method
-(void)determineGameDifficulty;

// Increment energy method
-(void)incrementEnergy;
// Calculate average energy method
-(void)calculateAvgEnergy;

// Ball movement method
-(void)moveBall;

// Ball start animation method
-(void)startBallAnimation;
// Ball stop animation method
-(void)stopBallAnimation;

@end

