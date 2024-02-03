const std = @import("std");
const string = []const u8;
const webidl = @import("webidl");

// generated with `find .zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/ -type f | sort`
// zig fmt: off
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/allowany.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/argument-constructor.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/argument-extattrs.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/async-iterable.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/async-name.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/attributes.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/bigint.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/buffersource.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/callback.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/comment.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/constants.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/constructor.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/default.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/dictionary-inherits.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/dictionary.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/documentation-dos.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/documentation.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/enum.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/equivalent-decl.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/escaped-name.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/escaped-type.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/exposed-asterisk.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/extended-attributes.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/generic.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/getter-setter.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/identifier-hyphen.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/identifier-qualified-names.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/includes-name.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/indexed-properties.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/inherits-getter.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/interface-inherits.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/iterable.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/maplike.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/mixin.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/namedconstructor.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/namespace.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/nointerfaceobject.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/nullableobjects.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/nullable.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/obsolete-keywords.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/operation-optional-arg.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/overloading.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/overridebuiltins.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/partial-interface.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/primitives.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/promise-void.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/prototyperoot.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/putforwards.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/record.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/reflector-interface.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/reg-operations.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/replaceable.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/sequence.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/setlike.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/sharedarraybuffer.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/static.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/stringifier-attribute.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/stringifier-custom.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/stringifier.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/treatasnull.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/treatasundefined.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/typedef-union.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/typedef.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/typesuffixes.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/undefined.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/uniontype.webidl"); }
test { try doValid(".zigmod/deps/git/github.com/w3c/webidl2.js/test/syntax/idl/variadic-operations.webidl"); }
// zig fmt: on

fn doValid(testfile_path: string) !void {
    _ = testfile_path;
}
