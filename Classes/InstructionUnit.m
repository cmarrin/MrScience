//
//  InstructionUnit.m
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "InstructionUnit.h"

#import "ExecutionUnit.h"
#import "NumberConverter.h"
#import "ProgramStore.h"

@interface InstructionUnit (Private)

- (void)solve:(int) f withReg:(int) reg;

@end

@implementation InstructionUnit

@synthesize mode = m_mode;
@synthesize base = m_base;
@synthesize disp = m_disp;
@synthesize dispSignificantDigits = m_dispSignificantDigits;
@synthesize lastStatus = m_lastStatus;
@synthesize inputPrompt = m_inputPrompt;
@synthesize inputMode = m_inputMode;

- (Number*)x
{
    return m_x;
}

- (Number*)y
{
    return m_y;
}

- (Number*)z
{
    return m_z;
}

- (Number*)t
{
    return m_t;
}

- (Number*)lastX
{
    return m_lastX;
}

- (id)initWithCalculator:(Calculator*) calculator;
{
    m_calculator = [calculator retain];
    
    m_x = [[Number alloc] init];
    m_y = [[Number alloc] init];
    m_z = [[Number alloc] init];
    m_t = [[Number alloc] init];
    m_lastX = [[Number alloc] init];
    
    m_registers = [[NSMutableDictionary alloc] init];
    
    m_mode = DEG;
    m_base = DEC;
    m_disp = ALL;
    m_dispSignificantDigits = MAXMANTISSA;
    m_enableLift = YES;
    
    m_numberConverter = [[NumberConverter alloc] init];
    m_inputMode = IM_NONE;
    
    return self;
}

- (void)dealloc
{
    [m_numberConverter release];
    [m_calculator release];
    [super dealloc];
}

- (void)enter:(BOOL) ignoreLift
{
    if (!m_enableLift && !ignoreLift) {
        m_enableLift = YES;
        return;
    }
    
    [m_t initWithNumber:m_z];
    [m_z initWithNumber:m_y];
    [m_y initWithNumber:m_x];
}

- (void)pop
{
    [m_lastX initWithNumber:m_x];
    [m_x initWithNumber:m_y];
    [m_y initWithNumber:m_z];
    [m_z initWithNumber:m_t];
}

- (Number*)numberFromReg:(int) reg
{
    Number* number = [m_registers objectForKey:[NSNumber numberWithInt:reg]];
    if (!number) {
        number = [Number number];
        [m_registers setObject:number forKey:[NSNumber numberWithInt:reg]];
    }
    return number;
}

static NSString* stringFromOperationWithReg(OperationType operation, int reg)
{
    NSString* s = [ExecutionUnit stringFromOperation:operation];
    return s ? [s stringByAppendingFormat:@":%@", [ExecutionUnit stringFromReg:reg]] : nil;
}

static NSString* stringFromOperationWithPrecision(OperationType operation, int precision)
{
    NSString* s = [ExecutionUnit stringFromOperation:operation];
    return s ? [s stringByAppendingFormat:@":%@", [[NSNumber numberWithInt:precision] stringValue]] : nil;
}

static NSString* stringFromOperationWithName(OperationType operation, NSString* name)
{
    NSString* s = [ExecutionUnit stringFromOperation:operation];
    return s ? [s stringByAppendingFormat:@":%@", name] : nil;
}

static NSString* stringFromOperationWithConversion(OperationType operation, NSString* fromString, NSString* toString)
{
    NSString* s = [ExecutionUnit stringFromOperation:operation];
    return s ? [s stringByAppendingFormat:@":%@➜%@", fromString, toString]: nil;
}

- (void)addInstruction:(OperationType) operation
{
    if (m_numberJustSet && operation == OP_ENTER)
        return;
    [m_calculator addInstructionString:[ExecutionUnit stringFromOperation:operation]];
    m_numberJustSet = NO;
}

- (void)addInstruction:(OperationType) operation withReg:(int) reg
{
    [m_calculator addInstructionString:stringFromOperationWithReg(operation, reg)];
    m_numberJustSet = NO;
}

- (void)addInstruction:(OperationType) operation withPrecision:(int) precision
{
    [m_calculator addInstructionString:stringFromOperationWithPrecision(operation, precision)];
    m_numberJustSet = NO;
}

- (void)addInstruction:(OperationType) operation withName:(NSString*) name
{
    [m_calculator addInstructionString:stringFromOperationWithName(operation, name)];
    m_numberJustSet = NO;
}

- (void)addInstruction:(OperationType) operation withConversionClass:(int) clas from:(int) from to:(int) to
{
    NSString* fromString = [m_numberConverter stringForConversionWithClass:clas index:from];
    NSString* toString = [m_numberConverter stringForConversionWithClass:clas index:to];
    [m_calculator addInstructionString:stringFromOperationWithConversion(operation, fromString, toString)];
    m_numberJustSet = NO;
}

- (void)executeBuiltInFunction:(const NSString*) function returnX:(BOOL) returnX returnY:(BOOL) returnY
{
    // Save regs
    Number* savedX = [Number numberWithNumber:m_x];
    Number* savedY = [Number numberWithNumber:m_y];
    Number* savedZ = [Number numberWithNumber:m_z];
    Number* savedT = [Number numberWithNumber:m_t];
    Number* savedLastX = [Number numberWithNumber:m_lastX];
    BOOL savedProgramming = m_calculator.programming;
    m_calculator.programming = NO;
    
    NSArray* instructions = [function componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";\n"]];

    ExecutionUnit* executionUnit = [[ExecutionUnit alloc] initWithCalculator:m_calculator];
    [executionUnit setupExecutionForFunction:0 withInstructions:instructions debug:NO];

    ExecutionStatusType xs = XS_NORMAL;
    while (xs == XS_NORMAL)
        xs = [executionUnit executeNext];
        
    // Built-in functions shouldn't ever PAUSE or INPUT
    assert(xs != XS_INPUT && xs != XS_PAUSE);
    
    // FIXME: deal with XS_ERROR
        
    [executionUnit release];
    
    m_calculator.programming = savedProgramming;

    if (!returnX)
        [m_x initWithNumber:savedX];
    if (!returnY)
        [m_y initWithNumber:savedY];
        
    [m_z initWithNumber:savedZ];
    [m_t initWithNumber:savedT];
    [m_lastX initWithNumber:savedLastX];
}

- (double)toRad:(double) d
{
    if (m_mode == DEG)
        return d / 360 * 2 * M_PI;
    if (m_mode == GRAD)
        return d / 400 * 2 * M_PI;
    return d;
}

- (double)fromRad:(double) d
{
    if (m_mode == DEG)
        return d / (2 * M_PI) * 360;
    if (m_mode == GRAD)
        return d / (2 * M_PI) * 400;
    return d;
}

- (void)op:(OperationType) operation
{
    Number* tmp = [Number number];

    BOOL newEnableLift = YES;

    switch(operation) {
        case OP_ROLL_UP:
            [tmp initWithNumber:m_t];
            [m_t initWithNumber:m_z];
            [m_z initWithNumber:m_y];
            [m_y initWithNumber:m_x];
            [m_x initWithNumber:tmp];
            break;
        case OP_ROLL_DN:
            [tmp initWithNumber:m_x];
            [m_x initWithNumber:m_y];
            [m_y initWithNumber:m_z];
            [m_z initWithNumber:m_t];
            [m_t initWithNumber:tmp];
            break;
        case OP_ENTER:
            [self enter:YES];
            newEnableLift = NO;
            break;
        case OP_EXCH:
            [tmp initWithNumber:m_x];
            [m_x initWithNumber:m_y];
            [m_y initWithNumber:tmp];
            break;
        case OP_DUP2:
            [m_t initWithNumber:m_y];
            [m_z initWithNumber:m_x];
            break;
        case OP_OVER:
            [m_z initWithNumber:m_y];
            [m_y initWithNumber:m_x];
            [m_x initWithNumber:m_z];
            break;
        case OP_LAST_X:
            [self enter:NO];
            [m_x initWithNumber:m_lastX];
            break;
        case OP_CLR_X:
            [m_x init];
            newEnableLift = NO;
            break;
        case OP_CLR_STACK:
        case OP_CLR_VARS:
        case OP_CLR_SUM:
        case OP_CLR_PGM:
        case OP_CLR_ALL:
            if (operation == OP_CLR_STACK || operation == OP_CLR_ALL) {
                [m_x init];
                [m_y init];
                [m_z init];
                [m_t init];
                [m_lastX init];
            }
            if (operation == OP_CLR_VARS || operation == OP_CLR_ALL) {
                // Clear all but the 6 summation regs
                NSMutableDictionary* sums = [[NSMutableDictionary alloc] init];
                for (int i = SUM_FIRST; i <= SUM_LAST; ++i) {
                    NSNumber* indx = [NSNumber numberWithInt:i];
                    Number* num = [m_registers objectForKey:indx];
                    if (num)
                        [sums setObject:num forKey:indx];
                }
                        
                [m_registers release];
                m_registers = sums;
            }
            if (operation == OP_CLR_SUM || operation == OP_CLR_ALL) {
                for (int i = SUM_FIRST; i <= SUM_LAST; ++i)
                    [m_registers removeObjectForKey:[NSNumber numberWithInt:i]];
            }
            if (operation == OP_CLR_PGM || operation == OP_CLR_ALL) {
                [m_calculator clearProgramStore];
            }
            if (operation == OP_CLR_VARS || operation == OP_CLR_SUM)
                newEnableLift = m_enableLift;
            break;

        case OP_PI:         [self enter:NO]; [m_x initWithString:PI_STRING inBase:DEC]; break;
        
        case OP_ADD:        [m_y add:m_x];        [self pop]; break;
        case OP_SUB:        [m_y subtract:m_x];   [self pop]; break;
        case OP_MUL:        [m_y multiply:m_x];   [self pop]; break;
        case OP_DIV:        [m_y divide:m_x];     [self pop]; break;
        case OP_Y_TO_THE_X: [m_y power:m_x];      [self pop]; break;
        
        case OP_SQRT:       [m_x squareRoot]; break;
        case OP_X_SQUARED:  [m_x multiply:m_x]; break;
        case OP_E_TO_THE_X: [m_x exp]; break;
        case OP_LN:         [m_x ln]; break;
        case OP_LOG:        [m_x log]; break;
        case OP_ROUND:      [m_x roundWithSignificantDigits:m_dispSignificantDigits]; break;
        case OP_TRUNC:      [m_x trunc]; break;
        case OP_FRAC:       [m_x frac]; break;
        case OP_ABS:        [m_x abs]; break;
        case OP_RAND:       [m_x rand]; break;
        case OP_SEED:       [m_x seed]; break;
        
        
        case OP_1_OVER_X:       [self executeBuiltInFunction:@"1; EXCH; DIV" returnX:YES returnY:NO]; break;
        case OP_10_TO_THE_X:    [self executeBuiltInFunction:@"10; EXCH; Y_TO_THE_X" returnX:YES returnY:NO]; break;
        case OP_2_TO_THE_X:     [self executeBuiltInFunction:@"2; EXCH; Y_TO_THE_X" returnX:YES returnY:NO]; break;

        case OP_X_ROOT_OF_Y:    [self executeBuiltInFunction:@"1/x; Y_TO_THE_X; ENTER" returnX:NO returnY:YES]; [self pop]; break;
        
        case OP_LOG_2:
            // log base 2 of x = log(x) / log(2)
            [self executeBuiltInFunction:@"LOG; 2; LOG; DIV" returnX:YES returnY:NO];
            break;
        case OP_X_FACTORIAL:
            [self executeBuiltInFunction:@"ROUND; 1; DUP2; LE; RETIF; EXCH; 2; FOR; RCL:i; MUL; LOOP" returnX:YES returnY:NO];
            break;
        case OP_PCT:
            // This preserves the value of Y, so it doesn't pop
            [self executeBuiltInFunction:@"100; DIV; MUL" returnX:YES returnY:NO];
            break;
        case OP_DELTA_PCT:
            // This preserves the value of Y, so it doesn't pop
            // Computes (x - y) / y
            [self executeBuiltInFunction:@"EXCH; SUB; LAST_X; DIV; 100; MUL" returnX:YES returnY:NO];
            break;
            
        // Initial implementation of these methods is suboptimal. By calculating
        // as double, we get only 16 digits of precision instead of 34 like the
        // rest of the calculations. We will fix that later with Taylor Series, etc.
        case OP_SIN:        [m_x initWithDouble:sin([self toRad:[m_x doubleValue]])]; break;
        case OP_COS:        [m_x initWithDouble:cos([self toRad:[m_x doubleValue]])]; break;
        case OP_TAN:        [m_x initWithDouble:tan([self toRad:[m_x doubleValue]])]; break;
        case OP_ARCSIN:     [m_x initWithDouble:[self fromRad:asin([m_x doubleValue])]]; break;
        case OP_ARCCOS:     [m_x initWithDouble:[self fromRad:acos([m_x doubleValue])]]; break;
        case OP_ARCTAN:     [m_x initWithDouble:[self fromRad:atan([m_x doubleValue])]]; break;
        case OP_SINH:       [m_x initWithDouble:sinh([self toRad:[m_x doubleValue]])]; break;
        case OP_COSH:       [m_x initWithDouble:cosh([self toRad:[m_x doubleValue]])]; break;
        case OP_TANH:       [m_x initWithDouble:tanh([self toRad:[m_x doubleValue]])]; break;
        case OP_ARCSINH:    [m_x initWithDouble:[self fromRad:asinh([m_x doubleValue])]]; break;
        case OP_ARCCOSH:    [m_x initWithDouble:[self fromRad:acosh([m_x doubleValue])]]; break;
        case OP_ARCTANH:    [m_x initWithDouble:[self fromRad:atanh([m_x doubleValue])]]; break;
            
        case OP_HEX_NEG:    [m_x initWithUInt64:-[m_x uInt64Value]]; break;
        case OP_HEX_NOT:    [m_x initWithUInt64:~[m_x uInt64Value]]; break;
        case OP_HEX_AND:    [m_y initWithUInt64:[m_y uInt64Value] & [m_x uInt64Value]]; [self pop]; break;
        case OP_HEX_OR:     [m_y initWithUInt64:[m_y uInt64Value] | [m_x uInt64Value]]; [self pop]; break;
        case OP_HEX_XOR:    [m_y initWithUInt64:[m_y uInt64Value] ^ [m_x uInt64Value]]; [self pop]; break;
        case OP_HEX_SHL:    [m_y initWithUInt64:[m_y uInt64Value] << [m_x uInt64Value]]; [self pop]; break;
        case OP_HEX_SHR:    [m_y initWithUInt64:[m_y uInt64Value] >> [m_x uInt64Value]]; [self pop]; break;
        case OP_HEX_MOD:    [m_y initWithUInt64:[m_y uInt64Value] % [m_x uInt64Value]]; [self pop]; break;
            
        case OP_IF:
        case OP_BREAKIF:
        case OP_RETIF:
            [self pop];
            break;
        case OP_FOR:
            [self pop];
            [self pop];
            break;
        case OP_EQ:
        case OP_NE:
        case OP_GE:
        case OP_GT:
        case OP_LT:
        case OP_LE: {
            int comp = [m_y compare:m_x];
            
            BOOL result = YES;
            switch(operation) {
                case OP_EQ: result = comp == 0; break;
                case OP_NE: result = comp != 0; break;
                case OP_GE: result = comp >= 0; break;
                case OP_GT: result = comp > 0; break;
                case OP_LT: result = comp < 0; break;
                case OP_LE: result = comp <= 0; break;
                default: break;
            }
            
            [m_y initWithUInt64:result ? 1 : 0];
            [self pop];
            break;
        }
        
        case OP_BASE_DEC: m_base = DEC; newEnableLift = m_enableLift; break;
        case OP_BASE_HEX: m_base = HEX; newEnableLift = m_enableLift; break;
        case OP_BASE_BIN: m_base = BIN; newEnableLift = m_enableLift; break;
        case OP_BASE_OCT: m_base = OCT; newEnableLift = m_enableLift; break;

        case OP_MODE_DEG: m_mode = DEG; newEnableLift = m_enableLift; break;
        case OP_MODE_RAD: m_mode = RAD; newEnableLift = m_enableLift; break;
        case OP_MODE_GRAD: m_mode = GRAD; newEnableLift = m_enableLift; break;
        
        case OP_CNV_DEGC:   [self executeBuiltInFunction:[m_numberConverter toDegCProgram] returnX:YES returnY:NO]; break;
        case OP_CNV_DEGF:   [self executeBuiltInFunction:[m_numberConverter toDegFProgram] returnX:YES returnY:NO]; break;
        case OP_CNV_RAD:    [self executeBuiltInFunction:[m_numberConverter toRadProgram] returnX:YES returnY:NO]; break;
        case OP_CNV_DEG:    [self executeBuiltInFunction:[m_numberConverter toDegProgram] returnX:YES returnY:NO]; break;
        case OP_CNV_HMS:    [self executeBuiltInFunction:[m_numberConverter toHMSProgram] returnX:YES returnY:NO]; break;
        case OP_CNV_H:      [self executeBuiltInFunction:[m_numberConverter toHProgram] returnX:YES returnY:NO]; break;
        case OP_CNV_POLAR:  [self executeBuiltInFunction:[m_numberConverter toPolarProgram] returnX:YES returnY:YES]; break;
        case OP_CNV_RECT:   [self executeBuiltInFunction:[m_numberConverter toRectProgram] returnX:YES returnY:YES]; break;
            
        case OP_SUM:        [self executeBuiltInFunction:PROG_SUM returnX:YES returnY:NO]; newEnableLift = NO; break;
        case OP_SUM_MINUS:  [self executeBuiltInFunction:PROG_SUM_MINUS returnX:YES returnY:NO]; newEnableLift = NO; break;
        case OP_X_MEAN:
            [self executeBuiltInFunction:@"RCL:SUMx; RCL:n; DIV" returnX:YES returnY:NO];
            break;
        case OP_Y_MEAN:
            [self executeBuiltInFunction:@"RCL:SUMy; RCL:n; DIV" returnX:YES returnY:NO];
            break;
        case OP_XW_MEAN:
            [self executeBuiltInFunction:@"RCL:SUMxy; RCL:SUMy; DIV" returnX:YES returnY:NO];
            break;
        case OP_PSD_X:
            [self executeBuiltInFunction:@"RCL:SUMx2; RCL:SUMx; X_SQUARED; RCL:n; DIV; SUB; RCL:n; DIV; SQRT" returnX:YES returnY:NO];
            break;
        case OP_PSD_Y:
            [self executeBuiltInFunction:@"RCL:SUMy2; RCL:SUMy; X_SQUARED; RCL:n; DIV; SUB; RCL:n; DIV; SQRT" returnX:YES returnY:NO];
            break;
        case OP_SSD_X:
            [self executeBuiltInFunction:@"RCL:SUMx2; RCL:SUMx; X_SQUARED; RCL:n; DIV; SUB; RCL:n; 1; SUB; DIV; SQRT" returnX:YES returnY:NO];
            break;
        case OP_SSD_Y:
            [self executeBuiltInFunction:@"RCL:SUMy2; RCL:SUMy; X_SQUARED; RCL:n; DIV; SUB; RCL:n; 1; SUB; DIV; SQRT" returnX:YES returnY:NO];
            break;
        case OP_C_N_R:
            [self executeBuiltInFunction:@"DUP2; SUB; X_FACTORIAL; EXCH; X_FACTORIAL; MUL; EXCH; X_FACTORIAL; EXCH; DIV" returnX:YES returnY:NO];
            break;
        case OP_P_N_R:
            [self executeBuiltInFunction:@"OVER; EXCH; SUB; X_FACTORIAL; EXCH; X_FACTORIAL; EXCH; DIV" returnX:YES returnY:NO];
            break;
            
        // These must have a param, so are illegal here
        case OP_STO: case OP_STO_ADD: case OP_STO_SUB: case OP_STO_MUL: case OP_STO_DIV:
        case OP_RCL: case OP_RCL_ADD: case OP_RCL_SUB: case OP_RCL_MUL: case OP_RCL_DIV:
        case OP_DISP_ALL: case OP_DISP_FIX: case OP_DISP_SCI: case OP_DISP_ENG:
        case OP_NUM: case OP_CALL: case OP_DEF_FUNC: case OP_DEF_SUBR:
        case OP_CNV_UNITS: case OP_SOLVE: case OP_INPUT:
            assert(0);
            return;
            
        case OP_DO: case OP_LOOP: case OP_FOR_START: case OP_FOR_NEXT:
        case OP_ELSE: case OP_THEN: case OP_BREAK: case OP_RET:
        case OP_NONE: case OP_ERROR: case OP_PAUSE:
            break;
    }
    
    m_enableLift = newEnableLift;

    m_lastStatus = [Number lastStatus];
    
    if (m_calculator.programming && operation != OP_CLR_PGM)
        [self addInstruction:operation];
}

- (void)op:(OperationType) operation withReg:(int) reg
{
    if (m_calculator.programming)
        [self addInstruction:operation withReg:reg];
        
    if (operation == OP_CALL)
        return;

    if (reg == REG_IND_I || reg == REG_IND_I_POST_INC || reg == REG_IND_I_PRE_DEC) {
        Number* i = [self numberFromReg:REG_INDEX];
        if (reg == REG_IND_I_PRE_DEC)
            [i subtract:[Number numberWithDouble:1]];
        reg = (int) [i doubleValue];
        if (reg == REG_IND_I_POST_INC)
            [i add:[Number numberWithDouble:1]];
    }
    else if (reg == REG_IND_X) {
        reg = (int) [m_x doubleValue];
        [self pop];
    }
    
    Number* r = [self numberFromReg:reg];

    switch(operation) {
        case OP_STO:
            [r initWithNumber:m_x];
            break;
        case OP_STO_ADD:
            [r add:m_x];
            break;
        case OP_STO_SUB:
            [r subtract:m_x];
            break;
        case OP_STO_MUL:
            [r multiply:m_x];
            break;
        case OP_STO_DIV:
            [r divide:m_x];
            break;
        case OP_RCL:
            [self enter:NO];
            [m_x initWithNumber:r];
            break;
        case OP_RCL_ADD:
            [self enter:NO];
            [r add:m_x];
            [m_x initWithNumber:r];
            break;
        case OP_RCL_SUB:
            [self enter:NO];
            [r subtract:m_x];
            [m_x initWithNumber:r];
            break;
        case OP_RCL_MUL:
            [self enter:NO];
            [r multiply:m_x];
            [m_x initWithNumber:r];
            break;
        case OP_RCL_DIV:
            [self enter:NO];
            [r divide:m_x];
            [m_x initWithNumber:r];
            break;
        default:
            // Everything else takes no params so is illegal here
            assert(0);
            return;
    }
    
    m_enableLift = YES; 

    m_lastStatus = [Number lastStatus];
}

- (void)op:(OperationType) operation withPrecision:(int) precision
{
    if (precision < 0)
        precision = 0;
    else if (precision > MAXMANTISSA)
        precision = MAXMANTISSA;
        
    switch(operation) {
        case OP_DISP_ALL: m_disp = ALL; m_dispSignificantDigits = precision; break;
        case OP_DISP_FIX: m_disp = FIX; m_dispSignificantDigits = precision; break;
        case OP_DISP_SCI: m_disp = SCI; m_dispSignificantDigits = precision; break;
        case OP_DISP_ENG: m_disp = ENG; m_dispSignificantDigits = precision; break;
        default: return;
    }

    if (m_calculator.programming)
        [self addInstruction:operation withPrecision:precision];
}

- (void)opInputWithReg:(int) reg string:(NSString*) string
{
    if (m_calculator.programming) {
        [m_calculator addInstructionString:[NSString stringWithFormat:@"%@|%@", stringFromOperationWithReg(OP_INPUT, reg), string]];
        m_numberJustSet = NO;
    }
    else {
        [m_inputPrompt release];
        char lastChar = [string characterAtIndex:[string length] - 1];
        if (lastChar == '#' || lastChar == '@') {
            m_inputMode =  (lastChar == '#') ? IM_DIGIT : IM_REG;
            string = [string substringToIndex:[string length] - 1];
        }
        else
            m_inputMode = IM_NUMBER;
            
        m_inputPrompt = [string retain];
        m_inputReg = reg;
        [self op:OP_RCL withReg:reg];
    }
}

- (void)opSolveWithFunction:(int) f reg:(int) reg
{
    if (m_calculator.programming) {
        [m_calculator addInstructionString:[NSString stringWithFormat:@"%@:%@", stringFromOperationWithReg(OP_SOLVE, f), [ExecutionUnit stringFromReg:reg]]];
        m_numberJustSet = NO;
    }
    
    // Save regs
    Number* savedT = [Number numberWithNumber:m_t];
    Number* savedLastX = [Number numberWithNumber:m_lastX];
    BOOL savedProgramming = m_calculator.programming;
    m_calculator.programming = NO;
    
    ExecutionUnit* executionUnit = [[ExecutionUnit alloc] initWithCalculator:m_calculator];
    [self solve:f withReg:reg];
    [executionUnit release];
    
    m_calculator.programming = savedProgramming;
    [m_t initWithNumber:savedT];
    [m_lastX initWithNumber:savedLastX];
}

- (void)op:(OperationType) operation withParams:(NSArray*) params
{
    switch (operation) {
        case OP_STO: case OP_STO_ADD: case OP_STO_SUB: case OP_STO_MUL: case OP_STO_DIV:
        case OP_RCL: case OP_RCL_ADD: case OP_RCL_SUB: case OP_RCL_MUL: case OP_RCL_DIV:
        case OP_CALL:
            assert(params && [params count] == 1);
            [self op:operation withReg:[[params objectAtIndex:0] intValue]];
            break;
        case OP_DISP_ALL: case OP_DISP_FIX: case OP_DISP_SCI: case OP_DISP_ENG:
            assert(params && [params count] == 1);
            [self op:operation withPrecision:[[params objectAtIndex:0] intValue]];
            break;
        case OP_SOLVE:
            assert(params && [params count] == 2);
            [self opSolveWithFunction:[[params objectAtIndex:0] intValue] reg:[[params objectAtIndex:1] intValue]];
            break;
        case OP_INPUT:
            assert(params && [params count] == 2);
            [self opInputWithReg:[[params objectAtIndex:0] intValue] string:[params objectAtIndex:1]];
            break;
        default:
            [self op:operation];
            break;
    }
}

- (void)inputComplete:(BOOL) accept
{
    if (accept)
        [self op:OP_STO withParams:[NSArray arrayWithObject:[NSNumber numberWithInt:m_inputReg]]];
    m_inputMode = IM_NONE;
}

- (void)convertWithClass:(int) clas fromIndex:(int) fromIndex toIndex:(int) toIndex
{
    NSString* fromString;
    NSString* toString;
    [m_numberConverter multiplierForClass:clas fromString:&fromString forFromIndex:fromIndex toString:&toString forToIndex:toIndex];
    Number* fromNumber = [Number numberWithString:fromString inBase:DEC];
    Number* toNumber = [Number numberWithString:toString inBase:DEC];
    
    [m_x multiply:toNumber];
    [m_x divide:fromNumber];

    if (m_calculator.programming) {
        [self addInstruction:OP_CNV_UNITS withConversionClass:clas from:fromIndex to:toIndex];
        m_numberJustSet = NO;
    }
}

- (NSArray*)conversionTypes
{
    return [m_numberConverter conversionTypes];
}

- (NSArray*)conversionsForClass:(int) clas index:(int) indx
{
    return [m_numberConverter conversionsForClass:clas index:indx];
}

- (void)setXFromString:(NSString*) string
{
    if (m_calculator.programming) {
        if (m_base != DEC)
            [m_calculator addInstructionString:[NSString stringWithFormat:@"#%s%@", (m_base == HEX) ? "" : ((m_base == BIN) ? "B" : "O"), string]];
        else
            [m_calculator addInstructionString:string];
        m_numberJustSet = YES;
    }

    [m_x initWithString:string inBase:m_base];
}

- (void)setXFromNumber:(Number*) number
{
    [m_x initWithNumber:number];
}


/*
function findRoot(f, regs, i, x)
{
    var xmin = x;
    var xmax = regs[i];

    if (xmin > xmax) {
        var tmp = xmin;
        xmin = xmax;
        xmax = tmp;
    }
    else if (xmin == xmax)
        xmax = xmin + 1;
    
    var ymin = execf(f, regs, i, xmin);
    var ymax = execf(f, regs, i, xmax);

    if (sign(ymin) == sign(ymax)) {
        // Find a better guess
        if (ymin < 0) {
            if (ymin < ymax)
                xmin = xmax;
            
            xmax = findGuess(f, regs, i, xmin, xmax > xmin);
        }
        else {
            if (ymax < ymin)
                xmax = xmin;
            
            xmin = findGuess(f, regs, i, xmax, xmax < xmin);
        }
    }

    var xmid = xmin;
    
    while (Math.abs(xmax - xmin) > 1e-34) {
        // Calculate xmid of domain
        var xmid = (xmax + xmin) / 2;

        // Find f(xmid)
        if (execf(f, regs, i, xmin) * execf(f, regs, i, xmid) < 0) {
            // Throw away xmax
            xmax = xmid;
        }
        else if (execf(f, regs, i, xmax) * execf(f, regs, i, xmid) < 0) {
            // Throw away xmin
            xmin = xmid;
        }
        else {
            // Our midpoint is exactly on the root
            break;
        }
    }
    return xmid;
}

function sign(x) { return (x >= 0) ? 1 : -1; }

function execf(f, regs, i, x)
{
    regs[i] = x;
    return f(regs);
}
*/

- (Number*)findGuessForFunction:(ExecutionUnit*) f variable:(int) v increasing:(BOOL) increasing
{
    Number* sgn = [Number numberWithDouble:([m_calculator.x negative] ^ !increasing) ? -1 : 1];
    Number* xdelta = [Number numberWithNumber:sgn];
    [xdelta multiply:[Number numberWithDouble:0.1]];
    Number* two = [Number numberWithDouble:2];

    for (int maxIters = 0; maxIters < 1000; ++maxIters) {
        Number* tmp = [Number numberWithNumber:m_calculator.x];
        [tmp add:xdelta];
        //[f execute];
        [tmp multiply:sgn];
        if ([tmp negative])
            break;
        
        [xdelta multiply:two];
    }

    Number* returnValue = [Number numberWithNumber:m_calculator.x];
    [returnValue multiply:xdelta];
    return returnValue;
}

- (void)solve:(int) f withReg:(int) reg
{
    // Solve the function f for the variable in reg. Use the value in x 
    // and reg as the guesses. Return with found root in X, previous guess
    // in Y and root at X in Z (should be 0 if solution found).
    //ExecutionUnit* executionUnit = [[ExecutionUnit alloc] initWithCalculator:m_calculator];
    
}


/*
- (void)executeBuiltInFunction:(const NSString*) function returnX:(BOOL) returnX returnY:(BOOL) returnY
{
    // Save regs
    Number* savedX = [Number numberWithNumber:m_x];
    Number* savedY = [Number numberWithNumber:m_y];
    Number* savedZ = [Number numberWithNumber:m_z];
    Number* savedT = [Number numberWithNumber:m_t];
    Number* savedLastX = [Number numberWithNumber:m_lastX];
    BOOL savedProgramming = m_calculator.programming;
    m_calculator.programming = NO;
    
    NSArray* instructions = [function componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";\n"]];

    ExecutionUnit* executionUnit = [[ExecutionUnit alloc] initWithCalculator:m_calculator];
    [executionUnit setupExecutionForFunction:0 withInstructions:instructions debug:NO];

    ExecutionStatusType xs = XS_NORMAL;
    while (xs == XS_NORMAL)
        xs = [executionUnit executeNext];
        
    // Built-in functions shouldn't ever PAUSE or INPUT
    assert(xs != XS_INPUT && xs != XS_PAUSE);
    
    // FIXME: deal with XS_ERROR
        
    [executionUnit release];
    
    m_calculator.programming = savedProgramming;

    if (!returnX)
        [m_x initWithNumber:savedX];
    if (!returnY)
        [m_y initWithNumber:savedY];
        
    [m_z initWithNumber:savedZ];
    [m_t initWithNumber:savedT];
    [m_lastX initWithNumber:savedLastX];
}
*/


@end
