local ffi = require "ffi"
local bit = require "bit"
local string = require "string"
local table = require "table"

local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_cast = ffi.cast

local is_luajit = pcall(require, "jit")
local clib
local consts = {}

---
-- aux
---
local aux = {}

if is_luajit then
  function aux.is_null(ptr)
    return ptr == nil
  end
else
  function aux.is_null(ptr)
    return ptr == ffi.C.NULL
  end
end

function aux.wrap_string(c_str)
  if not aux.is_null(c_str) then
    return ffi_str(c_str)
  end
  return nil
end

function aux.wrap_bool(c_bool)
  return c_bool ~= 0
end


---
-- sqlite3
---
local _M = {}

local function init_mod(mod, opts)
  if clib ~= nil then
    return mod
  end

  clib = _M._load_clib(opts)
  _M.C = clib
  _M._bind_clib()
  return mod
end

function _M._load_clib(opts)
  if opts == nil then
    return ffi.C
  end

  return ffi.load(opts)
end

function _M._bind_clib()
  _M.consts = consts

  consts.OK = 0

  consts.ERROR        = 1
  consts.INTERNAL     = 2
  consts.PERM         = 3
  consts.ABORT        = 4
  consts.BUSY         = 5
  consts.LOCKED       = 6
  consts.NOMEM        = 7
  consts.READONLY     = 8
  consts.INTERRUPT    = 9
  consts.IOERR        = 10
  consts.CORRUPT      = 11
  consts.NOTFOUND     = 12
  consts.FULL         = 13
  consts.CANTOPEN     = 14
  consts.PROTOCOL     = 15
  consts.EMPTY        = 16
  consts.SCHEMA       = 17
  consts.TOOBIG       = 18
  consts.CONSTRAINT   = 19
  consts.MISMATCH     = 20
  consts.MISUSE       = 21
  consts.NOLFS        = 22
  consts.AUTH         = 23
  consts.FORMAT       = 24
  consts.RANGE        = 25
  consts.NOTADB       = 26
  consts.NOTICE       = 27
  consts.WARNING      = 28
  consts.ROW          = 100
  consts.DONE         = 101

  consts.INTEGER  = 1
  consts.FLOAT    = 2
  consts.TEXT     = 3
  consts.BLOB     = 4
  consts.NULL     = 5

  if not is_luajit then
    consts.C_NULL = ffi.C.NULL
  end

  consts.OPEN_READONLY         = 0x00000001
  consts.OPEN_READWRITE        = 0x00000002
  consts.OPEN_CREATE           = 0x00000004
  consts.OPEN_URI              = 0x00000040
  consts.OPEN_MEMORY           = 0x00000080
  consts.OPEN_NOMUTEX          = 0x00008000
  consts.OPEN_FULLMUTEX        = 0x00010000
  consts.OPEN_SHAREDCACHE      = 0x00020000
  consts.OPEN_PRIVATECACHE     = 0x00040000
  consts.OPEN_NOFOLLOW         = 0x01000000

  ffi.cdef [[
    typedef __int64 sqlite3_int64;
    typedef unsigned __int64 sqlite3_uint64;

    typedef void (*sqlite3_destructor_type)(void *);

    typedef struct sqlite3 sqlite3;
    typedef struct sqlite3_stmt sqlite3_stmt;
    typedef struct sqlite3_value sqlite3_value;
  ]]

  consts.STATIC = ffi_cast("sqlite3_destructor_type", 0)
  consts.TRANSIENT = ffi_cast("sqlite3_destructor_type", -1)

  ffi.cdef [[
    const char *sqlite3_libversion();
    const char *sqlite3_sourceid();
    int sqlite3_libversion_number();

    int sqlite3_threadsafe();
    void sqlite3_free(void*);

    int sqlite3_errcode(sqlite3 *);
    const char *sqlite3_errmsg(sqlite3 *);
    int sqlite3_extended_errcode(sqlite3 *);
    const char *sqlite3_errstr(int);
    int sqlite3_extended_result_codes(sqlite3 *, int);
  ]]

  function _M.libversion()
    return aux.wrap_string(clib.sqlite3_libversion())
  end

  function _M.sourceid()
    return aux.wrap_string(clib.sqlite3_sourceid())
  end

  function _M.libversion_number()
    return clib.sqlite3_libversion_number()
  end

  function _M.threadsafe()
    -- return 0, 1, or 2
    return clib.sqlite3_threadsafe()
  end

  function _M.free(pointer)
    clib.sqlite3_free(pointer)
  end

  function _M.extended_result_codes(db, onoff)
    return clib.sqlite3_extended_result_codes(db, onoff)
  end

  function _M.errcode(db)
    return clib.sqlite3_errcode(db)
  end

  function _M.extended_errcode(db)
    return clib.sqlite3_extended_errcode(db)
  end

  function _M.errmsg(db)
    return aux.wrap_string(clib.sqlite3_errmsg(db))
  end

  function _M.errstr(code)
    return aux.wrap_string(clib.sqlite3_errstr(code))
  end

  ffi.cdef [[
    int sqlite3_open(const char *, sqlite3 **);
    int sqlite3_open_v2(const char *, sqlite3 **, int, const char *);
    int sqlite3_close(sqlite3 *);
    int sqlite3_close_v2(sqlite3 *);
  ]]

  function _M.open(filename)
    local db_p = ffi_new("sqlite3*[1]")
    local rc = clib.sqlite3_open(filename, db_p)
    return rc, db_p[0]
  end

  function _M.open_v2(filename, flags, vfs)
    local db_p = ffi_new("sqlite3*[1]")
    local rc = clib.sqlite3_open_v2(filename, db_p, flags, vfs)
    return rc, db_p[0]
  end

  function _M.close(db)
    return clib.sqlite3_close(db)
  end

  function _M.close_v2(db)
    return clib.sqlite3_close_v2(db)
  end

  ffi.cdef [[
    int sqlite3_exec(sqlite3 *, const char *sql,
      int (*callback)(void *arg1, int argc, char **argv, char **col_names),
      void *arg1,
      char **errmsg
    );
    sqlite3_int64 sqlite3_last_insert_rowid(sqlite3 *);
    void sqlite3_set_last_insert_rowid(sqlite3 *, sqlite3_int64);
  ]]

  function _M.exec(db, sql, callback, arg1, errmsg)
    if errmsg == true then
      local cstr = ffi_new("char*[1]")
      local rc = clib.sqlite3_exec(db, sql, callback, arg1, cstr)
      local errstr = aux.wrap_string(cstr[0])
      clib.sqlite3_free(cstr[0])
      return rc, errstr
    end
    return clib.sqlite3_exec(db, sql, callback, arg1, errmsg)
  end

  function _M.last_insert_rowid(db)
    return clib.sqlite3_last_insert_rowid(db)
  end

  function _M.set_last_insert_rowid(db, rowid)
    clib.sqlite3_set_last_insert_rowid(db, rowid)
  end

  ffi.cdef [[
    int sqlite3_prepare(sqlite3*, const char*, int, sqlite3_stmt**, const char**);
    int sqlite3_prepare_v2(sqlite3 *,
      const char *sql,
      int nbytes,
      sqlite3_stmt **ppStmt,
      const char **pzTail);
    int sqlite3_finalize(sqlite3_stmt*);
  ]]

  function _M.prepare_v2(db, sql)
    local pstmt = ffi.new("sqlite3_stmt*[1]")
    local rc = clib.sqlite3_prepare_v2(db, sql, #sql + 1, pstmt, nil);
    if rc == consts.OK then
      return rc, pstmt[0]
    else
      return rc, nil
    end
  end

  function _M.finalize(stmt)
    return clib.sqlite3_finalize(stmt)
  end

  ffi.cdef [[
    int sqlite3_step(sqlite3_stmt *);
    int sqlite3_reset(sqlite3_stmt *);
    int sqlite3_clear_bindings(sqlite3_stmt *);
  ]]

  function _M.step(stmt)
    return clib.sqlite3_step(stmt)
  end

  function _M.reset(stmt)
    return clib.sqlite3_reset(stmt)
  end

  function _M.clear_bindings(stmt)
    return clib.sqlite3_sqlite3_clear_bindings(stmt)
  end

  ffi.cdef [[
    int sqlite3_bind_parameter_count(sqlite3_stmt*);
    const char *sqlite3_bind_parameter_name(sqlite3_stmt*, int);
    int sqlite3_bind_parameter_index(sqlite3_stmt*, const char*);
  ]]

  function _M.bind_parameter_count(stmt)
    return clib.sqlite3_bind_parameter_count(stmt)
  end

  function _M.bind_parameter_name(stmt, index)
    return aux.wrap_string(clib.sqlite3_bind_parameter_name(stmt, index))
  end

  function _M.bind_parameter_index(stmt, name)
    return clib.sqlite3_bind_parameter_index(stmt, name)
  end

  ffi.cdef [[
    int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
    int sqlite3_bind_blob64(sqlite3_stmt*, int, const void*, sqlite3_uint64, void(*)(void*));
    int sqlite3_bind_double(sqlite3_stmt*, int, double);
    int sqlite3_bind_int(sqlite3_stmt *, int index, int value);
    int sqlite3_bind_int64(sqlite3_stmt*, int, sqlite3_int64);
    int sqlite3_bind_null(sqlite3_stmt*, int);
    int sqlite3_bind_text(sqlite3_stmt*, int, const char*, int, void(*)(void*));
    int sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
    int sqlite3_bind_pointer(sqlite3_stmt*, int, void*, const char*, void(*)(void*));
  ]]

  function _M.bind_blob(stmt, index, pointer, size, destructor)
    return clib.sqlite3_bind_blob(stmt, index, pointer, size, destructor)
  end

  function _M.bind_blob64(stmt, index, pointer, size, destructor)
    return clib.sqlite3_bind_blob64(stmt, index, pointer, size, destructor)
  end

  function _M.bind_double(stmt, index, value)
    return clib.sqlite3_bind_double(stmt, index, value)
  end

  function _M.bind_int(stmt, index, value)
    return clib.sqlite3_bind_int(stmt, index, value)
  end

  function _M.bind_null(stmt, index)
    return clib.sqlite3_bind_null(stmt, index)
  end

  function _M.bind_text(stmt, index, text, nbytes, destructor)
    if type(text) == "string" then
      return clib.sqlite3_bind_text(stmt, index, text, nbytes or #text + 1, nil)
    end
    return clib.sqlite3_bind_text(stmt, index, text, nbytes, destructor)
  end

  function _M.bind_value(stmt, index, value)
    return clib.sqlite3_bind_value(stmt, index, value)
  end

  function _M.bind_pointer(stmt, index, pointer, p_type, destructor)
    return clib.sqlite3_bind_pointer(stmt, index, pointer, p_type, destructor)
  end

  ffi.cdef [[
    int sqlite3_data_count(sqlite3_stmt *);
    int sqlite3_column_count(sqlite3_stmt *);
    const char *sqlite3_column_name(sqlite3_stmt *, int);
    const char *sqlite3_column_decltype(sqlite3_stmt *, int);
  ]]

  function _M.data_count(stmt)
    return clib.sqlite3_data_count(stmt)
  end

  function _M.column_count(stmt)
    return clib.sqlite3_column_count(stmt)
  end

  function _M.column_name(stmt, index)
    return aux.wrap_string(clib.sqlite3_column_name(stmt, index))
  end

  function _M.column_decltype(stmt, index)
    return aux.wrap_string(clib.sqlite3_column_decltype(stmt, index))
  end

  ffi.cdef [[
    const void *sqlite3_column_blob(sqlite3_stmt*, int);
    double sqlite3_column_double(sqlite3_stmt*, int);
    int sqlite3_column_int(sqlite3_stmt*, int);
    sqlite3_int64 sqlite3_column_int64(sqlite3_stmt*, int);
    const char *sqlite3_column_text(sqlite3_stmt*, int);
    sqlite3_value *sqlite3_column_value(sqlite3_stmt*, int);
    int sqlite3_column_bytes(sqlite3_stmt*, int);
    int sqlite3_column_type(sqlite3_stmt*, int);
  ]]

  function _M.column_blob(stmt, column)
    return clib.sqlite3_column_blob(stmt, column)
  end

  function _M.column_double(stmt, column)
    return clib.sqlite3_column_double(stmt, column)
  end

  function _M.column_int(stmt, column)
    return clib.sqlite3_column_int(stmt, column)
  end

  function _M.column_int64(stmt, column)
    return clib.sqlite3_column_int64(stmt, column)
  end

  function _M.column_text(stmt, column)
    return aux.wrap_string(clib.sqlite3_column_text(stmt, column))
  end

  function _M.column_value(stmt, column)
    return clib.sqlite3_column_value(stmt, column)
  end

  function _M.column_bytes(stmt, column)
    return clib.sqlite3_column_bytes(stmt, column)
  end

  function _M.column_type(stmt, column)
    return clib.sqlite3_column_type(stmt, column)
  end

  ffi.cdef [[
    const char *sqlite3_sql(sqlite3_stmt*);
    char *sqlite3_expanded_sql(sqlite3_stmt*);
    const char *sqlite3_normalized_sql(sqlite3_stmt *pStmt);
  ]]

  function _M.sql(stmt)
    return aux.wrap_string(clib.sqlite3_sql(stmt))
  end

  function _M.expanded_sql(stmt)
    local cstr = clib.sqlite3_expanded_sql(stmt)
    local lstr = ffi_str(cstr)
    clib.sqlite3_free(cstr)
    return lstr
  end

  function _M.normalized_sql(stmt)
    return aux.wrap_string(clib.sqlite3_normalized_sql(stmt))
  end
end

return setmetatable(_M, {
  __call = init_mod
})
