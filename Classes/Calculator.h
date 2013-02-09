//
//  Calculator.h
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Number.h"

// Operations
typedef enum {
    OP_ADD, OP_SUB, OP_MUL, OP_DIV,
    OP_STO, OP_STO_ADD, OP_STO_SUB, OP_STO_MUL, OP_STO_DIV,
    OP_RCL, OP_RCL_ADD, OP_RCL_SUB, OP_RCL_MUL, OP_RCL_DIV,
    OP_ROLL_UP, OP_ROLL_DN, OP_ENTER, OP_EXCH, OP_DUP2, OP_OVER, OP_LAST_X,
    OP_CLR_X, OP_CLR_STACK, OP_CLR_VARS, OP_CLR_SUM, OP_CLR_PGM, OP_CLR_ALL,
    OP_PI, OP_NUM,
    OP_1_OVER_X, OP_SQRT, OP_X_SQUARED, OP_Y_TO_THE_X, OP_X_ROOT_OF_Y,
    OP_E_TO_THE_X, OP_LN, OP_10_TO_THE_X, OP_LOG, OP_2_TO_THE_X, OP_LOG_2,
    OP_X_FACTORIAL, OP_PCT, OP_DELTA_PCT,
    OP_SUM, OP_SUM_MINUS,
    OP_SIN, OP_COS, OP_TAN, OP_ARCSIN, OP_ARCCOS, OP_ARCTAN, 
    OP_SINH, OP_COSH, OP_TANH, OP_ARCSINH, OP_ARCCOSH, OP_ARCTANH, 
    OP_HEX_AND, OP_HEX_OR, OP_HEX_XOR, OP_HEX_NEG, OP_HEX_NOT, 
    OP_HEX_SHL, OP_HEX_SHR, OP_HEX_MOD, 
    OP_ROUND, OP_TRUNC, OP_FRAC, OP_ABS, OP_RAND, OP_SEED, 
    OP_IF, OP_ELSE, OP_THEN, OP_FOR, OP_DO, OP_BREAK, OP_BREAKIF, OP_LOOP,
    OP_FOR_START, OP_FOR_NEXT,
    OP_EQ, OP_NE, OP_GT, OP_GE, OP_LT, OP_LE,
    OP_CALL, OP_RET, OP_RETIF, 
    OP_DEF_FUNC, // dummy op to allow function name to be set
    OP_DEF_SUBR, // dummy op to allow subroutine name to be set
    OP_BASE_DEC, OP_BASE_HEX, OP_BASE_BIN, OP_BASE_OCT,
    OP_MODE_DEG, OP_MODE_RAD, OP_MODE_GRAD,
    OP_DISP_ALL, OP_DISP_FIX, OP_DISP_SCI, OP_DISP_ENG,
    OP_CNV_DEGC, OP_CNV_DEGF, OP_CNV_RAD, OP_CNV_DEG, OP_CNV_HMS, OP_CNV_H, OP_CNV_POLAR, OP_CNV_RECT,
    OP_CNV_UNITS,
    OP_X_MEAN, OP_Y_MEAN, OP_XW_MEAN, OP_PSD_X, OP_PSD_Y, OP_SSD_X, OP_SSD_Y,
    OP_C_N_R, OP_P_N_R,
    OP_SOLVE,
    OP_PAUSE, OP_INPUT,
    
    OP_ERROR, OP_NONE
} OperationType;

typedef enum { DEG, RAD, GRAD } ModeType;
typedef enum { RS_NONE, RS_RUNNING, RS_STOPPED, RS_PAUSED } RunStateType;
typedef enum { IM_NONE, IM_NUMBER, IM_DIGIT, IM_REG } InputModeType;

@class InstructionUnit;
@class ExecutionUnit;
@class ProgramStore;

@interface Calculator : NSObject {
    InstructionUnit* m_instructionUnit;
    ExecutionUnit* m_executionUnit;
    ProgramStore* m_programStore;
    
    ProgramStore* m_solveProgramStore;
    
    BOOL m_programming;
    
    NSMutableArray* m_updateNotifications;
    NSTimer* m_updateNotificationTimer;
}

@property(readonly) Number* x;
@property(readonly) Number* y;
@property(readonly) Number* z;
@property(readonly) Number* t;
@property(readonly) Number* lastX;

@property(readonly) ModeType mode;
@property(readonly) BaseType base;
@property(readonly) DispType disp;
@property(readonly) int dispSignificantDigits;
@property(readonly) InputModeType inputMode;

@property(readonly) RunStateType runState;
@property(readonly) BOOL stepping;
@property(readonly) NSString* inputPrompt;
@property(assign) BOOL programming;

@property(readonly) NSUInteger currentFunction;
@property(readonly) NSUInteger currentInstruction;
@property(readonly) NSUInteger executingFunction;
@property(readonly) NSUInteger executingInstruction;
@property(readonly) NSArray* program;
@property(readonly) NSString* title;
@property(readonly) NSString* category;
@property(readonly) NSString* description;

+ (NSArray*)programList;

- (void)step;
- (void)run;
- (void)stop;
- (void)quit;

- (void)op:(OperationType) operation;
- (void)op:(OperationType) operation withParams:(NSArray*) params;

- (void)enterIfNeeded;
- (void)setXFromString:(NSString*) string;
- (void)setXFromNumber:(Number*) number;
- (Number*)numberFromReg:(int) reg;

- (NSArray*)conversionTypes;
- (NSArray*)conversionsForClass:(int) clas index:(int) indx;
- (void)convertWithClass:(int) clas fromIndex:(int) fromIndex toIndex:(int) toIndex;

- (void)addInstructionString:(NSString*) instruction;
- (BOOL)canAssignUserKey;
- (void)nameCurrentSubroutine:(int) reg;
- (void)nameCurrentFunction:(NSString*) name;
- (void)addFunction;
- (void)deleteCurrentFunction;
- (void)deleteCurrentInstruction;
- (void)currentFunctionName:(NSString**) name key:(int*) key;
- (NSString*)functionNameForKey:(int) key;
- (void)selectFunction:(NSUInteger) func instruction:(NSUInteger) inst;

- (void)clearProgramStore;
- (NSArray*)instructionsForSubr:(int) reg function:(NSUInteger*) function;

- (void)addUpdateNotificationWithTarget:(id) target selector:(SEL) selector;
- (void)removeAllUpdateNotificationsForTarget:(id) target;

+ (NSDictionary*)detailsForProgram:(NSString*) title withCategory:(NSString*)category;
- (void)loadProgram:(NSString*) title withCategory:(NSString*) category;
- (void)setProgramDescriptor:(NSDictionary*) program;
- (NSString*)programToPropertyListString;

- (void)notifyUpdate;

- (void)cleanup;

@end
