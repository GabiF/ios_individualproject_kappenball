//
//  ViewController.m
//  IndividualProject_Kappenball
//
//  Created by Gabriel Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import "ViewController.h"

#define GAME_SCREEN_WIDTH    1024
#define GAME_SCREEN_HEIGHT   610

@interface ViewController ()

@end

@implementation ViewController

/* Instance methods */

// Slider actions
-(IBAction)randSliderChanged
{
    // Get the value of the slider and store it in the appData randomness variable
    self.appData.randomness = self.randSlider.value;
    
    // Calculate the new coordinates of the ball
    
    
    // Move the ball
    
    // Update the interface (labels, slider)
//    [self updateInterface];
}

// Buttons actions
-(IBAction)resetBtnPressed
{
    // Initialize all the variables
}

-(IBAction)pauseBtnPressed
{
    // Determine what is the status of the pause button ("Pause" or "Resume")
    if([self.pauseBtn.currentTitle compare:@"PAUSE"] == NSOrderedSame)
    {
        // Freeze the timer
        [ViewController stopTimer:self.movementTimer];
        
        // set the button's title to "RESUME"
        [self.pauseBtn setTitle:@"RESUME" forState:UIControlStateNormal];
    }
    else
    {
        [ViewController startTimer:self.movementTimer];
        
        // set the button's title to "PAUSE"
        [self.pauseBtn setTitle:@"PAUSE" forState:UIControlStateNormal];
    }
}

-(IBAction)highscoresBtnPressed
{
    // empty
}

// Initialization method
-(void)initializeVariables
{
    
}

// Interface update method
-(void)updateInterface
{
    
}

/* Class methods */

// Timer methods
+(void)startTimer:(NSTimer*)target
{
    if(!(target.isValid))
    {
        target = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(update) userInfo:nil repeats:YES];
    }
}

+(void)stopTimer:(NSTimer*)sender
{
    [sender invalidate];
}


/* Predefined methods (editable) */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ball = [[BallModel alloc]initWithX:(GAME_SCREEN_WIDTH/2.0) Y:0.0];
    self.appData = [[AppDataModel alloc]init];
    
    // Create the background imageview
    CGRect backgroundRect = CGRectMake(0.0, 0.0, GAME_SCREEN_WIDTH, GAME_SCREEN_HEIGHT);
    UIImage* backgroundImag = [UIImage imageNamed:@"field.png"];
    
    UIImageView* background = [[UIImageView alloc]initWithFrame:backgroundRect];
    [background setImage:backgroundImag];
    // Set the backgroundImageView of the viewcontroller to be the above one and add it to the view
    self.backgroundImageView = background;
    [self.viewCenter addSubview:self.backgroundImageView];
    
    UIImage* ballImag = [UIImage imageNamed:@"ball.png"];
    UIImageView* ball = [[UIImageView alloc]initWithImage:ballImag];
    // Set the ballImageView of the viewcontroller to be the above one and add it to the view
    self.ballImageView = ball;
    [self.viewCenter addSubview:self.ballImageView];
    
    [self initializeVariables];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
