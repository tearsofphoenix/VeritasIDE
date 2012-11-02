//
//  VDELuaCompiler.m
//  VeritasIDE
//
//  Created by tearsofphoenix on 12-11-1.
//
//

#import "VDELuaCompiler.h"
#import <LuaCore/LuaCore.h>
/*
 ** $Id: luac.c,v 1.54 2006/06/02 17:37:11 lhf Exp $
 ** Lua compiler (saves bytecodes to files; also list bytecodes)
 ** See Copyright Notice in lua.h
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define luac_c
#define LUA_CORE

//#import <LuaCore/ldo.h>
//#import <LuaCore/lfunc.h>
//#import <LuaCore/lmem.h>
//
//#import <LuaCore/lobject.h>
//#import <LuaCore/lopcodes.h>
//#import <LuaCore/lstring.h>
//#import <LuaCore/lundump.h>

#define PROGNAME	"luac"		/* default program name */
#define	OUTPUT		PROGNAME ".out"	/* default output file */

static int listing=0;			/* list bytecodes? */
static int dumping=1;			/* dump bytecodes? */
static int stripping=0;			/* strip debug information? */
static char Output[]={ OUTPUT };	/* default output file name */
static const char* output=Output;	/* actual output file name */
static const char* progname=PROGNAME;	/* actual program name */

static void fatal(const char* message)
{
    fprintf(stderr,"%s: %s\n",progname,message);
    exit(EXIT_FAILURE);
}

static void cannot(const char* what)
{
    fprintf(stderr,"%s: cannot %s %s: %s\n",progname,what,output,strerror(errno));
    exit(EXIT_FAILURE);
}

#define toproto(L,i) (clvalue(L->top+(i))->l.p)

static const Proto* combine(lua_State* L, int n)
{
    if (n==1)
        return toproto(L,-1);
    else
    {
        int i,pc;
        Proto* f=luaF_newproto(L);
        setptvalue2s(L,L->top,f); incr_top(L);
        f->source=luaS_newliteral(L,"=(" PROGNAME ")");
        f->maxstacksize=1;
        pc=2*n+1;
        f->code=luaM_newvector(L,pc,Instruction);
        f->sizecode=pc;
        f->p=luaM_newvector(L,n,Proto*);
        f->sizep=n;
        pc=0;
        for (i=0; i<n; i++)
        {
            f->p[i]=toproto(L,i-n-1);
            f->code[pc++]=CREATE_ABx(OP_CLOSURE,0,i);
            f->code[pc++]=CREATE_ABC(OP_CALL,0,1,1);
        }
        f->code[pc++]=CREATE_ABC(OP_RETURN,0,1,0);
        return f;
    }
}

static int writer(lua_State* L, const void* p, size_t size, void* u)
{
    UNUSED(L);
    return (fwrite(p,size,1, (FILE*)u)!=1) && (size!=0);
}


@implementation VDELuaCompiler

static struct lua_State s_VDELuaCompilerState = NULL;

+ (void)initialize
{
    s_VDELuaCompilerState = luaL_newstate();
}

+ (void)compileLuaSourceCode: (NSString *)sourceCode
                toFileAtPath: (NSString *)path
{
    f=combine(s_VDELuaCompilerState, argc);

    FILE* D= (output==NULL) ? stdout : fopen(output,"wb");
    if (D==NULL)
    {
        cannot("open");
    }
    
    lua_lock(s_VDELuaCompilerState);
    
    luaU_dump(s_VDELuaCompilerState, f, writer, D, stripping);
    
    lua_unlock(s_VDELuaCompilerState);
    
    if (ferror(D))
    {
        cannot("write");
    }
    
    if (fclose(D))
    {
        cannot("close");
    }
}

@end
