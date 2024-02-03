const std = @import("std");
const string = []const u8;
const extras = @import("extras");
const w = @import("./types.zig");
const Parser = @This();
const tracer = @import("tracer");
const IntrusiveParser = @import("./intrusive_parser.zig").IntrusiveParser(w.StringIndex, w.StringListIndex);

const buf_size = 64;

allocator: std.mem.Allocator,
parser: IntrusiveParser,

pub fn init(allocator: std.mem.Allocator, any: extras.AnyReader) Parser {
    return .{
        .allocator = allocator,
        .parser = IntrusiveParser{ .any = any },
    };
}

pub fn deinit(ore: *Parser) void {
    ore.parser.deinit(ore.allocator);
}

pub usingnamespace IntrusiveParser.Mixin(@This());
