//
//  ExecutionUnit.h
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Calculator.h"

#define PAUSE_TIME 1
#define NUM_EXECUTE_LOOP 500 // Number of time to call executeNext before returning for key service

// Types of blocks on the block stack
typedef enum { BLOCK_LOOP, BLOCK_IF, BLOCK_CALL } BlockType;
typedef enum { XS_NORMAL, XS_ERROR, XS_DONE, XS_PAUSE, XS_INPUT } ExecutionStatusType;

@interface ExecutionUnit : NSObject {
    Calculator* m_calculator;
    
    // m_loopStack holds nested loop values. Each entry is a dictionary with:
    //
    //  i: previous value of i register
    //  n: total iterations
    //
    // If dictionary is empty, this is an infinite loop
    NSMutableArray* m_loopStack;

    // m_blockStack holds nested block values. Each entry is a dictionary with:
    //
    //  ip:     current instruction pointer (NSNumber)
    //  inst:   compiled instructions (NSArray)
    //  type:   type of block (NSNumber)
    //
    // 'type' is the type of block stored as a BlockType enumerant, which is 
    // important to know what to do when the block is finished. Values are:
    //
    //  LOOP:   OP_FOR or OP_DO loop
    //  IF:     OP_IF or OP_ELSE block
    //  CALL:   OP_CALL or top-level block
    //
    // This stack holds previous values, values of the currently executing
    // block are in 'inst' and 'ip'
    NSMutableArray* m_blockStack;
    
    NSArray* m_inst;
    int m_ip;
    BlockType m_type;
    NSUInteger m_executingFunction, m_executingInstruction;
    BOOL m_debug;
    RunStateType m_runState;
    BOOL m_stepping;
    
    NSTimer* m_executionTimer;

    NSString* m_inputTitle;
}

@property(readonly) RunStateType runState;
@property(readonly) BOOL stepping;
@property(readonly) NSString* inputTitle;
@property(readonly) NSUInteger executingFunction;
@property(readonly) NSUInteger executingInstruction;

- (id)initWithCalculator:(Calculator*) calculator;

+ (OperationType)operationFromString:(const NSString*) string;
+ (NSString*) stringFromOperation:(OperationType) operation;
+ (NSString*) stringFromReg:(int) reg;

// Instruction execution is asynchronous. setupExecutionWithInstructions sets up
// execution to run from the start of the passed instructions
- (void)setupExecutionForFunction:(NSUInteger) function withInstructions:(NSArray*) instructions debug:(BOOL) debug;

// Execute the next instruction. Returned status is:
- (ExecutionStatusType)executeNext;

- (BOOL)step;
- (void)run;
- (void)stop;

@end
