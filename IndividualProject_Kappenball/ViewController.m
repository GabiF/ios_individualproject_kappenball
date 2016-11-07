//
//  ViewController.m
//  IndividualProject_Kappenball
//
//  Created by Gabriel Flueran on 05/11/2016.
//  Copyright © 2016 Gabriel Flueran. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// define the movement constants
static const float DT = 0.1;
static const float DECAY = 0.95;
static const float Y_VELOCITY = 0.75;
static const float X_ACCELERATION = 1.3;

static const float BLOB_WIDTH = 28.0;
static const float BLOB_HEIGHT = 28.0;

static const float TIMER_MOVEMENT_RATE = 0.02;
static const float TIMER_ENERGY_RATE = 0.02;

/* Instance methods */

/* 
 @Name:
 @Params:
 @Return:
 @Description:
 
 */
-(void)configureUIElements
{
    // Configure the slider
    // get the current image dimensions
    UIImage* currentImag = [self.randSlider currentThumbImage];
    NSLog(@"%f,%f",currentImag.size.width,currentImag.size.height);
    // set the new thumb image
    UIImage* sliderImag = [UIImage imageNamed:@"slider.png"];
    [self.randSlider setThumbImage:sliderImag forState:UIControlStateNormal];
    // set the new track tint colours
    [self.randSlider setMinimumTrackTintColor:[UIColor redColor]];
    
}


/* 
 @Name: initializeGame
 @Params:
 @Return: void
 @Description: Initialization method. 
               To be called each time the ball hits a spike / you score a goal
 */
-(void)initializeGame
{
    // Initialize the ball model
    self.ball.xCoord = self.viewCenter.frame.size.width / 2.0;
    self.ball.yCoord = 0.0;
    
    // Initialize the appData model
    self.appData.currentEnergy = 0;
    self.appData.xVelocity = 0.0;
    self.appData.acceleration = 0.0;
}

/*
 @Name: resetGame
 @Params:
 @Return: void
 @Description: Reset game method. 
               To be called each time the game is reset (RESET button pressed)
 */
-(void)resetGame
{
    // Reset the flag - Game is not running
    self.gameRunning = NO;
    
    [self initializeGame];
    self.appData.totalEnergy = 0;
    self.appData.noOfPlays = 0;
    self.appData.score = 0;
    self.appData.avgEnergy = 0;
}

// Start game method
-(void)startGame
{
    [self startMovementTimer];
}

// Game won method
-(void)wonGame
{
    // Increment the score
    self.appData.score = self.appData.score + 1;
    // Update total energy, number of games played
    self.appData.totalEnergy = self.appData.totalEnergy + self.appData.currentEnergy;
    self.appData.noOfPlays = self.appData.noOfPlays + 1;
    // Calculate average energy
    [self calculateAvgEnergy];
    
    // Initialize the game
    [self initializeGame];
}

// Game lost method
-(void)lostGame
{
    // Update total energy, number of games played
    self.appData.totalEnergy = self.appData.totalEnergy + self.appData.currentEnergy;
    self.appData.noOfPlays = self.appData.noOfPlays + 1;
    // Calculate average energy
    [self calculateAvgEnergy];
    
    // Initialize the game
    [self initializeGame];
}

// Slider actions
-(IBAction)randSliderChanged
{
    // Get the value of the slider and store it in the appData randomness variable
    self.appData.randomness = self.randSlider.value;
}

// Buttons actions
-(IBAction)resetBtnPressed
{
    // Stop the movement timer
    [self stopMovementTimer];
    
    // Reset the used data models + controller variables
    [self resetGame];
    
    // Set the button's title to "START"
    [self.pauseBtn setTitle:@"START" forState:UIControlStateNormal];
}

-(IBAction)pauseBtnPressed
{
    // Determine if the pause button is in its initial/reset state ("Start")
    if([self.pauseBtn.currentTitle compare:@"START"] == NSOrderedSame)
    {
        // -- Pause button in "START" state
        // Set the flag - Game is running
        self.gameRunning = YES;
        
        // Start the game
        [self startGame];
        
        // Set the button's title to "PAUSE"
        [self.pauseBtn setTitle:@"PAUSE" forState:UIControlStateNormal];
    }
    else
    {   // -- Pause button NOT in "START" state
        // Determine what is the status of the pause button ("Pause" or "Resume")
        if([self.pauseBtn.currentTitle compare:@"PAUSE"] == NSOrderedSame)
        {
            // -- Pause button in "PAUSE" state
            // Freeze the timer
            [self stopMovementTimer];
            
            // Reset the flag - Game is not running
            self.gameRunning = NO;
            
            // Set the button's title to "RESUME"
            [self.pauseBtn setTitle:@"RESUME" forState:UIControlStateNormal];
        }
        else
        {
            // Pause button in "RESUME" state
            // Restart the timer
            [self startMovementTimer];
            
            // Set the flag - Game is running
            self.gameRunning = YES;
            
            // Set the button's title to "PAUSE"
            [self.pauseBtn setTitle:@"PAUSE" forState:UIControlStateNormal];
        }
    }
}

// GABI: method to be implemented
-(IBAction)highscoresBtnPressed
{
    // empty
}

// Timer methods (could be reduced to just two generic methods)
// GABI: method could be improved
-(void)startMovementTimer
{
    if(!(self.movementTimer.isValid))
    {
        self.movementTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_MOVEMENT_RATE target:self selector:@selector(moveBall) userInfo:nil repeats:YES];
    }
}
// GABI: method could be improved
-(void)stopMovementTimer
{
    [self.movementTimer invalidate];
}

// GABI: method could be improved
-(void)startEnergyTimer
{
    if(!(self.energyTimer.isValid))
    {
        self.energyTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_ENERGY_RATE target:self selector:@selector(incrementEnergy) userInfo:nil repeats:YES];
    }
}
// GABI: method could be improved
-(void)stopEnergyTimer
{
    [self.energyTimer invalidate];
}

-(void)incrementEnergy
{
    self.appData.currentEnergy = self.appData.currentEnergy + 1;
}

-(void)calculateAvgEnergy
{
    self.appData.avgEnergy = self.appData.totalEnergy / self.appData.noOfPlays;
}

-(void)moveBall
{
    // NOTE: So here I only calculate (and verify) the new values and update the model, which will possibly fire the observeValueForKeyPath method
    
    // Calculate the new x and new y
    // determine the new random behaviour on x-axis (rand in [-50.0,50.0])
    float rand = (arc4random() % 41) - 20.0;
    // determine new x-axis velocity
    self.appData.xVelocity = self.appData.xVelocity * DECAY + self.appData.acceleration + self.appData.randomness * rand;
    
    // calculate new x
    float newX = self.ball.xCoord + self.appData.xVelocity * DT;
    // calculate new y
    float newY = self.ball.yCoord + Y_VELOCITY;
    
    // Create a new rectangle that represents the next position of the ball imageview
    CGRect newBallRect = CGRectMake(newX-(self.ballImageView.frame.size.width/2), newY-(self.ballImageView.frame.size.height/2), self.ballImageView.frame.size.width, self.ballImageView.frame.size.height);
    
    // Verify if the potential new position of the ball would interact with walls, spikes or goals
    // check if any of the goals is reached
    if(CGRectIntersectsRect(newBallRect, self.viewGoalLeft.frame)||CGRectIntersectsRect(newBallRect, self.viewGoalRight.frame))
    {
        // - Ball reached one of the goals
        // GAME WON
        [self wonGame];
    }
    else
    {
        // check if any of the spikes are hit
        if(CGRectIntersectsRect(newBallRect, self.viewSpikesLeft.frame)||CGRectIntersectsRect(newBallRect, self.viewSpikesCenter.frame)||CGRectIntersectsRect(newBallRect, self.viewSpikesRight.frame))
        {
            // - Ball hit the spikes
            // GAME LOST
            [self lostGame];
        }
        else
        {
            // check if any of the walls is hit
            if(CGRectIntersectsRect(newBallRect, self.viewWallLeft.frame)||CGRectIntersectsRect(newBallRect, self.viewWallRight.frame)
               ||CGRectIntersectsRect(newBallRect, self.viewGoalLeftWallLeft.frame)||CGRectIntersectsRect(newBallRect, self.viewGoalLeftWallRight.frame)
               ||CGRectIntersectsRect(newBallRect, self.viewGoalRightWallLeft.frame)||CGRectIntersectsRect(newBallRect, self.viewGoalRightWallRight.frame))
            {
                // -- Ball hit one of the walls
                // BALL BOUNCES BACK FROM THE WALL
                self.appData.xVelocity = -self.appData.xVelocity;
                // calculate new x
                newX = self.ball.xCoord + self.appData.xVelocity * DT;
            }
            self.ball.xCoord = newX;
            self.ball.yCoord = newY;

        }
    }    
}

// NOTE: so this is the method that says "Look at x and y and see if they change". if they do, call **
-(void)connectBallModel:(BallModel*)ball
{
    [ball addObserver:self forKeyPath:@"xCoord" options:NSKeyValueObservingOptionNew context:nil];
    [ball addObserver:self forKeyPath:@"yCoord" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)connectAppDataModel:(AppDataModel*)appData
{
    [appData addObserver:self forKeyPath:@"score" options:NSKeyValueObservingOptionNew context:nil];
    [appData addObserver:self forKeyPath:@"avgEnergy" options:NSKeyValueObservingOptionNew context:nil];
    [appData addObserver:self forKeyPath:@"currentEnergy" options:NSKeyValueObservingOptionNew context:nil];
}

// ** this method is called automatically
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // NOTE: and here is where I do the visual updates on the view
    // it's like a communication:
    /*
     C -> M: make this changes
     M: making the changes
     M -> C: I made the changes, you have to do your thing cause things changed in my fields
     C: ok, doing the visual changes
     */ //TODO: delete these comments
    
    // Check if one of the values in the ball model has changed
    if(([keyPath compare:@"xCoord"] == NSOrderedSame) || ([keyPath compare:@"yCoord"] == NSOrderedSame))
    {
        // If yes, then update the position of the ball on the screen
        CGPoint ballCenter = CGPointMake(self.ball.xCoord, self.ball.yCoord);
        self.ballImageView.center = ballCenter;
    }
    
    // Check if one of the values in the appData model has changed
    if([keyPath compare:@"score"] == NSOrderedSame)
    {
        // If yes, then update the value in the score label
        self.scoreLabel.text = [NSString stringWithFormat:@"%d",self.appData.score];
    }
    if([keyPath compare:@"avgEnergy"] == NSOrderedSame)
    {
        // If yes, then update the value in the average energy label
        self.avgEnergyLabel.text = [NSString stringWithFormat:@"%d",self.appData.avgEnergy];
    }
    if([keyPath compare:@"currentEnergy"] == NSOrderedSame)
    {
        // If yes, then update the value in the current energy label
        self.currEnergyLabel.text = [NSString stringWithFormat:@"%d",self.appData.currentEnergy];
    }
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Interpret the touches only if the game is running
    if(self.gameRunning)
    {
        UITouch* touch = [touches anyObject];
        
        if([[touch view] isEqual:self.viewCenter])
        {
            CGPoint touchPoint = [touch locationInView:self.viewCenter];
            
            // Show the blob at the current touch point
            self.blobImageView.center = touchPoint;
            self.blobImageView.alpha = 0.8;
            
            // Hide the mouse cursor
//            [NSCursor hide];
            
            // Determine the position of the touch w.r.t. the current position of the ball
            CGPoint ballCenter = CGPointMake(self.ball.xCoord, self.ball.yCoord);
            
            if(touchPoint.x < ballCenter.x)
            {
                // The touch was on the LHS of the ball
                self.appData.acceleration = X_ACCELERATION;
            }
            else
            {
                // The touch was on the RHS of the ball
                self.appData.acceleration = -X_ACCELERATION;
            }
            
            // Set up a timer to increment the current energy used
            [self startEnergyTimer];
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // Interpret the touches only if the game is running
    if(self.gameRunning)
    {
        UITouch* touch = [touches anyObject];
        
        if([[touch view] isEqual:self.viewCenter])
        {
            CGPoint touchPoint = [touch locationInView:self.viewCenter];
            // Move the position of the blob to the current touch point
            self.blobImageView.center = touchPoint;
        }
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // Interpret the touches only if the game is running
    if(self.gameRunning)
    {
        // Hide the blob
        self.blobImageView.alpha = 0.0;
        
        // Acceleration is 0 as there is no more touch on the screen
        self.appData.acceleration = 0.0;
        
        // Stop the timer which increments the current energy used
        [self stopEnergyTimer];
    }
}

/* Predefined methods (editable) */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.ball = [[BallModel alloc]initWithX:(self.viewCenter.frame.size.width / 2.0) Y:0.0];
    [self connectBallModel:self.ball];
    self.appData = [[AppDataModel alloc]init];
    [self connectAppDataModel:self.appData];
    
    // Create the background imageview
    CGRect backgroundRect = CGRectMake(0.0, 0.0, self.viewCenter.frame.size.width, self.viewCenter.frame.size.height);
    UIImage* backgroundImag = [UIImage imageNamed:@"field.png"];
    UIImageView* background = [[UIImageView alloc]initWithFrame:backgroundRect];
    [background setImage:backgroundImag];
    // Set the backgroundImageView of the viewcontroller to be the above one and add it to the view
    self.backgroundImageView = background;
    [self.viewCenter addSubview:self.backgroundImageView];
    
    // Create the ball imageview
    UIImage* ballImag = [UIImage imageNamed:@"ball.png"];
    UIImageView* ball = [[UIImageView alloc]initWithImage:ballImag];
    // Set the ballImageView of the viewcontroller to be the above one and add it to the view
    self.ballImageView = ball;
    [self.viewCenter addSubview:self.ballImageView];
    
    // Create the blob imageview
    CGRect blobRect = CGRectMake(self.viewCenter.frame.size.width / 2.0, self.viewCenter.frame.size.height / 2.0, BLOB_WIDTH, BLOB_HEIGHT);
    UIImage* blobImag = [UIImage imageNamed:@"blob.png"];
    UIImageView* blob = [[UIImageView alloc]initWithFrame:blobRect];
    [blob setImage:blobImag];
    blob.alpha = 0.0;
    // Set the blobImageView of the viewcontroller to be the above one and add it to the view
    self.blobImageView = blob;
    [self.viewCenter addSubview:self.blobImageView];
    
    // Call the UI elements configuration methods
    [self configureUIElements];
    
    // Reset all the data models variables & flags
    [self resetGame];
    
    // Set the default value for the slider to be 0.0
    self.randSlider.value = self.appData.randomness;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

// Override the method to set the preferred orientation style to landscape.
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // This will make the application run by default in landscape mode
    return UIInterfaceOrientationLandscapeLeft;
}

@end
