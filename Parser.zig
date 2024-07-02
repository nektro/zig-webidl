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
    return @enumFromInt(try intrusive_parser.Parser.AddStrGeneric(@intFromEnum(w.Value.Tag.identifier)).add(&p.parser, alloc, p.parser.temp.items[start..end]));
}

pub fn addIdentLiteral(p: *Parser, alloc: std.mem.Allocator, id: []const u8) !w.IdentifierIndex {
    return @enumFromInt(@intFromEnum(try p.addStr(alloc, id)));
}

// tagValue(u8) + tagType(u8) + id(IdentifierIndex)(u32)
pub fn addNamedType(p: *Parser, alloc: std.mem.Allocator, id: w.IdentifierIndex) !w.TypeIndex {
    const r = p.parser.data.items.len;
    try p.parser.data.ensureUnusedCapacity(alloc, 6);
    p.parser.data.appendAssumeCapacity(@intFromEnum(w.Value.Tag.type));
    p.parser.data.appendAssumeCapacity(@intFromEnum(w.Type.named));
    p.parser.data.appendSliceAssumeCapacity(&std.mem.toBytes(id));
    return @enumFromInt(r);
}

// tagValue(u8) + tagType(u8) + id(IdentifierIndex)(u32) + len(u32) + fields(StringIndex)(u32)*len
pub fn addEnum(p: *Parser, alloc: std.mem.Allocator, name: w.IdentifierIndex, fields: []const w.StringIndex) !w.TypeIndex {
    const r = p.parser.data.items.len;
    try p.parser.data.ensureUnusedCapacity(alloc, 1 + 1 + 4 + 4 + (4 * fields.len));
    p.parser.data.appendAssumeCapacity(@intFromEnum(w.Value.Tag.type));
    p.parser.data.appendAssumeCapacity(@intFromEnum(w.Type.enumeration));
    p.parser.data.appendSliceAssumeCapacity(&std.mem.toBytes(name));
    p.parser.data.appendSliceAssumeCapacity(&std.mem.toBytes(@as(u32, @intCast(fields.len))));
    p.parser.data.appendSliceAssumeCapacity(std.mem.sliceAsBytes(fields));
    return @enumFromInt(r);
}

// tag(u8) + base(u8) + str(StringIndex)(u32)
pub fn addInteger(p: *Parser, alloc: std.mem.Allocator, loc: [2]usize, base: u8) !w.ValueIndex {
    const r = p.parser.data.items.len;
    try p.parser.data.ensureUnusedCapacity(alloc, 1 + 1 + 4);
    p.parser.data.appendAssumeCapacity(@intFromEnum(w.Value.Tag.integer));
    p.parser.data.appendAssumeCapacity(base);
    p.parser.data.appendSliceAssumeCapacity(&std.mem.toBytes(@as(w.IntegerIndex, @enumFromInt(try intrusive_parser.Parser.AddStrGeneric(@intFromEnum(w.Value.Tag.integer)).add(&p.parser, alloc, p.parser.temp.items[loc[0]..loc[1]])))));
    return @enumFromInt(r);
}
