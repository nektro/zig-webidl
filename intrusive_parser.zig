const std = @import("std");
const string = []const u8;
const extras = @import("extras");
const tracer = @import("tracer");

const buf_size = 64;

pub fn IntrusiveParser(comptime StringIndex_: type, comptime StringListIndex_: type) type {
    return struct {
        const Parser = @This();
        pub const StringIndex = StringIndex_;
        pub const StringListIndex = StringListIndex_;
        pub usingnamespace MixinFactory(Parser);

        any: extras.AnyReader,
        temp: std.ArrayListUnmanaged(u8) = .{},
        idx: usize = 0,
        end: bool = false,
        line: usize = 1,
        col: usize = 1,
        extras: std.ArrayListUnmanaged(u32) = .{},
        string_bytes: std.ArrayListUnmanaged(u8) = .{},
        strings_map: std.StringArrayHashMapUnmanaged(StringIndex) = .{},
        trace_eat: bool = false,

        pub fn deinit(p: *Parser, allocator: std.mem.Allocator) void {
            p.temp.deinit(allocator);
            p.extras.deinit(allocator);
            p.string_bytes.deinit(allocator);
            p.strings_map.deinit(allocator);
        }

        pub fn avail(p: *Parser) usize {
            return p.temp.items.len - p.idx;
        }

        pub fn slice(p: *Parser) []const u8 {
            return p.temp.items[p.idx..];
        }

        pub fn eat(p: *Parser, alloc: std.mem.Allocator, comptime test_s: string) !void {
            const tr = if (p.trace_eat) tracer.trace(@src(), "({d})({s})", .{ p.idx, test_s }) else tracer.Ctx{ .src = @src() };
            defer if (p.trace_eat) tr.end();

            if (test_s.len == 1) {
                _ = try p.eatByte(alloc, test_s[0]);
                return;
            }
            try p.peekAmt(alloc, test_s.len);
            if (std.mem.eql(u8, p.slice()[0..test_s.len], test_s)) {
                p.idx += test_s.len;
                return;
            }
            return error.Null;
        }

        fn peekAmt(p: *Parser, alloc: std.mem.Allocator, amt: usize) !void {
            if (p.avail() >= amt) return;
            const diff_amt = amt - p.avail();
            std.debug.assert(diff_amt <= buf_size);
            var buf: [buf_size]u8 = undefined;
            var target_buf = buf[0..diff_amt];
            const len = try p.any.readAll(target_buf);
            if (len == 0) p.end = true;
            if (len == 0) return error.EndOfStream;
            std.debug.assert(len <= diff_amt);
            try p.temp.appendSlice(alloc, target_buf[0..len]);
            if (len != diff_amt) return error.EndOfStream;
        }

        pub fn eatByte(p: *Parser, alloc: std.mem.Allocator, test_c: u8) !u8 {
            const tr = if (p.trace_eat) tracer.trace(@src(), "({d})({c})", .{ p.idx, test_c }) else tracer.Ctx{ .src = @src() };
            defer if (p.trace_eat) tr.end();

            try p.peekAmt(alloc, 1);
            if (p.slice()[0] == test_c) {
                p.idx += 1;
                return test_c;
            }
            return error.Null;
        }

        pub fn eatCp(p: *Parser, alloc: std.mem.Allocator, comptime test_cp: u21) !u21 {
            const tr = if (p.trace_eat) tracer.trace(@src(), "({d})(U+{d})", .{ p.idx, test_cp }) else tracer.Ctx{ .src = @src() };
            defer if (p.trace_eat) tr.end();

            return p.eatRangeM(alloc, test_cp, test_cp);
        }

        pub fn eatRange(p: *Parser, alloc: std.mem.Allocator, comptime from: u8, comptime to: u8) !u8 {
            const tr = if (p.trace_eat) tracer.trace(@src(), "({d})({d},{d})", .{ p.idx, from, to }) else tracer.Ctx{ .src = @src() };
            defer if (p.trace_eat) tr.end();

            try p.peekAmt(alloc, 1);
            const b = p.slice()[0];
            if (b >= from and b <= to) {
                p.idx += 1;
                return b;
            }
            return error.Null;
        }

        pub fn eatRangeM(p: *Parser, alloc: std.mem.Allocator, comptime from: u21, comptime to: u21) !u21 {
            const tr = if (p.trace_eat) tracer.trace(@src(), "({d})({d},{d})", .{ p.idx, from, to }) else tracer.Ctx{ .src = @src() };
            defer if (p.trace_eat) tr.end();

            const from_len = comptime std.unicode.utf8CodepointSequenceLength(from) catch unreachable;
            const to_len = comptime std.unicode.utf8CodepointSequenceLength(to) catch unreachable;
            const amt = @max(from_len, to_len);
            try p.peekAmt(alloc, amt);
            const len = try std.unicode.utf8ByteSequenceLength(p.slice()[0]);
            if (amt != len) return error.EndOfStream;
            const mcp = try std.unicode.utf8Decode(p.slice()[0..amt]);
            if (mcp >= from and mcp <= to) {
                p.idx += len;
                return @intCast(mcp);
            }
            return error.Null;
        }

        pub fn eatAny(p: *Parser, alloc: std.mem.Allocator, test_s: []const u8) !u8 {
            for (test_s) |c| {
                return p.eatByte(alloc, c) catch continue;
            }
            return error.Null;
        }

        pub fn eatEnum(p: *Parser, alloc: std.mem.Allocator, comptime E: type) !?E {
            inline for (comptime std.meta.fieldNames(E)) |name| {
                if (p.eat(alloc, name)) |_| {
                    return @field(E, name);
                }
            }
            return error.Null;
        }

        pub fn addStr(p: *Parser, alloc: std.mem.Allocator, str: string) !StringIndex {
            const adapter: Adapter = .{ .p = p };
            var res = try p.strings_map.getOrPutAdapted(alloc, str, adapter);
            if (res.found_existing) return res.value_ptr.*;
            const q = p.string_bytes.items.len;
            try p.string_bytes.appendSlice(alloc, str);
            const r = p.extras.items.len;
            try p.extras.appendSlice(alloc, &[_]u32{ @as(u32, @intCast(q)), @as(u32, @intCast(str.len)) });
            res.value_ptr.* = @enumFromInt(r);
            return @enumFromInt(r);
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

        pub fn addStrList(p: *Parser, alloc: std.mem.Allocator, items: []const StringIndex) !StringListIndex {
            if (items.len == 0) return .empty;
            const r = p.extras.items.len;
            try p.extras.ensureUnusedCapacity(alloc, 1 + items.len);
            p.extras.appendAssumeCapacity(@intCast(items.len));
            p.extras.appendSliceAssumeCapacity(@ptrCast(items));
            return @enumFromInt(r);
        }

        pub fn getStr(p: *const Parser, sidx: StringIndex) string {
            const obj = p.extras.items[@intFromEnum(sidx)..][0..2].*;
            const str = p.string_bytes.items[obj[0]..][0..obj[1]];
            return str;
        }
    };
}

fn MixinFactory(comptime P: type) type {
    return struct {
        pub fn Mixin(comptime T: type) type {
            return struct {
                //

                pub fn avail(p: *T) usize {
                    return p.parser.avail();
                }

                pub fn slice(p: *T) []const u8 {
                    return p.parser.slice();
                }

                pub fn eat(p: *T, comptime test_s: string) !void {
                    return p.parser.eat(p.allocator, test_s);
                }

                fn peekAmt(p: *T, amt: usize) !void {
                    return p.parser.peekAmt(p.allocator, amt);
                }

                pub fn eatByte(p: *T, test_c: u8) !u8 {
                    return p.parser.eatByte(p.allocator, test_c);
                }

                pub fn eatCp(p: *T, comptime test_cp: u21) !u21 {
                    return p.parser.eatCp(p.allocator, test_cp);
                }

                pub fn eatRange(p: *T, comptime from: u8, comptime to: u8) !u8 {
                    return p.parser.eatRange(p.allocator, from, to);
                }

                pub fn eatRangeM(p: *T, comptime from: u21, comptime to: u21) !u21 {
                    return p.parser.eatRangeM(p.allocator, from, to);
                }

                pub fn eatAny(p: *T, test_s: []const u8) !u8 {
                    return p.parser.eatAny(p.allocator, test_s);
                }

                pub fn eatEnum(p: *T, comptime E: type) !E {
                    return p.parser.eatEnum(p.allocator, E);
                }

                pub fn addStr(p: *T, str: string) !P.StringIndex {
                    return p.parser.addStr(p.allocator, str);
                }

                pub fn addStrList(p: *T, items: []const P.StringIndex) !P.StringListIndex {
                    return p.parser.addStrList(p.allocator, items);
                }

                pub fn getStr(p: *const T, sidx: P.StringIndex) string {
                    return p.parser.getStr(sidx);
                }
            };
        }
    };
}
