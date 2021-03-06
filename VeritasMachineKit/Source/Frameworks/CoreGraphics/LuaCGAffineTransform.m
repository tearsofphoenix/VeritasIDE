//
//  LuaCGAffineTransform.m
//  LuaIOS
//
//  Created by tearsofphoenix on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "LuaCGAffineTransform.h"
#import "LuaObjCAuxiliary.h"
#import "LuaCGGeometry.h"
#import "LuaObjCFrameworkFunctions.h"

static int lua_CGAffineTransformIndex(lua_State *L)
{
    CGAffineTransform *t = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
    const char *fieldName = lua_tostring(L, 2);
    if (!strcmp(fieldName, "a"))
    {
        lua_pushnumber(L, t->a);
        return 1;
    }else if (!strcmp(fieldName, "b"))
    {
        lua_pushnumber(L, t->b);
        return 1;
    }else if (!strcmp(fieldName, "c"))
    {
        lua_pushnumber(L, t->c);
        return 1;
    }else if (!strcmp(fieldName, "d"))
    {
        lua_pushnumber(L, t->d);
        return 1;
    }else if (!strcmp(fieldName, "tx"))
    {
        lua_pushnumber(L, t->tx);
        return 1;
    }else if (!strcmp(fieldName, "ty"))
    {
        lua_pushnumber(L, t->ty);
        return 1;
    }
    
    return 0;
}

static int lua_CGAffineTransformNewIndex(lua_State *L)
{
    CGAffineTransform *t = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
    const char *fieldName = lua_tostring(L, 2);
    if (!strcmp(fieldName, "a"))
    {
        t->a = lua_tonumber(L, 3);
        
    }else if (!strcmp(fieldName, "b"))
    {
        t->b = lua_tonumber(L, 3);
    }else if (!strcmp(fieldName, "c"))
    {
        t->c = lua_tonumber(L, 3);
    }else if (!strcmp(fieldName, "d"))
    {
        t->d = lua_tonumber(L, 3);
    }else if (!strcmp(fieldName, "tx"))
    {
        t->tx = lua_tonumber(L, 3);
    }else if (!strcmp(fieldName, "ty"))
    {
        t->ty = lua_tonumber(L, 3);
    }
    
    return 0;
}

int LuaObjCPushCGAffineTransform(lua_State *L, CGAffineTransform t)
{
    CGAffineTransform *trans = lua_newuserdata(L, sizeof(CGAffineTransform));
    trans->a = t.a;
    trans->b = t.b;
    trans->c = t.c;
    trans->d = t.d;
    trans->tx = t.tx;
    trans->ty = t.ty;
    
    luaL_getmetatable(L, LUA_CGAffineTransform_METANAME);
    lua_setmetatable(L, -2);
    return 1;

}

static int lua_CGAffineTransformMake(lua_State *L)
{
   LuaObjCPushCGAffineTransform(L, CGAffineTransformMake(lua_tonumber(L, 1), 
                                                      lua_tonumber(L, 2), 
                                                      lua_tonumber(L, 3),
                                                      lua_tonumber(L, 4), 
                                                      lua_tonumber(L, 5), 
                                                      lua_tonumber(L, 6)));
    return 1;
}

static int lua_CGAffineTransformMakeTranslation(lua_State *L)
{
   LuaObjCPushCGAffineTransform(L,  CGAffineTransformMakeTranslation(lua_tonumber(L, 1), 
                                                                  lua_tonumber(L, 2)));
    return 1;
}

static int lua_CGAffineTransformMakeScale(lua_State *L)
{
    LuaObjCPushCGAffineTransform(L, CGAffineTransformMakeScale(lua_tonumber(L, 1),
                                                            lua_tonumber(L, 2)));
    return 1;
}

static int lua_CGAffineTransformMakeRotation(lua_State *L)
{
   LuaObjCPushCGAffineTransform(L, CGAffineTransformMakeRotation(lua_tonumber(L, 1)));
    return 1;
}

static int lua_CGAffineTransformIsIdentity(lua_State *L)
{
    CGAffineTransform *t = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
    lua_pushboolean(L, CGAffineTransformIsIdentity(*t));
    return 1;
}

static int lua_CGAffineTransformTranslate(lua_State *L)
{
    CGAffineTransform *t = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);

   LuaObjCPushCGAffineTransform(L, CGAffineTransformTranslate(*t, lua_tonumber(L, 2), lua_tonumber(L, 3)));
    return 1;
}

static int lua_CGAffineTransformScale(lua_State *L)
{
    CGAffineTransform *t = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
   LuaObjCPushCGAffineTransform(L, CGAffineTransformScale(*t, lua_tonumber(L, 2), lua_tonumber(L, 3)));
    return 1;
}

static int lua_CGAffineTransformRotate(lua_State *L)
{
    CGAffineTransform *t = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
    LuaObjCPushCGAffineTransform(L, CGAffineTransformRotate(*t, lua_tonumber(L, 2)));
    return 1;
}

static int lua_CGAffineTransformInvert(lua_State *L)
{
    CGAffineTransform *t = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
    LuaObjCPushCGAffineTransform(L, CGAffineTransformInvert(*t));
    return 1;
}

static int lua_CGAffineTransformConcat(lua_State *L)
{
    CGAffineTransform *t1 = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
    CGAffineTransform *t2 = luaL_checkudata(L, 2, LUA_CGAffineTransform_METANAME);

    LuaObjCPushCGAffineTransform(L, CGAffineTransformConcat(*t1, *t2));
    return 1;
}

static int lua_CGAffineTransformEqualToTransform(lua_State *L)
{
    CGAffineTransform *t1 = luaL_checkudata(L, 1, LUA_CGAffineTransform_METANAME);
    CGAffineTransform *t2 = luaL_checkudata(L, 2, LUA_CGAffineTransform_METANAME);

    lua_pushboolean(L, CGAffineTransformEqualToTransform(*t1, *t2));
    return 1;
}

static int lua_CGPointApplyAffineTransform(lua_State *L)
{
    CGPoint *p = luaL_checkudata(L, 1, LUA_CGPoint_METANAME);
    CGAffineTransform *t = luaL_checkudata(L, 2, LUA_CGAffineTransform_METANAME);

    LuaObjCPushCGPoint(L, CGPointApplyAffineTransform(*p, *t));
    return 1;
}

static int lua_CGSizeApplyAffineTransform(lua_State *L)
{
    CGSize *size = luaL_checkudata(L, 1, LUA_CGSize_METANAME);
    CGAffineTransform *t = luaL_checkudata(L, 2, LUA_CGAffineTransform_METANAME);
    LuaObjCPushCGSize(L, CGSizeApplyAffineTransform(*size, *t));
    return 1;
}

static int lua_CGRectApplyAffineTransform(lua_State *L)
{
    CGRect *rect = luaL_checkudata(L, 1, LUA_CGRect_METANAME);
    CGAffineTransform *t = luaL_checkudata(L, 2, LUA_CGAffineTransform_METANAME);
    LuaObjCPushCGRect(L, CGRectApplyAffineTransform(*rect, *t));
    return 1;
}

static const luaL_Reg __luaCGAffineTransformAPIs[] = 
{
    {"CGAffineTransformMake", lua_CGAffineTransformMake},
    {"CGAffineTransformMakeTranslation", lua_CGAffineTransformMakeTranslation},
    {"CGAffineTransformMakeScale", lua_CGAffineTransformMakeScale},
    {"CGAffineTransformMakeRotation", lua_CGAffineTransformMakeRotation},
    {"CGAffineTransformIsIdentity", lua_CGAffineTransformIsIdentity},
    {"CGAffineTransformTranslate", lua_CGAffineTransformTranslate},
    {"CGAffineTransformScale", lua_CGAffineTransformScale},
    {"CGAffineTransformRotate", lua_CGAffineTransformRotate},
    {"CGAffineTransformInvert", lua_CGAffineTransformInvert},
    {"CGAffineTransformConcat", lua_CGAffineTransformConcat},
    {"CGAffineTransformEqualToTransform", lua_CGAffineTransformEqualToTransform},
    {"CGPointApplyAffineTransform", lua_CGPointApplyAffineTransform},
    {"CGSizeApplyAffineTransform", lua_CGSizeApplyAffineTransform},
    {"CGRectApplyAffineTransform", lua_CGRectApplyAffineTransform},
    {NULL, NULL},
};

static const luaL_Reg __luaCGAffineTransformMetaMethods[] =
{
    {"__gc", LuaInternalStructGarbageCollection},
    {"__index", lua_CGAffineTransformIndex},
    {"__newindex", lua_CGAffineTransformNewIndex},
    {NULL, NULL},
};

int LuaObjCOpenCGAffineTransform(lua_State *L)
{
    LuaObjCLoadCreateMetatable(L, LUA_CGAffineTransform_METANAME, __luaCGAffineTransformMetaMethods);

    LuaObjCLoadGlobalFunctions(L, __luaCGAffineTransformAPIs);
    
    return 0;
}
