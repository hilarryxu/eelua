--
-- Class
--

local Class = {}

Class.__version__ = '0.1.0'
Class.__name__ = 'Class'

Class.extend = function(super_class, properties)
  properties = properties or {}
  local cls = {}

  -- Import mixins to class
  for _, mixin in ipairs(properties.__include__ or {}) do
    for key, value in pairs(mixin) do
      cls[key] = value
    end
  end

  -- Set class functions and properties
  for key, value in pairs(properties) do
    cls[key] = value
  end

  cls.__name__ = properties.__name__ or '?'
  cls.__super__ = super_class
  cls.__index = cls

  -- Class.__call to init instance
  local cls_newobj = function(cls, ...)
    local obj = {}
    obj.__class__ = cls
    setmetatable(obj, cls)
    if type(cls.__init__) == 'function' then
      cls.__init__(obj, ...)
    end
    return obj
  end

  -- Set class metatable
  setmetatable(cls, {
    __index = function(t, k)
      -- FIXME: Here we can cache the property
      return t.__super__[k]
    end,
    __call = cls_newobj
  })

  return cls
end

return Class

-- vim: set ts=4 sw=2 sts=2 et:

