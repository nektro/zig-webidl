const std = @import("std");

pub const ValueIndex = enum(u32) {
    zero,
    _,
};

pub const Value = union(enum(u8)) {
    zero,
    string: StringIndex,

    pub const Tag = std.meta.Tag(@This());
};

pub const StringIndex = enum(u32) {
    _,
};
