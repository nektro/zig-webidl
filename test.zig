const std = @import("std");
const string = []const u8;
const webidl = @import("webidl");

// generated with `find .zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/ -type f | sort`
// updated as of 83fffdb10e196eb54af122b13f6386708a5609c6
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

// generated with `find .zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/ -type f | sort`
// updated as of 83fffdb10e196eb54af122b13f6386708a5609c6
// zig fmt: off
test { try doFail("any-keyword"); }
test { try doFail("argument-dict-default"); }
test { try doFail("argument-dict-nullable"); }
test { try doFail("argument-dict-optional"); }
test { try doFail("array"); }
test { try doFail("async-iterable-readonly"); }
test { try doFail("async-iterable-unterminated-args"); }
test { try doFail("async-maplike"); }
test { try doFail("bigint64array-keyword"); }
test { try doFail("bigint-keyword"); }
test { try doFail("callback-attribute"); }
test { try doFail("callback-noassign"); }
test { try doFail("callback-noparen"); }
test { try doFail("callback-noreturn"); }
test { try doFail("callback-semicolon"); }
test { try doFail("caller"); }
test { try doFail("const-nullable"); }
test { try doFail("const-null"); }
test { try doFail("constructible-global"); }
test { try doFail("constructor-escaped"); }
test { try doFail("constructor"); }
test { try doFail("dict-field-unterminated"); }
test { try doFail("dict-no-default"); }
test { try doFail("dict-required-default"); }
test { try doFail("duplicate-escaped"); }
test { try doFail("duplicate"); }
test { try doFail("enum-bodyless"); }
test { try doFail("enum-empty"); }
test { try doFail("enum"); }
test { try doFail("enum-wo-comma"); }
test { try doFail("exception"); }
test { try doFail("exposed"); }
test { try doFail("extattr-double-field"); }
test { try doFail("extattr-double"); }
test { try doFail("extattr-empty-ids"); }
test { try doFail("extattr-empty"); }
test { try doFail("extattr-invalid-rhs"); }
test { try doFail("extattr-no-rhs"); }
test { try doFail("float"); }
test { try doFail("frozenarray-empty"); }
test { try doFail("id-underscored-number"); }
test { try doFail("implements_and_includes_ws"); }
test { try doFail("implements"); }
test { try doFail("inheritance-typeless"); }
test { try doFail("inherit-readonly"); }
test { try doFail("int32array-keyword"); }
test { try doFail("invalid-allowshared"); }
test { try doFail("invalid-attribute"); }
test { try doFail("iterable-args"); }
test { try doFail("iterable-empty"); }
test { try doFail("iterable-notype"); }
test { try doFail("iterator"); }
test { try doFail("legacyiterable"); }
test { try doFail("maplike-1type"); }
test { try doFail("maplike-args"); }
test { try doFail("module"); }
test { try doFail("namespace-readwrite"); }
test { try doFail("nonempty-sequence"); }
test { try doFail("nonnullableany"); }
test { try doFail("nonnullableobjects"); }
test { try doFail("no-semicolon-callback"); }
test { try doFail("no-semicolon-operation"); }
test { try doFail("no-semicolon"); }
test { try doFail("nullable-union-dictionary"); }
test { try doFail("operation-nameless"); }
test { try doFail("operation-too-special"); }
test { try doFail("overloads"); }
test { try doFail("promise-empty"); }
test { try doFail("promise-nullable"); }
test { try doFail("promise-with-extended-attribute"); }
test { try doFail("raises"); }
test { try doFail("readonly-iterable"); }
test { try doFail("record-key"); }
test { try doFail("record-key-with-extended-attribute"); }
test { try doFail("record-single"); }
test { try doFail("recursive-type"); }
test { try doFail("renamed-legacy-extattrs"); }
test { try doFail("scopedname"); }
test { try doFail("sequence-empty"); }
test { try doFail("setlike-2types"); }
test { try doFail("setlike-args"); }
test { try doFail("setter-creator"); }
// test { try doFail("sharedarraybuffer"); } // https://github.com/w3c/webidl2.js/issues/786
test { try doFail("spaced-negative-infinity"); }
test { try doFail("spaced-variadic"); }
test { try doFail("special-omittable"); }
test { try doFail("stray-slash"); }
test { try doFail("stringconstants"); }
test { try doFail("tostring-escaped"); }
test { try doFail("tostring"); }
test { try doFail("typedef-nested"); }
test { try doFail("union-any"); }
test { try doFail("union-dangling-or"); }
test { try doFail("union-one"); }
test { try doFail("union-promise"); }
test { try doFail("union-zero"); }
test { try doFail("unknown-generic"); }
// test { try doFail("void-keyword"); } // https://github.com/w3c/webidl2.js/issues/784
// zig fmt: on

fn doFail(comptime case: string) !void {
    const path = ".zigmod/deps/git/github.com/w3c/webidl2.js/test/invalid/idl/" ++ case ++ ".webidl";
    const allocator = std.testing.allocator;
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    var doc = webidl.parse(allocator, path, file.reader(), .{}) catch return;
    defer doc.deinit(allocator);
    return error.ShouldHaveFailed;
}
