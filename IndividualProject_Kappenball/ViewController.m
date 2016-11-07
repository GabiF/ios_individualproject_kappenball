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

/*** Class constants ***/

// Movement constants
static const float DT = 0.1;
static const float DECAY = 0.95;
static const float Y_VELOCITY = 0.75;
static const float X_ACCELERATION = 1.3;

// Blob dimensions constants
static const float BLOB_WIDTH = 28.0;
static const float BLOB_HEIGHT = 28.0;

// Timers constants
static const float TIMER_MOVEMENT_RATE = 0.02;
static const float TIMER_ENERGY_RATE = 0.02;
static const float TIMER_ANIMATION_RATE = 0.02;

/*** Instance methods ***/

/** User Interface - related methods **/

/*
 @Name: configureUIElements
 @Params:
 @Return:
 @Description: UI elements configuration method.
To be called in appDidLoad method, after all initializations
 */
-(void)configureUIElements
{
    // Configure the slider
    
    // set the new thumb image
    UIImage* sliderImag = [UIImage imageNamed:@"slider.png"];
    [self.randSlider setThumbImage:sliderImag forState:UIControlStateNormal];
    // set the new track tint colours
    [self.randSlider setMinimumTrackTintColor:[UIColor redColor]];
    // set the default value for the slider to be 0.0
    self.randSlider.value = self.appData.randomness;
    
    // Configure the switch
    [self.gameSwitch setTintColor:[UIColor redColor]];
}

/*
 @Name: preferredInterfaceOrientationForPresentation
 @Params:
 @Return: UIInterfaceOrientation enum value
 @Description: Method override meant to set the preferred orientation style to landscape.
 To be called in appDidLoad method, before all initializations
 */
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    // This will make the application run by default in landscape mode
    return UIInterfaceOrientationLandscapeLeft;
}

/* Slider actions */

/*
 @Name: randSliderChanged
 @Params:
 @Return:
 @Description: RANDOMNESS slider changed method.
 To be set as the sliderChanged ACTION of the randomness slider
 */
-(IBAction)randSliderChanged
{
    // Get the value of the slider and store it in the appData randomness variable
    self.appData.randomness = self.randSlider.value;
}

/* Buttons actions */

/*
 @Name: resetBtnPressed
 @Params:
 @Return:
 @Description: RESET button pressed method.
 To be set as the buttonPressed ACTION of the reset button
 */
-(IBAction)resetBtnPressed
{
    // Stop the movement timer
    [self stopMovementTimer];
    
    // Reset the used data models + controller variables
    [self resetGame];
    
    // Set the button's title to "START"
    [self.pauseBtn setTitle:@"START" forState:UIControlStateNormal];
}

/*
 @Name: pauseBtnPressed
 @Params:
 @Return:
 @Description: START/PAUSE/RESUME button pressed method
 To be set as the buttonPressed ACTION of the start/pause/resume button.
 */
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

/*
 @Name: highscoresBtnPressed
 @Params:
 @Return:
 @Description: HIGHSCORES button pressed method
 To be set as the buttonPressed ACTION of the highscores button.
 */
-(IBAction)highscoresBtnPressed
{
    // empty
    //TODO: to be implemented
}

/** Game functionality methods **/

/* Initialization methods */

/*
 @Name: initializeGame
 @Params:
 @Return:
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
 @Return:
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

/* Game outcomes methods */

/*
 @Name: startGame
 @Params:
 @Return:
 @Description: Start game method.
 To be called each time the game is started (START button pressed)
 */
// Start game method
-(void)startGame
{
    [self startMovementTimer];
}

/*
 @Name: wonGame
 @Params:
 @Return:
 @Description: Game won method.
 To be called when the ball touches the bottom of a goal
 */
-(void)wonGame
{
    // Increment the score
    self.appData.score = self.appData.score + 1;
    
    // Calculate average energy
    [self calculateAvgEnergy];
    
    // Initialize the game
    [self initializeGame];
}

/*
 @Name: lostGame
 @Params:
 @Return:
 @Description: Game lost method.
 To be called when the ball hits a region with spikes
 */
-(void)lostGame
{
    // Calculate average energy
    [self calculateAvgEnergy];
    
    // Invalidate the ball movement timer
    [self stopMovementTimer];
    
    // Start ball animation
    [self startBallAnimation];
}

/* Ball-related methods */

/*
 @Name: startBallAnimation
 @Params:
 @Return:
 @Description: Start ball animation method.
 To be called at the end of the lostGame method
 */
-(void)startBallAnimation
{
    // Set animation duration
    [self.ballImageView setAnimationDuration:0.8];
    // Set animation no of repetitions
    [self.ballImageView setAnimationRepeatCount:1];
    // Start the animation
    [self.ballImageView startAnimating];
    
    // Create an animation timer to check whether the animation has stopped
    [self startAnimationTimer];
}

/*
 @Name: stopBallAnimation
 @Params:
 @Return:
 @Description: Stop ball animation method.
 To be added as the SELECTOR for the animationTimer
 */
-(void)stopBallAnimation
{
    // Check if ball animation stopped
    if(![self.ballImageView isAnimating])
    {
        // -- Ball animation stopped
        // Stop animation timer
        [self stopAnimationTimer];
        
        // Start movement timer
        [self startMovementTimer];
        
        // Initialize the game
        [self initializeGame];
    }
    
}

/*
 @Name: moveBall
 @Params:
 @Return:
 @Description: Ball movement (x and y coordinates) calculation, verification and update method.
 To be added as the SELECTOR for the movementTimer
 @NOTE: Here I only calculate (and verify) the new values and update the model, which will possibly fire the observeValueForKeyPath method
 */

-(void)moveBall
{
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

/** Timer methods  **/
// NOTE: could be reduced to just two generic methods

//TODO: method could be improved
-(void)startMovementTimer
{
    if(!(self.movementTimer.isValid))
    {
        self.movementTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_MOVEMENT_RATE target:self selector:@selector(moveBall) userInfo:nil repeats:YES];
    }
}
//TODO: method could be improved
-(void)stopMovementTimer
{
    [self.movementTimer invalidate];
}

//TODO: method could be improved
-(void)startEnergyTimer
{
    if(!(self.energyTimer.isValid))
    {
        self.energyTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_ENERGY_RATE target:self selector:@selector(incrementEnergy) userInfo:nil repeats:YES];
    }
}
//TODO: method could be improved
-(void)stopEnergyTimer
{
    [self.energyTimer invalidate];
}
//TODO: method could be improved
-(void)startAnimationTimer
{
    if(!(self.animationTimer.isValid))
    {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_ANIMATION_RATE target:self selector:@selector(stopBallAnimation) userInfo:nil repeats:YES];
    }
}
//TODO: method could be improved
-(void)stopAnimationTimer
{
    [self.animationTimer invalidate];
}

/** APPLICATION DATA MODEL methods **/

/*
 @Name: incrementEnergy
 @Params:
 @Return:
 @Description: Increment energy method.
 To be set as the SELECTOR for the energyTimer
 */
-(void)incrementEnergy
{
    self.appData.currentEnergy = self.appData.currentEnergy + 1;
}

/*
 @Name: calculateAvgEnergy
 @Params:
 @Return:
 @Description: Average energy calculation method.
 To be called in wonGame and lostGame methods
 */
-(void)calculateAvgEnergy
{
    // Update total energy, number of games played
    self.appData.totalEnergy = self.appData.totalEnergy + self.appData.currentEnergy;
    self.appData.noOfPlays = self.appData.noOfPlays + 1;
    // Calculate average energy based on total energy and no. of games played
    self.appData.avgEnergy = self.appData.totalEnergy / self.appData.noOfPlays;
}

/** Data models observer methods **/

/* Observer creation methods */
// NOTE: These are the methods that say "Look at these data model variables and see if they change". If they do, call the observer method.

/*
 @Name: connectBallModel
 @Params: (BallModel*)ball
 @Return:
 @Description: Ball model observer creation method.
 To be called in viewDidLoad method of this ViewController
 */
-(void)connectBallModel:(BallModel*)ball
{
    [ball addObserver:self forKeyPath:@"xCoord" options:NSKeyValueObservingOptionNew context:nil];
    [ball addObserver:self forKeyPath:@"yCoord" options:NSKeyValueObservingOptionNew context:nil];
}

/*
 @Name: connectAppDataModel
 @Params: (AppDataModel*)appData
 @Return:
 @Description: App model observer creation method.
 To be called in viewDidLoad method of this ViewController
 */
-(void)connectAppDataModel:(AppDataModel*)appData
{
    [appData addObserver:self forKeyPath:@"score" options:NSKeyValueObservingOptionNew context:nil];
    [appData addObserver:self forKeyPath:@"avgEnergy" options:NSKeyValueObservingOptionNew context:nil];
    [appData addObserver:self forKeyPath:@"currentEnergy" options:NSKeyValueObservingOptionNew context:nil];
}

/* ViewController observer method */

/*
 @Name: observeValueForKeyPath
 @Params: default ones
 @Return:
 @Description: ViewController observer method.
 This method is called AUTOMATICALLY when one of the watched variables changes its value.
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // NOTE: here is where I must do the visual updates on the view
    
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

/** Methods that deal with screen touches **/

/*
 @Name: touchesBegan
 @Params: default ones
 @Return:
 @Description:
 */
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

/*
 @Name: touchesMoved
 @Params: default ones
 @Return:
 @Description:
 */
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

/*
 @Name: touchesEnded
 @Params: default ones
 @Return:
 @Description:
 */
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

/*
 @Name: touchesCancelled
 @Params: default ones
 @Return:
 @Description:
 */
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // empty
    //TODO: to be implemented
}

/** Predefined methods **/
// NOTE: methods are editable

/*
 @Name: viewDidLoad
 @Params:
 @Return:
 @Description: View (owned by current view controller) loaded
 This method is called AUTOMATICALLY when the current ViewController loaded.
 */
-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self preferredInterfaceOrientationForPresentation];
    
    // Create the ball and appData models and connect the observer with the variables to be watched
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
    NSMutableArray* ballImages = [[NSMutableArray alloc]init];
    for(int i=2; i<=5; i++)
    {
        UIImage* ballImag = [UIImage imageNamed:[NSString stringWithFormat:@"ball%d.png",i]];
        [ballImages addObject:ballImag];
    }
    UIImageView* ball = [[UIImageView alloc]initWithImage:[ballImages objectAtIndex:0]];
    [ball setAnimationImages:ballImages];
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
}

/*
 @Name: didReceiveMemoryWarning
 @Params:
 @Return:
 @Description:
 This method is called AUTOMATICALLY when the application received a memory warning.
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

@end
