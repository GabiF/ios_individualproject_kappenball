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
static const float X_ACCELERATION = 15.0;

static const float BLOB_WIDTH = 40.0;
static const float BLOB_HEIGHT = 45.0;

/* Instance methods */

// Initialization method
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
// Reset method
-(void)resetGame
{
    // Game is not running
    self.gameRunning = NO;
    
    [self initializeGame];
    self.appData.totalEnergy = 0;
    self.appData.noOfPlays = 0;
    self.appData.score = 0;
    self.appData.avgEnergy = 0;
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
    // Stop the timer and wait for the "START" button to be pressed
    [self stopMovementTimer];
    
    // Initialize all the variables
    [self resetGame];
    
    // Set the button's title to "START"
    [self.pauseBtn setTitle:@"START" forState:UIControlStateNormal];
}

-(IBAction)pauseBtnPressed
{
    // Determine if the pause button is in its initial state ("Start")
    if([self.pauseBtn.currentTitle compare:@"START"] == NSOrderedSame)
    {
        // Game is running
        self.gameRunning = YES;
        
        // Start the game
        [self startMovementTimer];
        
        // Set the button's title to "PAUSE"
        [self.pauseBtn setTitle:@"PAUSE" forState:UIControlStateNormal];
    }
    else
    {
        // Determine what is the status of the pause button ("Pause" or "Resume")
        if([self.pauseBtn.currentTitle compare:@"PAUSE"] == NSOrderedSame)
        {
            // Freeze the timer
            [self stopMovementTimer];
            
            // Set the button's title to "RESUME"
            [self.pauseBtn setTitle:@"RESUME" forState:UIControlStateNormal];
        }
        else
        {
            // Restart the timer
            [self startMovementTimer];
            
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
        self.movementTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveBall) userInfo:nil repeats:YES];
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
        self.energyTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(incrementEnergy) userInfo:nil repeats:YES];
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
    // determine the new random behaviour on x-axis (rand in [-50.0,50.0]
    float rand = (arc4random() % 101) - 50.0;
    // determine new x-axis velocity
    float newXVelocity = self.appData.xVelocity * DECAY + self.appData.acceleration + self.appData.randomness * rand;
    // calculate new x
    float newX = self.ball.xCoord + newXVelocity * DT;
    // calculate new y
    float newY = self.ball.yCoord + Y_VELOCITY;
    
    // Determine if the new coordinates of the ball mean ball interacts with background: walls, spikes, holes
    if(newY < self.viewCenter.frame.size.height)
    {
        // well these values I have to get empirically, by trial-and-error. cause we don't know the exact coordinates of spikes, walls, holes
        // but I'll just make it go down until it reaches the bottom of the view, and then reset
        self.ball.xCoord = newX;
        self.ball.yCoord = newY;
    }
    else
    {   // GAME WON
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
    
}

// NOTE: so this is the method that says "Look at x and y and see if they change". if they do, call ** //TODO: delete this comment
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
    
    [self resetGame];
    
    // Set the default value for the slider to be 0.0
    self.randSlider.value = self.appData.randomness;
    
    // Set the default value for the labels to 0
//    self.scoreLabel.text = [NSString stringWithFormat:@"%d",self.appData.score];
//    self.avgEnergyLabel.text = [NSString stringWithFormat:@"%d",self.appData.avgEnergy];
//    self.currEnergyLabel.text = [NSString stringWithFormat:@"%d",self.appData.currentEnergy];
    
    // start the timer
//    self.movementTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(moveBall) userInfo:nil repeats:YES]; //TODO: remove this part of code
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
