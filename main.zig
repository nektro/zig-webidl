const std = @import("std");
const webidl = @import("webidl");
const nfs = @import("nfs");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const path = "main.webidl";
    var file = try nfs.cwd().openFile(path, .{});
    defer file.close();

    var doc = try webidl.parse(allocator, path, file.reader(), .{});
    defer doc.deinit(allocator);
}
