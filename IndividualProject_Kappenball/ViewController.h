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
// define the timer object
@property (strong) NSTimer* movementTimer;

// define the model objects
@property (strong) BallModel* ball;
@property (strong) AppDataModel* appData;



// define the storyboard objects to be interacted with

// view objects
@property (weak) IBOutlet UIView* viewTop;
@property (weak) IBOutlet UIView* viewCenter;
@property (weak) IBOutlet UIView* viewBottom;

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

// Initialization method
-(void)initializeVariables;

// Interface update method
-(void)updateInterface;

/* Class methods */
// Timer methods
+(NSTimer*)startTimer;
+(void)stopTimer:(NSTimer*)sender;

@end

