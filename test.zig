const std = @import("std");
const string = []const u8;
const webidl = @import("webidl");

// generated with `find .zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/ -type f | sort`
// zig fmt: off
test { try doValid("allowany"); }
test { try doValid("argument-constructor"); }
test { try doValid("argument-extattrs"); }
test { try doValid("async-iterable"); }
test { try doValid("async-name"); }
test { try doValid("attributes"); }
test { try doValid("bigint"); }
test { try doValid("buffersource"); }
test { try doValid("callback"); }
test { try doValid("comment"); }
test { try doValid("constants"); }
test { try doValid("constructor"); }
test { try doValid("default"); }
test { try doValid("dictionary-inherits"); }
test { try doValid("dictionary"); }
test { try doValid("documentation-dos"); }
test { try doValid("documentation"); }
test { try doValid("enum"); }
test { try doValid("equivalent-decl"); }
test { try doValid("escaped-name"); }
test { try doValid("escaped-type"); }
test { try doValid("exposed-asterisk"); }
test { try doValid("extended-attributes"); }
test { try doValid("generic"); }
test { try doValid("getter-setter"); }
test { try doValid("identifier-hyphen"); }
test { try doValid("identifier-qualified-names"); }
test { try doValid("includes-name"); }
test { try doValid("indexed-properties"); }
test { try doValid("inherits-getter"); }
test { try doValid("interface-inherits"); }
test { try doValid("iterable"); }
test { try doValid("maplike"); }
test { try doValid("mixin"); }
test { try doValid("namedconstructor"); }
test { try doValid("namespace"); }
test { try doValid("nointerfaceobject"); }
test { try doValid("nullableobjects"); }
test { try doValid("nullable"); }
test { try doValid("obsolete-keywords"); }
test { try doValid("operation-optional-arg"); }
test { try doValid("overloading"); }
test { try doValid("overridebuiltins"); }
test { try doValid("partial-interface"); }
test { try doValid("primitives"); }
test { try doValid("promise-void"); }
test { try doValid("prototyperoot"); }
test { try doValid("putforwards"); }
test { try doValid("record"); }
test { try doValid("reflector-interface"); }
test { try doValid("reg-operations"); }
test { try doValid("replaceable"); }
test { try doValid("sequence"); }
test { try doValid("setlike"); }
test { try doValid("sharedarraybuffer"); }
test { try doValid("static"); }
test { try doValid("stringifier-attribute"); }
test { try doValid("stringifier-custom"); }
test { try doValid("stringifier"); }
test { try doValid("treatasnull"); }
test { try doValid("treatasundefined"); }
test { try doValid("typedef-union"); }
test { try doValid("typedef"); }
test { try doValid("typesuffixes"); }
test { try doValid("undefined"); }
test { try doValid("uniontype"); }
test { try doValid("variadic-operations"); }
// zig fmt: on

fn doValid(comptime case: string) !void {
    const path = ".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/" ++ case ++ ".webidl";
    const allocator = std.testing.allocator;
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var doc = try webidl.parse(allocator, path, file.reader(), .{});
    defer doc.deinit(allocator);
}
