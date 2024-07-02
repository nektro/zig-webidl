const std = @import("std");

pub const ValueIndex = enum(u32) {
    zero,
    true = 1,
    false = 2,
    type_float = 3,
    type_double = 5,
    type_short = 7,
    type_long = 9,
    type_long_long = 11,
    type_unrestricted_float = 13,
    type_unrestricted_double = 15,
    type_unsigned_short = 17,
    type_unsigned_long = 19,
    type_unsigned_long_long = 21,

    _,
};

pub const Value = union(enum(u8)) {
    zero,
    string: StringIndex,
    identifier: IdentifierIndex,
    true,
    false,
    type: TypeIndex,

    pub const Tag = std.meta.Tag(@This());
};

pub const StringIndex = enum(u32) {
    _,
};

pub const IdentifierIndex = enum(u32) {
    _,
};

pub const TypeIndex = enum(u32) {
    float = 3,
    double = 5,
    short = 7,
    long = 9,
    long_long = 11,
    unrestricted_float = 13,
    unrestricted_double = 15,
    unsigned_short = 17,
    unsigned_long = 19,
    unsigned_long_long = 21,

    _,
};

pub const Type = enum(u8) {
    float,
    double,
    short,
    long,
    long_long,
    unrestricted_float,
    unrestricted_double,
    unsigned_short,
    unsigned_long,
    unsigned_long_long,
};
