const std = @import("std");

pub const ValueIndex = enum(u32) {
    zero,
    true = 1,
    false = 2,
    _,
};

pub const Value = union(enum(u8)) {
    zero,
    string: StringIndex,
    identifier: IdentifierIndex,
    true,
    false,

    pub const Tag = std.meta.Tag(@This());
};

pub const StringIndex = enum(u32) {
    _,
};

pub const IdentifierIndex = enum(u32) {
    _,
};
