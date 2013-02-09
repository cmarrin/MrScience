//
//  Calculator.m
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "Calculator.h"

#import "InstructionUnit.h"
#import "ExecutionUnit.h"
#import "ProgramStore.h"

@implementation Calculator

- (RunStateType)runState
{
    return m_executionUnit ? m_executionUnit.runState : RS_NONE;
}

- (BOOL) stepping
{
    return m_executionUnit ? m_executionUnit.stepping : NO;
}

- (Number*)x { return m_instructionUnit.x; }
- (Number*)y { return m_instructionUnit.y; }
- (Number*)z { return m_instructionUnit.z; }
- (Number*)t { return m_instructionUnit.t; }
- (Number*)lastX { return m_instructionUnit.lastX; }
- (ModeType)mode { return m_instructionUnit.mode; }
- (BaseType)base { return m_instructionUnit.base; }
- (DispType)disp { return m_instructionUnit.disp; }
- (int)dispSignificantDigits { return m_instructionUnit.dispSignificantDigits; }
- (NSString*)inputPrompt { return m_instructionUnit.inputPrompt; }
- (NSUInteger)currentFunction { return m_programStore.currentFunction; }
- (NSUInteger)currentInstruction { return m_programStore.currentInstruction; }
- (NSUInteger)executingFunction { return m_executionUnit ? m_executionUnit.executingFunction : 0; }
- (NSUInteger)executingInstruction { return m_executionUnit ? m_executionUnit.executingInstruction : 0; }
- (InputModeType)inputMode { return m_instructionUnit.inputMode; }
- (NSArray*)program { return m_programStore.program; }

- (BOOL)programming
{
    return m_programming;
}

- (void)setProgramming:(BOOL) b
{
    m_programming = b;
    [self notifyUpdate];
}

- (NSString*)title
{
    return m_programStore.title;
}

- (void)setTitle:(NSString*) s
{
    m_programStore.title = s;
    [self notifyUpdate];
}

- (NSString*)category
{
    return m_programStore.category;
}

- (void)setCategory:(NSString*) s
{
    m_programStore.category = s;
    [self notifyUpdate];
}

- (NSString*)description
{
    return m_programStore.description;
}

- (void)setDescription:(NSString*) s
{
    m_programStore.description = s;
    [self notifyUpdate];
}

+ (NSArray*)programList
{
    return [ProgramStore programList];
}

- (id)init
{
    m_instructionUnit = [[InstructionUnit alloc] initWithCalculator:self];
    m_programStore = [[ProgramStore alloc] init];
    m_updateNotifications = [[NSMutableArray alloc] init];
    
    NSString *solvePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    solvePath = [solvePath stringByAppendingString:@"/Solve.mrscience"];
    m_solveProgramStore = [[ProgramStore alloc] initWithProgramPath:solvePath];
    return self;
}

- (void)dealloc
{
    [m_programStore release];
    [m_executionUnit release];
    [m_updateNotifications release];
    [super dealloc];
}

- (Number*)numberFromReg:(int) reg
{
    return [m_instructionUnit numberFromReg:reg];
}

- (void)enterIfNeeded
{
    [m_instructionUnit enter:NO];
    [self notifyUpdate];
}

- (void)terminateExecution
{
    if (m_executionUnit) {
        [m_executionUnit release];
        m_executionUnit = nil;
        [self notifyUpdate];
    }
}

- (void)nameCurrentSubroutine:(int) reg
{
    [self terminateExecution];
    [m_programStore nameCurrentSubroutine:reg];
    [self notifyUpdate];
}

- (BOOL)canAssignUserKey
{
    return [m_programStore canAssignUserKey];
}

- (void)nameCurrentFunction:(NSString*) name
{
    [self terminateExecution];
    [m_programStore nameCurrentFunction:name];
    [self notifyUpdate];
}

- (void)addFunction
{
    [self terminateExecution];
    [m_programStore addFunction];
    [self notifyUpdate];
}

- (void)deleteCurrentFunction
{
    [self terminateExecution];
    [m_programStore deleteCurrentFunction];
    [self notifyUpdate];
}

- (void)deleteCurrentInstruction
{
    [self terminateExecution];
    [m_programStore deleteCurrentInstruction];
    [self notifyUpdate];
}

- (void)currentFunctionName:(NSString**) name key:(int*) key
{
    NSDictionary* func = [self.program objectAtIndex:self.currentFunction];
    *name = [func objectForKey:@"name"];
    *key = [[func objectForKey:@"key"] intValue];
}

- (NSString*)functionNameForKey:(int) key
{
    if (key <= 0 || key > 9)
        return nil;
        
    for (NSDictionary* func in self.program)
        if ([[func objectForKey:@"key"] intValue] == key)
            return [func objectForKey:@"name"];
    
    return nil;
}

- (void)selectFunction:(NSUInteger) func instruction:(NSUInteger) inst
{
    [m_programStore selectFunction:func instruction:inst];
    [self notifyUpdate];
}

- (void)addInstructionString:(NSString*) instruction
{
    [self terminateExecution];
    [m_programStore addInstructionString:instruction];
    [self notifyUpdate];
}

- (void)clearProgramStore
{
    [m_programStore clear];
    [self notifyUpdate];
}

- (NSArray*)instructionsForSubr:(int) reg function:(NSUInteger*) function
{
    return [m_programStore instructionsForSubr:reg function:function];
}

- (void)setXFromString:(NSString*) string
{
    [m_instructionUnit setXFromString:string];
    [self notifyUpdate];
}

- (void)setXFromNumber:(Number*) number
{
    [m_instructionUnit setXFromNumber:number];
    [self notifyUpdate];
}

- (NSArray*)conversionTypes
{
    return [m_instructionUnit conversionTypes];
}

- (NSArray*)conversionsForClass:(int) clas index:(int) indx
{
    return [m_instructionUnit conversionsForClass:clas index:indx];
}

- (void)convertWithClass:(int) clas fromIndex:(int) fromIndex toIndex:(int) toIndex
{
    [m_instructionUnit convertWithClass:clas fromIndex:fromIndex toIndex:toIndex];
    [self notifyUpdate];
}

- (void)op:(OperationType) operation
{
    [m_instructionUnit op:operation];
    [self notifyUpdate];
}

- (void)op:(OperationType) operation withParams:(NSArray*) params
{
    [m_instructionUnit op:operation withParams:params];
    [self notifyUpdate];
}

- (void)addUpdateNotificationWithTarget:(id) target selector:(SEL) selector
{
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[[target class] instanceMethodSignatureForSelector:selector]];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    [m_updateNotifications addObject:invocation];
}

- (void)removeAllUpdateNotificationsForTarget:(id) target
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (NSInvocation* invocation in m_updateNotifications) {
        if ([invocation target] == target)
            [array addObject:invocation];
    }
    
    for (NSInvocation* invocation in array)
        [m_updateNotifications removeObject:invocation];
}

- (void)fireUpdateNotificationTimer
{
    m_updateNotificationTimer = nil;
    
    for (NSInvocation* invocation in m_updateNotifications)
        [invocation invoke];
}

- (void)notifyUpdate
{
    if (m_updateNotificationTimer)
        return;

    m_updateNotificationTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(fireUpdateNotificationTimer) userInfo:nil repeats:NO];
}

+ (NSDictionary*)detailsForProgram:(NSString*) title withCategory:(NSString*)category
{
    return [ProgramStore detailsForProgram:title withCategory:category];
}

- (void)loadProgram:(NSString*) title withCategory:(NSString*) category
{
    [m_programStore loadProgram:title withCategory:category];
}

- (void)setProgramDescriptor:(NSDictionary*) program
{
    [m_programStore setProgramDescriptor:program];
}

- (NSString*)programToPropertyListString
{
    return [m_programStore programToPropertyListString];
}

- (void)createExecutionUnit
{
    m_programming = NO;
    
    // FIXME - If return is ERROR, handle the error
    [self terminateExecution];
        
    m_executionUnit = [[ExecutionUnit alloc] initWithCalculator:self];
}

- (void)step
{
    m_programming = NO;

    if (!m_executionUnit || !m_executionUnit.stepping)
        [self createExecutionUnit];
        
    if (![m_executionUnit step])
        [self terminateExecution];
    
    [self notifyUpdate];
}

- (void)run
{
    m_programming = NO;

    if (!m_executionUnit || m_executionUnit.stepping)
        [self createExecutionUnit];

    if (m_instructionUnit.inputMode != IM_NONE)
        [m_instructionUnit inputComplete:YES];
    
    [m_executionUnit run];
    [self notifyUpdate];
}

- (void)stop
{
    if (!m_executionUnit)
        return;
    [m_executionUnit stop];
    [self notifyUpdate];
}

- (void)quit
{
    if (m_instructionUnit.inputMode != IM_NONE)
        [m_instructionUnit inputComplete:NO];
    
    [self terminateExecution];
    [self notifyUpdate];
}

- (void)cleanup
{
    [m_programStore cleanup];
}

@end
