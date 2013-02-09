//
//  InstructionUnit.h
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Calculator.h"

#define PI_STRING @"3.14159265358979323846264338327950288"
#define NUM_ALPHA_REGS 'z' - 'a' + 1

// The register array is a dictionary with numeric keys. Any number may be used, but some are special
// Registers 0-25 are the alpha registers. 25-31 are the statistical registers. All of these may be 
// loaded or stored with keys on the calculator. Additionally the statistical registers are updated
// using the SUM and SUM_MINUS keys. Negative register indexes are for internal use. There is no
// restriction in storing to them, but they may be destroyed by internal functions. Additionally,
// registers -1 to -5 have special meaning as described below.
#define SUM_FIRST 26
#define SUM_LAST 31

#define REG_INDEX -1            // i register, used to index other registers
#define REG_IND_I -2            // (i) - sto/rcl register indexed by i
#define REG_IND_I_POST_INC -3   // (i++) - sto/rcl register indexed by i then increment i
#define REG_IND_I_PRE_DEC -4    // (--i) - decrement i then sto/rcl register indexed by i
#define REG_IND_X -5            // (x) sto/rcl register indexed by x then pop the x register

// Statistical registers are:
#define STAT_N 26
#define STAT_SUM_X 27
#define STAT_SUM_Y 28
#define STAT_SUM_X_2 29
#define STAT_SUM_Y_2 30
#define STAT_SUM_X_Y 31

#define PROG_SUM @"1; STO_ADD:26; ROLL_DN; STO:-10; EXCH; STO_MUL:-10; STO_ADD:28; X_SQUARED; STO_ADD:30;" \
                  "EXCH; STO_ADD:27; X_SQUARED; STO_ADD:29; RCL:-10; STO_ADD:31; RCL:26"

#define PROG_SUM_MINUS @"1; STO_SUB:26; ROLL_DN; STO:-10; EXCH; STO_MUL:-10; STO_SUB:28; X_SQUARED; STO_SUB:30;" \
                        "EXCH; STO_SUB:27; X_SQUARED; STO_SUB:29; RCL:-10; STO_SUB:31; RCL:26"

@class NumberConverter;
@class ExecutionUnit;
@class ProgramStore;

@interface InstructionUnit : NSObject {
    Calculator* m_calculator;
    NSMutableDictionary* m_registers;
    Number *m_x, *m_y, *m_z, *m_t, *m_lastX;
    
    InputModeType m_inputMode;
    NSString* m_inputPrompt;
    int m_inputReg;
    
    ModeType m_mode;
    BaseType m_base;
    DispType m_disp;
    int m_dispSignificantDigits;
    NumberConverter* m_numberConverter;
    StatusType m_lastStatus;
    BOOL m_numberJustSet;

    // This is set to NO when the stack should not be lifted before
    // the operation. Normally entering the first numeric key lifts the
    // stack. But this is not done if (for instance) the last key pressed
    // was ENTER.
    //
    // Operations that clear m_enableLift:
    //
    //  ENTER, SUMMATION, SUMMATION_MINUS, CLEAR_X
    //
    // Operations that leave the status as it was:
    //
    //  - Changing mode, disp, and base
    //  - CLEAR_VARS, CLEAR_SUM
    //  - Number entry and editing
    //  
    // All other operations set this flag to YES
    BOOL m_enableLift;
}

@property(readonly) ModeType mode;
@property(readonly) BaseType base;
@property(readonly) DispType disp;
@property(readonly) int dispSignificantDigits;
@property(readonly) Number* x;
@property(readonly) Number* y;
@property(readonly) Number* z;
@property(readonly) Number* t;
@property(readonly) Number* lastX;
@property(readonly) StatusType lastStatus;
@property(readonly) NSString*inputPrompt;
@property(readonly) InputModeType inputMode;

- (id)initWithCalculator:(Calculator*) calculator;

- (void)op:(OperationType) operation;
- (void)op:(OperationType) operation withParams:(NSArray*) params;

- (NSArray*)conversionTypes;
- (NSArray*)conversionsForClass:(int) clas index:(int) indx;
- (void)convertWithClass:(int) clas fromIndex:(int) fromIndex toIndex:(int) toIndex;

- (void)setXFromString:(NSString*) string;
- (void)setXFromNumber:(Number*) number;
- (void)enter:(BOOL) ignoreLift;
- (Number*)numberFromReg:(int) reg;
- (void)inputComplete:(BOOL) accept;

@end
