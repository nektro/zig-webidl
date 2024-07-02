const std = @import("std");
const string = []const u8;
const extras = @import("extras");
const w = @import("./types.zig");
const Parser = @This();
const tracer = @import("tracer");
const intrusive_parser = @import("intrusive-parser");
const Value = w.Value;
const StringIndex = w.StringIndex;

parser: intrusive_parser.Parser,
warnings: std.ArrayListUnmanaged(string) = .{},

max_depth: u16 = 0,

pub fn init(allocator: std.mem.Allocator, any: std.io.AnyReader, options: Options) Parser {
    return .{
        .parser = intrusive_parser.Parser.init(allocator, any, @intFromEnum(Value.Tag.string)),
        .max_depth = options.max_depth,
    };
}

pub const Options = struct {
    max_depth: u16 = 0,
};

pub fn deinit(p: *Parser) void {
    p.parser.deinit();
    p.warnings.deinit(p.parser.allocator);
}

pub usingnamespace intrusive_parser.Mixin(@This());

// tag(u8) + len(u32) + bytes(N)
pub fn addStr(p: *Parser, alloc: std.mem.Allocator, str: string) !StringIndex {
    const t = tracer.trace(@src(), "({d})", .{str.len});
    defer t.end();

    return @enumFromInt(try p.parser.addStr(alloc, str));
}

const Adapter = struct {
    p: *const Parser,

    pub fn hash(ctx: @This(), a: string) u32 {
        _ = ctx;
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(a);
        return @truncate(hasher.final());
    }

    pub fn eql(ctx: @This(), a: string, _: string, b_index: usize) bool {
        const sidx = ctx.p.strings_map.values()[b_index];
        const b = ctx.p.getStr(sidx);
        return std.mem.eql(u8, a, b);
    }
};

pub fn addIdent(p: *Parser, alloc: std.mem.Allocator, id: [2]usize) !w.IdentifierIndex {
    const start, const end = id;
    return @enumFromInt(@intFromEnum(try p.addStr(alloc, p.parser.temp.items[start..end])));
}
