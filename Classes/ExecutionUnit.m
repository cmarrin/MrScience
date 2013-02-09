//
//  ExecutionUnit.m
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ExecutionUnit.h"

#import "InstructionUnit.h"

// These values are returned from each step of program execution:
//
//  ST_NORMAL   - Continue with current block
//  ST_LOOP     - Execute block again
//  ST_BREAK    - Break from innermost LOOP block
//  ST_RET      - Return from innermost CALL block
//  ST_DONE     - Exit from current block
//  ST_ERROR    - Error occured, stop execution
//  ST_PAUSE    - Pause execution and show regs for PAUSE_TIME seconds
//  ST_INPUT    - Pause execution and ask for user input
typedef enum { OS_NORMAL, OS_LOOP, OS_BREAK, OS_RET, OS_DONE, OS_ERROR, OS_PAUSE, OS_INPUT } OperationStatusType;

static NSArray* g_opcodes;

#define OPCODE(op) [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:OP_##op], @"op", @#op, @"name", nil]
#define OPCODE2(op, s) [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:OP_##op], @"op", @#op, @"name", @s, @"symbol", nil]

@interface ExecutionUnit (Private)

- (void)startExecutionTimer:(NSTimeInterval) t;

@end

@implementation ExecutionUnit

@synthesize runState = m_runState;
@synthesize stepping = m_stepping;
@synthesize inputTitle = m_inputTitle;
@synthesize executingFunction = m_executingFunction;
@synthesize executingInstruction = m_executingInstruction;

static NSArray* opcodes()
{
    // Create the Opcode dictionary
    if (!g_opcodes) {
        g_opcodes = [NSArray arrayWithObjects:
            OPCODE2(ADD, "+"), OPCODE2(SUB, "-"), OPCODE2(MUL, "×"), OPCODE2(DIV, "÷"),
            OPCODE(STO), OPCODE2(STO_ADD, "STO+"), OPCODE2(STO_SUB, "STO-"), OPCODE2(STO_MUL, "STO×"), OPCODE2(STO_DIV, "STO÷"),
            OPCODE(RCL), OPCODE2(RCL_ADD, "RCL+"), OPCODE2(RCL_SUB, "RCL-"), OPCODE2(RCL_MUL, "RCL×"), OPCODE2(RCL_DIV, "RCL÷"),
            OPCODE2(ROLL_UP, "R↑"), OPCODE2(ROLL_DN, "R↓"), OPCODE(ENTER), OPCODE(EXCH), OPCODE(DUP2), OPCODE(OVER), OPCODE2(LAST_X, "LASTx"),
            OPCODE(CLR_X), OPCODE(CLR_STACK), OPCODE(CLR_VARS), OPCODE(CLR_SUM), OPCODE(CLR_PGM), OPCODE(CLR_ALL),
            OPCODE2(PI, "π"), OPCODE(NUM),
            OPCODE2(1_OVER_X, "1/x"), OPCODE(SQRT), OPCODE2(X_SQUARED, "x²"), OPCODE(Y_TO_THE_X), OPCODE(X_ROOT_OF_Y),
            OPCODE2(E_TO_THE_X, "e^x"), OPCODE(LN), OPCODE2(10_TO_THE_X, "10^x"), OPCODE(LOG), OPCODE2(2_TO_THE_X, "2^x"), OPCODE2(LOG_2, "LOG2"),
            OPCODE2(X_FACTORIAL, "x!"), OPCODE2(PCT, "%"), OPCODE2(DELTA_PCT, "%Δ"),
            OPCODE2(SUM, "Σ+"), OPCODE2(SUM_MINUS, "Σ-"),
            OPCODE(SIN), OPCODE(COS), OPCODE(TAN), OPCODE(ARCSIN), OPCODE(ARCCOS), OPCODE(ARCTAN),
            OPCODE(SINH), OPCODE(COSH), OPCODE(TANH), OPCODE(ARCSINH), OPCODE(ARCCOSH), OPCODE(ARCTANH),
            OPCODE2(HEX_AND, "AND"), OPCODE2(HEX_OR, "OR"), OPCODE2(HEX_XOR, "XOR"), OPCODE2(HEX_NEG, "NEG"), OPCODE2(HEX_NOT, "NOT"),
            OPCODE2(HEX_SHL, "<<"), OPCODE2(HEX_SHR, ">>"), OPCODE2(HEX_MOD, "MOD"),
            OPCODE(ROUND), OPCODE(TRUNC), OPCODE(FRAC), OPCODE(ABS), OPCODE(RAND), OPCODE(SEED),
            OPCODE(IF), OPCODE(ELSE), OPCODE(THEN), OPCODE(FOR), OPCODE(DO), OPCODE(BREAK), OPCODE(BREAKIF), OPCODE(LOOP),
            OPCODE(FOR_START), OPCODE(FOR_NEXT),
            OPCODE(EQ), OPCODE(NE), OPCODE(GT), OPCODE(GE), OPCODE(LT), OPCODE(LE),
            OPCODE(CALL), OPCODE(RET), OPCODE(RETIF), 
            OPCODE(BASE_DEC), OPCODE(BASE_HEX), OPCODE(BASE_BIN), OPCODE(BASE_OCT),
            OPCODE(MODE_DEG), OPCODE(MODE_RAD), OPCODE(MODE_GRAD),
            OPCODE(DISP_ALL), OPCODE(DISP_FIX), OPCODE(DISP_SCI), OPCODE(DISP_ENG),
            OPCODE2(CNV_DEGC, "➜°C"), OPCODE2(CNV_DEGF, "➜°F"), OPCODE2(CNV_RAD, "➜DEG"), OPCODE2(CNV_DEG, "➜RAD"), 
            OPCODE2(CNV_HMS, "➜H.MS"), OPCODE2(CNV_H, "➜H"), OPCODE2(CNV_POLAR, "➜θ,r"), OPCODE2(CNV_RECT, "➜x,y"),
            OPCODE2(CNV_UNITS, "CNV"),
            OPCODE(X_MEAN), OPCODE(Y_MEAN), OPCODE(XW_MEAN), OPCODE2(PSD_X, "σx"), OPCODE2(PSD_Y, "σy"), OPCODE2(SSD_X, "sx"), OPCODE2(SSD_Y, "sy"),
            OPCODE2(C_N_R, "C(n,r)"), OPCODE2(P_N_R, "P(n,r)"),
            OPCODE(PAUSE), OPCODE(INPUT),
            OPCODE(NONE),
            nil
        ];
        
        [g_opcodes retain];
    }
    
    return g_opcodes;
}

- (id)initWithCalculator:(Calculator*) calculator
{
    [super init];
    m_calculator = calculator;
    
    m_loopStack = [[NSMutableArray alloc] init];
    m_blockStack = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)dealloc {
    [m_loopStack release];
    [m_blockStack release];

    m_runState = RS_NONE;
    m_stepping = NO;
    [self startExecutionTimer:0];

    [super dealloc];
}

+ (OperationType)operationFromString:(const NSString*) string
{
    NSString* trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    // Ignore comments
    if ([trimmedString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"*/"]].location == 0)
        return OP_NONE;
        
    // Ignore blank lines
    if (![trimmedString length])
        return OP_NONE;

    // Split out the param if needed
    NSArray* array = [string componentsSeparatedByString:@":"];
    if ([array count] != 1 && [array count] != 2)
        return OP_ERROR;
        
    NSString* name = [[array objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    for (NSDictionary* entry in opcodes()) {
        if ([name isEqualToString:[entry objectForKey:@"name"]] || [name isEqualToString:[entry objectForKey:@"symbol"]])
            return [[entry objectForKey:@"op"] intValue];
    }
    
    // Handle Number
    if ([trimmedString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"#0123456789-."]].location == 0)
        return OP_NUM;

    return OP_ERROR;
}

static NSString* operationParamFromString(const NSString* s)
{
    NSString* trimmedString = [s stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];

    // Split out the param if needed
    NSArray* array = [trimmedString componentsSeparatedByString:@":"];
    assert([array count] >= 2);
        
    // Get rid of any second param
    NSArray* paramArray = [[array objectAtIndex:1] componentsSeparatedByString:@"|"];
    assert([paramArray count] > 0);
    return [paramArray objectAtIndex:0];
}

static NSString* operation2ndParamFromString(const NSString* s)
{
    NSString* trimmedString = [s stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];

    // Split out the param if needed
    NSArray* array = [trimmedString componentsSeparatedByString:@":"];
    assert([array count] >= 2);
        
    // Get second param
    NSArray* paramArray = [[array objectAtIndex:1] componentsSeparatedByString:@"|"];
    assert([paramArray count] > 0);
    return ([paramArray count] > 1) ? [paramArray objectAtIndex:1] : @"";
}

+ (NSString*) stringFromOperation:(OperationType) operation
{
    for (NSDictionary* entry in opcodes()) {
        if ([[entry objectForKey:@"op"] intValue] == (int) operation) {
            NSString* name = [entry objectForKey:@"symbol"];
            return name ? name : [entry objectForKey:@"name"];
        }
    }
    return nil;
}

static int regFromString(NSString* string)
{
    // Assumes whitespace has been stripped from the front and back
    if ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-0123456789"]].location == 0)
        return [string intValue];
        
    if ([string length] == 1) {
        unichar c = [string characterAtIndex:0];
        if (c >= 'A' && c <= 'Z')
            return c - 'A';
    }
    
    string = [string lowercaseString];

    if ([string isEqualToString:@"i"])
        return REG_INDEX;
        
    if ([string isEqualToString:@"(i)"])
        return REG_IND_I;
        
    if ([string isEqualToString:@"(i++)"])
        return REG_IND_I_POST_INC;
        
    if ([string isEqualToString:@"(--i)"])
        return REG_IND_I_PRE_DEC;
        
    if ([string isEqualToString:@"(x)"])
        return REG_IND_X;
        
    if ([string isEqualToString:@"n"])
        return STAT_N;
        
    if ([string isEqualToString:@"∑x"] || [string isEqualToString:@"sumx"])
        return STAT_SUM_X;
        
    if ([string isEqualToString:@"∑y"] || [string isEqualToString:@"sumy"])
        return STAT_SUM_Y;
        
    if ([string isEqualToString:@"∑x²"] || [string isEqualToString:@"sumx2"])
        return STAT_SUM_X_2;
        
    if ([string isEqualToString:@"∑y²"] || [string isEqualToString:@"sumy2"])
        return STAT_SUM_Y_2;
        
    if ([string isEqualToString:@"∑xy"] || [string isEqualToString:@"sumxy"])
        return STAT_SUM_X_Y;
        
    return -10;
}

+ (NSString*) stringFromReg:(int) reg
{
    if (reg >= 0 && reg < NUM_ALPHA_REGS)
        return [NSString stringWithFormat:@"%c", reg + 'A'];
    else switch(reg) {
        case REG_INDEX: return @"i";
        case REG_IND_I: return @"(i)";
        case REG_IND_I_POST_INC: return @"(i++)";
        case REG_IND_I_PRE_DEC: return @"(--i)";
        case REG_IND_X: return @"(x)";
        case STAT_N: return @"n";
        case STAT_SUM_X: return @"∑x";
        case STAT_SUM_Y: return @"∑y";
        case STAT_SUM_X_2: return @"∑x²";
        case STAT_SUM_Y_2: return @"∑y²";
        case STAT_SUM_X_Y: return @"∑xy";
        default: return [[NSNumber numberWithInt:reg] stringValue];
    }
}

static NSArray* compileBlock(NSArray* instructions, int* ip, OperationType endOp1, OperationType endOp2, BOOL debug)
{
    // Compile instructions. This looks for blocks and when found puts them into a NSArray and inserts that
    // into the instruction stream in their place. Nested blocks are handled. Blocks are formed by:
    // IF <block> THEN
    // IF <block> ELSE
    // ELSE <block> THEN
    // FOR <block> LOOP
    // DO <block> LOOP
    //
    // All operations are stored as NSNumbers. OP_NUM entries are followed by
    // a Number object. Any other opcode with a parameter has its parameter
    // following it as an NSNumber.    
    NSMutableArray* compiledBlock = [[NSMutableArray alloc] init];
    
    if (endOp1 == OP_LOOP) {
        if (debug)
            [compiledBlock addObject:[NSNumber numberWithInt:*ip]];
        [compiledBlock addObject:[NSNumber numberWithInt:OP_FOR_START]];
    }
    
    for ( ; *ip < (int) [instructions count]; ) {
        NSString* instruction = [instructions objectAtIndex:*ip];
        OperationType operation = [ExecutionUnit operationFromString:instruction];
        NSArray* subBlock = nil;
        
        if (operation == endOp1 || operation == endOp2)
            break;

        if (debug)
            [compiledBlock addObject:[NSNumber numberWithInt:*ip]];
        [compiledBlock addObject:[NSNumber numberWithInt:operation]];
        
        (*ip)++;
        
        switch (operation) {
            case OP_IF:
                subBlock = compileBlock(instructions, ip, OP_ELSE, OP_THEN, debug);
                break;
            case OP_ELSE:
                subBlock = compileBlock(instructions, ip, OP_THEN, OP_NONE, debug);
                break;
            case OP_FOR:
            case OP_DO:
                subBlock = compileBlock(instructions, ip, OP_LOOP, OP_NONE, debug);
                break;
            default: break;
        }
        
        switch (operation) {
            case OP_NUM: {
                BaseType base = DEC;
                if ([instruction characterAtIndex:0] == '#') {
                    if ([instruction characterAtIndex:1] == 'B')
                        base = BIN;
                    else if ([instruction characterAtIndex:1] == 'O')
                        base = BIN;
                }
        
                instruction = [instruction stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" #BO"]];
                Number* number = [Number numberWithString:instruction inBase:base];
                [compiledBlock addObject:number];
                break;
            }
            case OP_STO: case OP_STO_ADD: case OP_STO_SUB: case OP_STO_MUL: case OP_STO_DIV:
            case OP_RCL: case OP_RCL_ADD: case OP_RCL_SUB: case OP_RCL_MUL: case OP_RCL_DIV:
            case OP_CALL: case OP_INPUT:
                [compiledBlock addObject:[NSNumber numberWithInt:regFromString(operationParamFromString(instruction))]];
                if (operation == OP_INPUT)
                    [compiledBlock addObject:operation2ndParamFromString(instruction)];
                break;
            case OP_DISP_ALL: case OP_DISP_FIX: case OP_DISP_SCI: case OP_DISP_ENG:        
                [compiledBlock addObject:[NSNumber numberWithInt:[operationParamFromString(instruction) intValue]]];
                break;
            default: break;
        }
        
        if (subBlock)
            [compiledBlock addObject:subBlock];
    }

    if (endOp1 == OP_LOOP) {
        if (debug)
            [compiledBlock addObject:[NSNumber numberWithInt:*ip]];
        [compiledBlock addObject:[NSNumber numberWithInt:OP_FOR_NEXT]];
    }
    
    return [compiledBlock autorelease];
}

- (void)pushLoopStack:(Number*) number
{
    [m_loopStack addObject:[Number numberWithNumber:number]];
}

- (void)pushLoopStackDummy
{
    [m_loopStack addObject:[[[NSObject alloc] init] autorelease]];
}

- (void)popLoopStack
{
    [m_loopStack removeLastObject];
}

- (Number*)loopStackTOS
{
    id obj = [m_loopStack lastObject];
    return ([obj isKindOfClass:[Number class]]) ? obj : nil;
}

- (Number*)loopStackNOS
{
    id obj = [m_loopStack objectAtIndex:[m_loopStack count] - 2];
    return ([obj isKindOfClass:[Number class]]) ? obj : nil;
}

- (void)pushBlock:(NSArray*) block ofType:(BlockType) type
{
    if (m_inst) {
        if (m_debug)
            [m_blockStack addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                    m_inst, @"inst",
                                    [NSNumber numberWithInt:m_ip], @"ip",
                                    [NSNumber numberWithInt:m_type], @"type",
                                    [NSNumber numberWithInt:m_executingFunction], @"executingFunction",
                                    [NSNumber numberWithInt:m_executingInstruction], @"executingInstruction",
                                    nil]];
        else
            [m_blockStack addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                    m_inst, @"inst",
                                    [NSNumber numberWithInt:m_ip], @"ip",
                                    [NSNumber numberWithInt:m_type], @"type",
                                    nil]];
        [m_inst release];
    }
    
    m_ip = 0;
    m_type = type;
    int ip = 0;
    
    // If the block type is LOOP or IF it will have already been compiled
    m_inst = [(type == BLOCK_CALL) ? compileBlock(block, &ip, OP_NONE, OP_NONE, m_debug) : block retain];
}

- (void)popBlock
{
    [m_inst release];
    m_inst = nil;
    
    if ([m_blockStack count] > 0) {
        NSDictionary* entry = [m_blockStack lastObject];
        
        m_inst = [[entry objectForKey:@"inst"] retain];
        m_ip = [[entry objectForKey:@"ip"] intValue];
        m_type = [[entry objectForKey:@"type"] intValue];
        
        if (m_debug) {
            m_executingFunction = [[entry objectForKey:@"executingFunction"] intValue];
            m_executingInstruction = [[entry objectForKey:@"executingInstruction"] intValue];
            if ((int) [m_inst count] <= m_ip)
                m_executingInstruction++;
            else
                m_executingInstruction = [[m_inst objectAtIndex:m_ip] intValue];
        }

        [m_blockStack removeLastObject];
    }
}

- (OperationStatusType)executeInstruction
{
    static Number* one;
    if (!one)
        one = [[Number numberWithDouble:1] retain];
        
    if (m_ip >= (int) [m_inst count]) {
        switch (m_type) {
            case BLOCK_LOOP: return OS_LOOP;
            case BLOCK_IF: return OS_DONE;
            case BLOCK_CALL: return OS_RET;
        }
    }
    
    // Get the next instruction (skip the ip if in debug mode)
    if (m_debug)
        m_ip++;
    id inst = [m_inst objectAtIndex:m_ip++];
    if (![inst isKindOfClass:[NSNumber class]])
        return OS_ERROR;
    OperationType operation = [inst intValue];
    OperationStatusType opStatus = OS_NORMAL;
        
    // Handle program specific opcodes
    switch (operation) {
        case OP_CALL: {
            NSUInteger function;
            [self pushBlock:[m_calculator instructionsForSubr:[[m_inst objectAtIndex:m_ip++] intValue] function:&function] ofType:BLOCK_CALL];
            if (m_debug)
                m_executingFunction = function;
            break;
        }
        case OP_IF: {
            BOOL cond = ![m_calculator.x zero];
            NSArray* condBlock = nil;
            if (cond)
                condBlock = [m_inst objectAtIndex:m_ip];
            m_ip++;
            
            if ([[m_inst objectAtIndex:m_ip] intValue] == OP_ELSE) {
                m_ip++;
                if (!cond)
                    condBlock = [m_inst objectAtIndex:m_ip];
                m_ip++;
            }
            
            if (condBlock) {
                assert([condBlock isKindOfClass:[NSArray class]]);
                // Push the previous inst and ip onto the call stack
                [self pushBlock:condBlock ofType:BLOCK_IF];
            }
            else if (m_debug)
                m_executingInstruction = [[m_inst objectAtIndex:m_ip] intValue];

            break;
        }
        case OP_FOR:
        case OP_DO: {
            if (operation == OP_FOR) {
                Number* indx = [m_calculator numberFromReg:REG_INDEX];
                [self pushLoopStack:[m_calculator numberFromReg:REG_INDEX]];
                [indx initWithNumber:m_calculator.x];
                [self pushLoopStack:m_calculator.y];
            }
            else {
                [self pushLoopStackDummy];
                [self pushLoopStackDummy];
            }

            [self pushBlock:[m_inst objectAtIndex:m_ip++] ofType:BLOCK_LOOP];
            break;
        }
        case OP_FOR_START:
            // See if we need to break the FOR loop
            if (![self loopStackTOS])
                break;
            if ([[m_calculator numberFromReg:REG_INDEX] compare:[self loopStackTOS]] > 0)
                opStatus = OS_BREAK;
            break;
        case OP_FOR_NEXT: {
            if (![self loopStackTOS])
                break;
            // Increment i
            Number* indx = [m_calculator numberFromReg:REG_INDEX];
            [indx add:one];
            break;
        }
        case OP_LOOP:
            [self popLoopStack];
            if ([self loopStackTOS])
                [[m_calculator numberFromReg:REG_INDEX] initWithNumber:[self loopStackTOS]];
            [self popLoopStack];
            break;
        case OP_BREAK:
            opStatus = OS_BREAK;
            break;
        case OP_BREAKIF:
        case OP_RETIF: {
            BOOL cond = ![m_calculator.x zero];
            if (cond)
                opStatus = (operation == OP_BREAKIF) ? OS_BREAK : OS_RET;
            break;
        }
        case OP_RET:
            opStatus = OS_RET;
            break;
        case OP_PAUSE:
            opStatus = OS_PAUSE;
            break;
        default: break;
    }
    
    // Handle opcodes
    switch (operation) {
        case OP_NUM:
            [m_calculator enterIfNeeded];
            [m_calculator setXFromNumber:[m_inst objectAtIndex:m_ip++]];
            break;
        case OP_STO: case OP_STO_ADD: case OP_STO_SUB: case OP_STO_MUL: case OP_STO_DIV:
        case OP_RCL: case OP_RCL_ADD: case OP_RCL_SUB: case OP_RCL_MUL: case OP_RCL_DIV:
        case OP_DISP_ALL: case OP_DISP_FIX: case OP_DISP_SCI: case OP_DISP_ENG:        
            [m_calculator op:operation withParams:[NSArray arrayWithObject:[m_inst objectAtIndex:m_ip++]]];
            break;
        case OP_CALL:
            break;
        case OP_INPUT:
            [m_calculator op:operation withParams:[NSArray arrayWithObjects:[m_inst objectAtIndex:m_ip], [m_inst objectAtIndex:m_ip + 1], nil]];
            m_ip += 2;
            opStatus = OS_INPUT;
            break;
        default:
            [m_calculator op:operation];
            break;
    }
    
    // For purposes of debugging, we want to step past the special inserted opcodes
    if (operation == OP_DO || operation == OP_FOR_NEXT)
        opStatus = [self executeInstruction];
    
    if (m_debug) {
        if (!m_inst || (int) [m_inst count] <= m_ip)
            m_executingInstruction++;
        else
            m_executingInstruction = [[m_inst objectAtIndex:m_ip] intValue];
    }
    
    return opStatus;
}

- (void)setupExecutionForFunction:(NSUInteger) function withInstructions:(NSArray*) instructions debug:(BOOL) debug;
{
    [m_loopStack removeAllObjects];
    [m_blockStack removeAllObjects];
    
    if (m_inst) {
        [m_inst release];
        m_inst = nil;
    }
    
    m_debug = debug;
    m_executingFunction = function;
    
    [self pushBlock:instructions ofType:BLOCK_CALL];
}

- (ExecutionStatusType)executeNext
{
    for ( ; ; ) {
        OperationStatusType opStatus = [self executeInstruction];
        switch (opStatus) {
            case OS_NORMAL: return XS_NORMAL;
            case OS_PAUSE: return XS_PAUSE;
            case OS_INPUT: return XS_INPUT;
            case OS_ERROR: return XS_ERROR;
            case OS_LOOP:
                m_ip = 0;
                m_executingInstruction = [[m_inst objectAtIndex:m_ip] intValue] - 1;
                return XS_NORMAL;
            case OS_DONE:
                [self popBlock];
                return m_inst ? XS_NORMAL : XS_DONE;
            case OS_BREAK:
                while (m_type != BLOCK_LOOP && m_inst)
                    [self popBlock];
                [self popBlock];
                return m_inst ? XS_NORMAL : XS_DONE;
            case OS_RET:
                while (m_type != BLOCK_CALL && m_inst)
                    [self popBlock];
                [self popBlock];
                return m_inst ? XS_NORMAL : XS_DONE;
        }
    }
}

- (void)setupExecutionOfFunction:(NSString*) name debug:(BOOL) debug
{
    NSUInteger i = 0;
    for (NSDictionary* func in m_calculator.program) {
        if ([[func objectForKey:@"key"] intValue] > 0 && [[func objectForKey:@"name"] isEqualToString:name])
            [self setupExecutionForFunction:i withInstructions:[[m_calculator.program objectAtIndex:i] objectForKey:@"inst"] debug:debug];
        ++i;
    }
}

- (void)setupExecutionOfCurrentFunction:(BOOL) debug
{
    [self setupExecutionForFunction:m_calculator.currentFunction withInstructions:[[m_calculator.program objectAtIndex:m_calculator.currentFunction] objectForKey:@"inst"] debug:debug];
}

- (void)startExecutionTimer:(NSTimeInterval) t
{
    if (m_executionTimer) {
        [m_executionTimer invalidate];
        [m_executionTimer release];
        m_executionTimer = nil;
    }

    if (m_runState == RS_RUNNING || m_runState == RS_PAUSED)
        m_executionTimer = [[NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(fireExecutionTimer) userInfo:nil repeats:NO] retain];
}

- (void)fireExecutionTimer
{
    NSTimeInterval t = 0;
    
    for (int i = 0; i < NUM_EXECUTE_LOOP && m_runState == RS_RUNNING; ++i) {
        ExecutionStatusType xs = [self executeNext];
        
        switch (xs) {
            case XS_NORMAL:
                break;
            case XS_ERROR:
                // FIXME: set error code
                // Fall-through
            case XS_DONE:
                m_runState = RS_NONE;
                break;
            case XS_PAUSE:
                t = PAUSE_TIME;
                m_runState = RS_PAUSED;
                break;
            case XS_INPUT:
                m_runState = RS_STOPPED;
                break;
        }
    }
    
    [m_calculator notifyUpdate];
    [self startExecutionTimer:t];
}

- (BOOL)step
{
    switch (m_runState) {
        case RS_RUNNING:
        case RS_PAUSED:
        case RS_NONE: [self setupExecutionOfCurrentFunction:YES]; break;
        case RS_STOPPED: {
            ExecutionStatusType xs = [self executeNext];
            if (xs == XS_ERROR || xs == XS_DONE) {
                m_runState = RS_NONE;
                m_stepping = NO;
                return NO;
            }
            break;
        }
    }
    
    m_runState = RS_STOPPED;
    m_stepping = YES;
    [self startExecutionTimer:0];
    return YES;
}

- (void)run
{
    if (m_runState == RS_NONE)
        [self setupExecutionOfCurrentFunction:NO];
        
    m_runState = RS_RUNNING;
    m_stepping = NO;
    [self startExecutionTimer:0];
}

- (void)stop
{
    m_stepping = NO;
    m_runState = RS_STOPPED;
    [self startExecutionTimer:0];
}

@end
