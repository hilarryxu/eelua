#include "irrXML.h"
using namespace irr;
using namespace io;

#include "lirrxml.h"

#define YUI_CLASS_IRRXML "yui{irrxml}"
#define YUI_GROUP_IRRXML "yui{:irrxml}" 

#define self(x) ((x)->self)

typedef struct {
    IrrXMLReader *self;
} l_irrxml_t;

static int
l_irrxml__fail(lua_State *L, const char *errmsg)
{
    lua_pushnil(L);
    lua_pushstring(L, errmsg);
    return 2;
}

static int
l_irrxml__new(lua_State *L)
{
    const char *filename = luaL_checkstring(L, 1);
    l_irrxml_t *irrxml = (l_irrxml_t *)lua_newuserdata(L, sizeof(l_irrxml_t));

    auxiliar_setclass(L, YUI_CLASS_IRRXML, -1);
    irrxml->self = createIrrXMLReader(filename);
    if (!self(irrxml)) {
        lua_pop(L, 1);
        return l_irrxml__fail(L, "Create irrxml fail");
    } else {
        return 1;
    }
}

static int
l_irrxml_close(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);

    delete self(irrxml);
    lua_pushnumber(L, 1);

    return 1;
}

static int
l_irrxml_read(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);

    lua_pushboolean(L, self(irrxml)->read());

    return 1;
}

static const char *
lirrxml__nodetype2str(EXML_NODE nodetype)
{
    switch (nodetype) {
        case EXN_NONE: return "none";
        case EXN_ELEMENT: return "tagstart";
        case EXN_ELEMENT_END: return "tagend";
        case EXN_TEXT: return "text";
        case EXN_COMMENT: return "comment";
        case EXN_CDATA: return "cdata";
        case EXN_UNKNOWN: return "unknown";
    }

    return "unknown";
}

static const char *
lirrxml__format2str(ETEXT_FORMAT fmt)
{
    switch (fmt) {
        case ETF_ASCII: return "ascii";
        case ETF_UTF8: return "utf8";
        case ETF_UTF16_BE: return "utf16-be";
        case ETF_UTF16_LE: return "utf16-le";
        case ETF_UTF32_BE: return "utf32-be";
        case ETF_UTF32_LE: return "utf32-le";
    }

    return "unknown";
}

static int
l_irrxml_nodename(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    const char *node_name = self(irrxml)->getNodeName();

    lua_pushstring(L, node_name);

    return 1;
}

static int
l_irrxml_nodetype(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    const char *node_typename = lirrxml__nodetype2str(self(irrxml)->getNodeType());

    lua_pushstring(L, node_typename);

    return 1;
}

static int
l_irrxml_nodedata(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    const char *node_data = self(irrxml)->getNodeData();

    lua_pushstring(L, node_data);

    return 1;
}

static int
l_irrxml_nodeattrcount(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    int count = self(irrxml)->getAttributeCount();

    lua_pushinteger(L, count);

    return 1;
}

static int
l_irrxml_nodeattr(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    const char *attr_name = luaL_checkstring(L, 2);
    const char *attr_value = self(irrxml)->getAttributeValue(attr_name);

    if (attr_value) {
        lua_pushstring(L, attr_value);
        return 1;
    } else {
        return l_irrxml__fail(L, "No this attr");
    }
}

static int
l_irrxml_nodeattrs(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    int i = 0;
    const char *name;

    lua_newtable(L);
    while ((name = self(irrxml)->getAttributeName(i)) != NULL) {
        lua_pushstring(L, name);
        lua_pushstring(L, self(irrxml)->getAttributeValue(i));
        lua_rawset(L, -3);
        ++i;
    }

    return 1;
}

static int
l_irrxml_isemptyelem(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);

    lua_pushboolean(L, self(irrxml)->isEmptyElement());

    return 1;
}

static int
l_irrxml_sourceformat(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    const char *fmt = lirrxml__format2str(self(irrxml)->getSourceFormat());

    lua_pushstring(L, fmt);

    return 1;
}

static int
l_irrxml_parserformat(lua_State *L)
{
    l_irrxml_t *irrxml = (l_irrxml_t *)auxiliar_checkclass(L, YUI_CLASS_IRRXML, 1);
    const char *fmt = lirrxml__format2str(self(irrxml)->getParserFormat());

    lua_pushstring(L, fmt);

    return 1;
}

static luaL_Reg irrxml[] = {
    {"__gc",            l_irrxml_close},
    {"__tostring",      auxiliar_tostring},
    {"close",           l_irrxml_close},
    {"read",            l_irrxml_read},
    {"node_name",       l_irrxml_nodename},
    {"node_type",       l_irrxml_nodetype},
    {"node_data",       l_irrxml_nodedata},
    {"node_attr",       l_irrxml_nodeattr},
    {"node_attrcount",  l_irrxml_nodeattrcount},
    {"node_attrs",      l_irrxml_nodeattrs},
    {"is_emptyelem",   l_irrxml_isemptyelem},
    {"source_format",   l_irrxml_sourceformat},
    {"parser_format",   l_irrxml_parserformat},
    {NULL,              NULL}
};

static luaL_Reg funcs[] = {
    {"new",  l_irrxml__new},
    {NULL,      NULL}
};

int
luaopen_lirrxml(lua_State *L)
{
    auxiliar_newclass(L, YUI_CLASS_IRRXML, irrxml);
    auxiliar_add2group(L, YUI_CLASS_IRRXML, YUI_GROUP_IRRXML);
    luaL_newlib(L, funcs);
    auxiliar_setinfo(L, LUAIRRXML_COPYRIGHT, LUAIRRXML_DESCRIPTION, LUAIRRXML_VERSION);

    return 1;
}

