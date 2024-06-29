const Document = @This();
const std = @import("std");
const string = []const u8;

pub threadlocal var doc: ?*const Document = null;

data: []const u8,
root: void,
warnings: []const string,

pub fn deinit(this: *const Document, alloc: std.mem.Allocator) void {
    alloc.free(this.data);
    alloc.free(this.warnings);
}

pub fn acquire(this: *const Document) void {
    std.debug.assert(doc == null);
    doc = this;
}

pub fn release(this: *const Document) void {
    std.debug.assert(doc == this);
    doc = null;
}

pub fn format(this: *const Document, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = fmt;
    _ = options;
    return std.fmt.format(writer, "{}", .{this.root});
}
