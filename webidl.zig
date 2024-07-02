//! Parser for Web Interface Design Language
//! https://webidl.spec.whatwg.org/

const std = @import("std");
const string = []const u8;
const tracer = @import("tracer");
const extras = @import("extras");
const Parser = @import("./Parser.zig");
const Document = @import("./Document.zig");
const w = @import("./types.zig");
const Value = w.Value;

const Error = error{ OutOfMemory, EndOfStream, MalformedWebIDL };

// TODO use precise error return; https://github.com/ziglang/zig/issues/20177
pub fn parse(alloc: std.mem.Allocator, path: string, inreader: anytype, options: Parser.Options) anyerror!Document {
    //
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    _ = path;

    var p = Parser.init(alloc, inreader.any(), options);
    defer p.deinit();

    comptime std.debug.assert(@intFromEnum(Value.zero) == 0);
    try p.parser.data.ensureUnusedCapacity(alloc, 4096);
    p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.zero));
    p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.true)); // 1
    p.parser.data.appendAssumeCapacity(@intFromEnum(Value.Tag.false)); // 2
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.float) }); // 3
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.double) }); // 5
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.short) }); // 7
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.long) }); // 9
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.long_long) }); // 11
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.unrestricted_float) }); // 13
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.unrestricted_double) }); // 15
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.unsigned_short) }); // 17
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.unsigned_long) }); // 19
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.unsigned_long_long) }); // 21
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.boolean) }); // 23
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.byte) }); // 25
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.octet) }); // 27
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.bigint) }); // 29
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.ByteString) }); // 31
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.DOMString) }); // 33
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.USVString) }); // 35
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.ArrayBuffer) }); // 37
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.SharedArrayBuffer) }); // 39
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.DataView) }); // 41
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Int8Array) }); // 43
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Int16Array) }); // 45
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Int32Array) }); // 47
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Uint8Array) }); // 49
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Uint16Array) }); // 51
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Uint32Array) }); // 53
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Uint8ClampedArray) }); // 55
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.BigInt64Array) }); // 57
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.BigUint64Array) }); // 59
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Float32Array) }); // 61
    p.parser.data.appendSliceAssumeCapacity(&.{ @intFromEnum(Value.Tag.type), @intFromEnum(w.Type.Float64Array) }); // 63
    _ = try p.addStr(alloc, "");

    // const root = try parseDefinitionsPrecise(alloc, &p, @TypeOf(inreader).Error || Error);
    const root = try parseDefinitions(alloc, &p);
    if (p.avail() > 0) {
        std.log.warn("avail: {d}", .{p.avail()});
        std.log.warn("avail: {s}", .{p.parser.temp.items[p.parser.idx..]});
        return error.MalformedWebIDL;
    }

    const data = try p.parser.data.toOwnedSlice(alloc);
    errdefer alloc.free(data);

    const warnings = try p.warnings.toOwnedSlice(alloc);
    // dont need to free the children since theyre literals
    errdefer alloc.free(warnings);

    return .{
        .data = data,
        .root = root,
        .warnings = warnings,
    };
}

fn parseDefinitionsPrecise(alloc: std.mem.Allocator, p: *Parser, comptime E: type) E!void {
    return @errorCast(parseDefinitions(alloc, p));
}

// Definitions ::
//     (ExtendedAttributeList? Definition)*
fn parseDefinitions(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    try skip_whitespace(p);
    while (true) {
        _ = try parseExtendedAttributeList(alloc, p) orelse {};
        _ = try parseDefinition(alloc, p) orelse break;
    }
}

// Definition ::
//     CallbackOrInterfaceOrMixin
//     Namespace
//     Partial
//     Dictionary
//     Enum
//     Typedef
//     IncludesStatement
fn parseDefinition(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseCallbackOrInterfaceOrMixin(alloc, p)) |_| return;
    if (try parseNamespace(alloc, p)) |_| return;
    if (try parsePartial(alloc, p)) |_| return;
    if (try parseDictionary(alloc, p)) |_| return;
    if (try parseEnum(alloc, p)) |_| return;
    if (try parseTypedef(alloc, p)) |_| return;
    if (try parseIncludesStatement(alloc, p)) |_| return;
    return null;
}

// ArgumentNameKeyword ::
//     async
//     attribute
//     callback
//     const
//     constructor
//     deleter
//     dictionary
//     enum
//     getter
//     includes
//     inherit
//     interface
//     iterable
//     maplike
//     mixin
//     namespace
//     partial
//     readonly
//     required
//     setlike
//     setter
//     static
//     stringifier
//     typedef
//     unrestricted
fn parseArgumentNameKeyword(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.IdentifierIndex {
    if (try parse_keyword(p, .@"async")) |_| return try p.addIdentLiteral(alloc, "async");
    if (try parse_keyword(p, .attribute)) |_| return try p.addIdentLiteral(alloc, "attribute");
    if (try parse_keyword(p, .callback)) |_| return try p.addIdentLiteral(alloc, "callback");
    if (try parse_keyword(p, .@"const")) |_| return try p.addIdentLiteral(alloc, "const");
    if (try parse_keyword(p, .constructor)) |_| return try p.addIdentLiteral(alloc, "constructor");
    if (try parse_keyword(p, .deleter)) |_| return try p.addIdentLiteral(alloc, "deleter");
    if (try parse_keyword(p, .dictionary)) |_| return try p.addIdentLiteral(alloc, "dictionary");
    if (try parse_keyword(p, .@"enum")) |_| return try p.addIdentLiteral(alloc, "enum");
    if (try parse_keyword(p, .getter)) |_| return try p.addIdentLiteral(alloc, "getter");
    if (try parse_keyword(p, .includes)) |_| return try p.addIdentLiteral(alloc, "includes");
    if (try parse_keyword(p, .inherit)) |_| return try p.addIdentLiteral(alloc, "inherit");
    if (try parse_keyword(p, .interface)) |_| return try p.addIdentLiteral(alloc, "interface");
    if (try parse_keyword(p, .iterable)) |_| return try p.addIdentLiteral(alloc, "iterable");
    if (try parse_keyword(p, .maplike)) |_| return try p.addIdentLiteral(alloc, "maplike");
    if (try parse_keyword(p, .mixin)) |_| return try p.addIdentLiteral(alloc, "mixin");
    if (try parse_keyword(p, .namespace)) |_| return try p.addIdentLiteral(alloc, "namespace");
    if (try parse_keyword(p, .partial)) |_| return try p.addIdentLiteral(alloc, "partial");
    if (try parse_keyword(p, .readonly)) |_| return try p.addIdentLiteral(alloc, "readonly");
    if (try parse_keyword(p, .required)) |_| return try p.addIdentLiteral(alloc, "required");
    if (try parse_keyword(p, .setlike)) |_| return try p.addIdentLiteral(alloc, "setlike");
    if (try parse_keyword(p, .setter)) |_| return try p.addIdentLiteral(alloc, "setter");
    if (try parse_keyword(p, .static)) |_| return try p.addIdentLiteral(alloc, "static");
    if (try parse_keyword(p, .stringifier)) |_| return try p.addIdentLiteral(alloc, "stringifier");
    if (try parse_keyword(p, .typedef)) |_| return try p.addIdentLiteral(alloc, "typedef");
    if (try parse_keyword(p, .unrestricted)) |_| return try p.addIdentLiteral(alloc, "unrestricted");
    return null;
}

// CallbackOrInterfaceOrMixin ::
//     callback CallbackRestOrInterface
//     interface InterfaceOrMixin
//
// CallbackRestOrInterface ::
//     CallbackRest
//     interface identifier { CallbackInterfaceMembers } ;
// CallbackRest ::
//     identifier = Type OptionalArgumentList ;
// CallbackInterfaceMembers ::
//     (ExtendedAttributeList? CallbackInterfaceMember)*
// CallbackInterfaceMember ::
//     Const
//     RegularOperation
//
// InterfaceOrMixin ::
//     InterfaceRest
//     MixinRest
fn parseCallbackOrInterfaceOrMixin(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(p, .callback)) |_| {
        if (try parse_keyword(p, .interface)) |_| {
            _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
            try parse_symbol(p, '{') orelse return error.MalformedWebIDL;
            while (true) {
                _ = try parseExtendedAttributeList(alloc, p);

                if (try parseConst(alloc, p)) |_| continue;
                if (try parseRegularOperation(alloc, p)) |_| continue;
                break;
            }
            try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
            try parse_symbol(p, ';') orelse return error.MalformedWebIDL;

            return;
        }
        if (try parse_name(alloc, p)) |_| {
            try parse_symbol(p, '=') orelse return error.MalformedWebIDL;
            _ = try parseType(alloc, p) orelse return error.MalformedWebIDL;
            _ = try parseOptionalArgumentList(alloc, p) orelse return error.MalformedWebIDL;
            try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
            return;
        }
        return null;
    }
    if (try parse_keyword(p, .interface)) |_| {
        if (try parseMixinRest(alloc, p)) |_| return;
        if (try parseInterfaceRest(alloc, p)) |_| return;
        return null;
    }
    return null;
}

// InterfaceRest ::
//     identifier Inheritance? { InterfaceMembers } ;
// InterfaceMembers ::
//     (ExtendedAttributeList? InterfaceMember)*
fn parseInterfaceRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parse_name(alloc, p) orelse return null;
    _ = try parseInheritance(alloc, p);
    try parse_symbol(p, '{') orelse return error.MalformedWebIDL;
    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parseInterfaceMember(alloc, p) orelse break;
    }
    try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// Partial ::
//     partial PartialDefinition
// PartialDefinition ::
//     interface PartialInterfaceOrPartialMixin
//     PartialDictionary
//     Namespace
fn parsePartial(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .partial) orelse return null;

    if (try parse_keyword(p, .interface)) |_| {
        _ = try parsePartialInterfaceOrPartialMixin(alloc, p) orelse return error.MalformedWebIDL;
        return;
    }
    if (try parsePartialDictionary(alloc, p)) |_| {
        return;
    }
    if (try parseNamespace(alloc, p)) |_| {
        return;
    }
    return null;
}

// PartialInterfaceOrPartialMixin ::
//     PartialInterfaceRest
//     MixinRest
fn parsePartialInterfaceOrPartialMixin(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseMixinRest(alloc, p)) |_| return;
    if (try parsePartialInterfaceRest(alloc, p)) |_| return;
    return null;
}

// PartialInterfaceRest ::
//     identifier { PartialInterfaceMembers } ;
// PartialInterfaceMembers ::
//     (ExtendedAttributeList? PartialInterfaceMember)*
fn parsePartialInterfaceRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parse_name(alloc, p) orelse return null;
    try parse_symbol(p, '{') orelse return error.MalformedWebIDL;
    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parsePartialInterfaceMember(alloc, p) orelse break;
    }
    try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// InterfaceMember ::
//     PartialInterfaceMember
//     Constructor
fn parseInterfaceMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parsePartialInterfaceMember(alloc, p)) |_| return;
    if (try parseConstructor(alloc, p)) |_| return;
    return null;
}

// PartialInterfaceMember ::
//     Const
//     Operation
//     Stringifier
//     StaticMember
//     Iterable
//     AsyncIterable
//     ReadOnlyMember
//     ReadWriteAttribute
//     ReadWriteMaplike
//     ReadWriteSetlike
//     InheritAttribute
fn parsePartialInterfaceMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseInheritAttribute(alloc, p)) |_| return;
    if (try parseReadWriteSetlike(alloc, p)) |_| return;
    if (try parseReadWriteMaplike(alloc, p)) |_| return;
    if (try parseReadWriteAttribute(alloc, p)) |_| return;
    if (try parseReadOnlyMember(alloc, p)) |_| return;
    if (try parseAsyncIterable(alloc, p)) |_| return;
    if (try parseIterable(alloc, p)) |_| return;
    if (try parseStaticMember(alloc, p)) |_| return;
    if (try parseStringifier(alloc, p)) |_| return;
    if (try parseConst(alloc, p)) |_| return;
    if (try parseOperation(alloc, p)) |_| return;
    return null;
}

// Inheritance ::
//     : identifier
fn parseInheritance(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.IdentifierIndex {
    try parse_symbol(p, ':') orelse return null;
    return try parse_name(alloc, p) orelse return error.MalformedWebIDL;
}

// MixinRest ::
//     mixin identifier { MixinMembers } ;
// MixinMembers ::
//     (ExtendedAttributeList? MixinMember)*
fn parseMixinRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parse_keyword(p, .mixin) orelse return null;

    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '{') orelse return error.MalformedWebIDL;
    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parseMixinMember(alloc, p) orelse break;
    }
    try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// MixinMember ::
//     Const
//     RegularOperation
//     Stringifier
//     readonly? AttributeRest
fn parseMixinMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseConst(alloc, p)) |_| return;
    if (try parseStringifier(alloc, p)) |_| return;
    if (try parse_keyword(p, .readonly)) |_| {
        _ = try parseAttributeRest(alloc, p) orelse return error.MalformedWebIDL;
        return;
    }
    if (try parseAttributeRest(alloc, p)) |_| return;
    if (try parseRegularOperation(alloc, p)) |_| return;
    return null;
}

// IncludesStatement ::
//     identifier includes identifier ;
fn parseIncludesStatement(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parse_name(alloc, p) orelse return null;
    _ = try parse_keyword(p, .includes) orelse return error.MalformedWebIDL;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// Const ::
//     const ConstType identifier = ConstValue ;
fn parseConst(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .@"const") orelse return null;
    _ = try parseConstType(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '=') orelse return error.MalformedWebIDL;
    _ = try parseConstValue(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// ConstValue ::
//     BooleanLiteral
//     FloatLiteral
//     integer
fn parseConstValue(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseBooleanLiteral(alloc, p)) |_| return;
    if (try parse_integer(alloc, p)) |_| return;
    if (try parseFloatLiteral(alloc, p)) |_| return;
    return null;
}

// BooleanLiteral ::
//     true
//     false
fn parseBooleanLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.ValueIndex {
    _ = alloc;
    if (try parse_keyword(p, .true)) |_| return .true;
    if (try parse_keyword(p, .false)) |_| return .false;
    return null;
}

// FloatLiteral ::
//     decimal
//     -Infinity
//     Infinity
//     NaN
fn parseFloatLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(p, .@"-Infinity")) |_| return;
    if (try parse_keyword(p, .Infinity)) |_| return;
    if (try parse_keyword(p, .NaN)) |_| return;
    if (try parse_decimal(alloc, p)) |_| return;
    return null;
}

// ConstType ::
//     PrimitiveType
//     identifier
fn parseConstType(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.TypeIndex {
    if (try parsePrimitiveType(p)) |y| return y;
    if (try parse_name(alloc, p)) |id| return try p.addNamedType(alloc, id);
    return null;
}

// ReadOnlyMember ::
//     readonly ReadOnlyMemberRest
// ReadOnlyMemberRest ::
//     AttributeRest
//     MaplikeRest
//     SetlikeRest
fn parseReadOnlyMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .readonly) orelse return null;

    if (try parseAttributeRest(alloc, p)) |_| return;
    if (try parseMaplikeRest(alloc, p)) |_| return;
    if (try parseSetlikeRest(alloc, p)) |_| return;
    return error.MalformedWebIDL;
}

// ReadWriteAttribute ::
//     AttributeRest
fn parseReadWriteAttribute(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    return parseAttributeRest(alloc, p);
}

// InheritAttribute ::
//     inherit AttributeRest
fn parseInheritAttribute(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .inherit) orelse return null;
    _ = try parseAttributeRest(alloc, p) orelse return error.MalformedWebIDL;
}

// AttributeRest ::
//     attribute TypeWithExtendedAttributes AttributeName ;
fn parseAttributeRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .attribute) orelse return null;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parseAttributeName(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// AttributeName ::
//     identifier
//     async
//     required
fn parseAttributeName(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.IdentifierIndex {
    if (try parse_keyword(p, .@"async")) |_| return try p.addIdentLiteral(alloc, "async");
    if (try parse_keyword(p, .required)) |_| return try p.addIdentLiteral(alloc, "required");
    if (try parse_name(alloc, p)) |id| return id;
    return null;
}

// DefaultValue ::
//     ConstValue
//     string
//     [ ]
//     { }
//     null
//     undefined
fn parseDefaultValue(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseConstValue(alloc, p)) |_| return;
    if (try parse_string(alloc, p)) |_| return;
    if (try parse_keyword(p, .undefined)) |_| return;
    if (try parse_keyword(p, .null)) |_| return;

    if (try parse_symbol(p, '[')) |_| {
        try parse_symbol(p, ']') orelse return error.MalformedWebIDL;
        return;
    }
    if (try parse_symbol(p, '{')) |_| {
        try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
        return;
    }
    return null;
}

// Operation ::
//     Special? RegularOperation
fn parseOperation(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseSpecial(alloc, p);
    _ = try parseRegularOperation(alloc, p) orelse return null;
}

// RegularOperation ::
//     Type OperationRest
fn parseRegularOperation(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseType(alloc, p) orelse return null;
    _ = try parseOperationRest(alloc, p) orelse return error.MalformedWebIDL;
}

// Special ::
//     getter
//     setter
//     deleter
fn parseSpecial(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = alloc;
    if (try parse_keyword(p, .getter)) |_| return;
    if (try parse_keyword(p, .setter)) |_| return;
    if (try parse_keyword(p, .deleter)) |_| return;
    return null;
}

// OperationRest ::
//     OperationName? OptionalArgumentList ;
fn parseOperationRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseOperationName(alloc, p);
    _ = try parseOptionalArgumentList(alloc, p) orelse return null; //FIXME:
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// OperationName ::
//     includes
//     identifier
fn parseOperationName(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.IdentifierIndex {
    if (try parse_keyword(p, .includes)) |_| return try p.addIdentLiteral(alloc, "includes");
    if (try parse_name(alloc, p)) |id| return id;
    return null;
}

// ArgumentList ::
//     Argument (, Argument)*
fn parseArgumentList(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);
    try list.append(alloc, try parseArgument(alloc, p) orelse return);

    while (true) {
        try parse_symbol(p, ',') orelse break;
        try list.append(alloc, try parseArgument(alloc, p) orelse return error.MalformedWebIDL);
    }
}

// Argument ::
//     ExtendedAttributeList? ArgumentRest
// ArgumentRest ::
//     optional TypeWithExtendedAttributes ArgumentName Default?
//     Type Ellipsis? ArgumentName
fn parseArgument(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseExtendedAttributeList(alloc, p);

    if (try parse_keyword(p, .optional)) |_| {
        _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
        _ = try parseArgumentName(alloc, p) orelse return error.MalformedWebIDL;
        _ = try parseDefault(alloc, p);
        return;
    }
    if (try parseType(alloc, p)) |_| {
        _ = try parseEllipsis(alloc, p);
        _ = try parseArgumentName(alloc, p) orelse return error.MalformedWebIDL;
        return;
    }
    return null;
}

// ArgumentName ::
//     ArgumentNameKeyword
//     identifier
fn parseArgumentName(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.IdentifierIndex {
    if (try parseArgumentNameKeyword(alloc, p)) |id| return id;
    if (try parse_name(alloc, p)) |id| return id;
    return null;
}

// Ellipsis ::
//     ...
fn parseEllipsis(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = alloc;
    _ = try p.eatByte('.') orelse return null;
    _ = try p.eatByte('.') orelse return error.MalformedWebIDL;
    _ = try p.eatByte('.') orelse return error.MalformedWebIDL;
    try skip_whitespace(p);
}

// Constructor ::
//     constructor OptionalArgumentList ;
fn parseConstructor(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .constructor) orelse return null;
    _ = try parseOptionalArgumentList(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// Stringifier ::
//     stringifier StringifierRest
// StringifierRest ::
//     readonly? AttributeRest
//     ;
fn parseStringifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .stringifier) orelse return null;

    if (try parse_symbol(p, ';')) |_| return;

    _ = try parse_keyword(p, .readonly);
    _ = try parseAttributeRest(alloc, p) orelse return error.MalformedWebIDL;
}

// StaticMember ::
//     static StaticMemberRest
// StaticMemberRest ::
//     readonly? AttributeRest
//     RegularOperation
fn parseStaticMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .static) orelse return null;

    if (try parse_keyword(p, .readonly)) |_| {
        _ = try parseAttributeRest(alloc, p) orelse return error.MalformedWebIDL;
        return;
    }
    if (try parseRegularOperation(alloc, p)) |_| {
        return;
    }
    return null;
}

// Iterable ::
//     iterable < TypeWithExtendedAttributes OptionalType? > ;
// OptionalType ::
//     , TypeWithExtendedAttributes
fn parseIterable(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .iterable) orelse return null;
    try parse_symbol(p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = if (try parse_symbol(p, ',') == null) null else (try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL);
    try parse_symbol(p, '>') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// AsyncIterable ::
//     async iterable < TypeWithExtendedAttributes OptionalType? > OptionalArgumentList? ;
// OptionalType ::
//     , TypeWithExtendedAttributes
fn parseAsyncIterable(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .@"async") orelse return null;
    try parse_keyword(p, .iterable) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = if (try parse_symbol(p, ',') == null) null else (try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL);
    try parse_symbol(p, '>') orelse return error.MalformedWebIDL;
    _ = try parseOptionalArgumentList(alloc, p);
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// OptionalArgumentList ::
//     ( ArgumentList? )
fn parseOptionalArgumentList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(p, '(') orelse return null;
    _ = try parseArgumentList(alloc, p);
    try parse_symbol(p, ')') orelse return error.MalformedWebIDL;
}

// ReadWriteMaplike ::
//     MaplikeRest
fn parseReadWriteMaplike(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    return parseMaplikeRest(alloc, p);
}

// MaplikeRest ::
//     maplike < TypeWithExtendedAttributes , TypeWithExtendedAttributes > ;
fn parseMaplikeRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .maplike) orelse return null;
    try parse_symbol(p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, ',') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '>') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// ReadWriteSetlike ::
//     SetlikeRest
fn parseReadWriteSetlike(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    return parseSetlikeRest(alloc, p);
}

// SetlikeRest ::
//     setlike < TypeWithExtendedAttributes > ;
fn parseSetlikeRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .setlike) orelse return null;
    try parse_symbol(p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '>') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// Namespace ::
//     namespace identifier { NamespaceMembers? } ;
// NamespaceMembers? ::
//     (ExtendedAttributeList? NamespaceMember)+
fn parseNamespace(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .namespace) orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);

    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parseNamespaceMember(alloc, p) orelse break;
    }
    try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// NamespaceMember ::
//     RegularOperation
//     readonly AttributeRest
//     Const
fn parseNamespaceMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(p, .readonly)) |_| {
        _ = try parseAttributeRest(alloc, p) orelse return error.MalformedWebIDL;
        return;
    }
    if (try parseConst(alloc, p)) |_| return;
    if (try parseRegularOperation(alloc, p)) |_| return;
    return null;
}

// Dictionary ::
//     dictionary identifier Inheritance? { DictionaryMembers? } ;
// DictionaryMembers? ::
//     DictionaryMember+
fn parseDictionary(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .dictionary) orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parseInheritance(alloc, p);
    try parse_symbol(p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);

    while (true) {
        _ = try parseDictionaryMember(alloc, p) orelse break;
    }
    try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// DictionaryMember ::
//     ExtendedAttributeList? DictionaryMemberRest
// DictionaryMemberRest ::
//     required TypeWithExtendedAttributes identifier ;
//     Type identifier Default? ;
fn parseDictionaryMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseExtendedAttributeList(alloc, p);

    if (try parse_keyword(p, .required)) |_| {
        _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
        _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
        try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
        return;
    }
    if (try parseType(alloc, p)) |_| {
        _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
        _ = try parseDefault(alloc, p);
        try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
        return;
    }
    return null;
}

// PartialDictionary ::
//     dictionary identifier { DictionaryMembers? } ;
// DictionaryMembers? ::
//     DictionaryMember+
fn parsePartialDictionary(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .dictionary) orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);

    while (true) {
        _ = try parseDictionaryMember(alloc, p) orelse break;
    }
    try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// Default ::
//     = DefaultValue
fn parseDefault(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(p, '=') orelse return null;
    _ = try parseDefaultValue(alloc, p) orelse return error.MalformedWebIDL;
}

// Enum ::
//     enum identifier { EnumValueList } ;
// EnumValueList ::
//     string (, string)*
fn parseEnum(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.TypeIndex {
    try parse_keyword(p, .@"enum") orelse return null;
    const name = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(w.StringIndex){};
    defer list.deinit(alloc);
    try list.append(alloc, try parse_string(alloc, p) orelse return error.MalformedWebIDL);

    while (true) {
        try parse_symbol(p, ',') orelse break;
        try list.append(alloc, try parse_string(alloc, p) orelse continue);
    }
    try parse_symbol(p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
    return try p.addEnum(alloc, name, list.items);
}

// Typedef ::
//     typedef TypeWithExtendedAttributes identifier ;
fn parseTypedef(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .typedef) orelse return null;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, ';') orelse return error.MalformedWebIDL;
}

// Type ::
//     SingleType
//     UnionType Null?
fn parseType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseSingleType(alloc, p)) |_| return;

    _ = try parseUnionType(alloc, p) orelse return null;
    _ = try parse_symbol(p, '?');
}

// TypeWithExtendedAttributes ::
//     ExtendedAttributeList? Type
fn parseTypeWithExtendedAttributes(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseExtendedAttributeList(alloc, p);
    _ = try parseType(alloc, p) orelse return null;
}

// SingleType ::
//     DistinguishableType
//     any
//     PromiseType
fn parseSingleType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(p, .any)) |_| return;
    if (try parsePromiseType(alloc, p)) |_| return;
    if (try parseDistinguishableType(alloc, p)) |_| return;
    return null;
}

// UnionType ::
//     ( UnionMemberType (or UnionMemberType)* )
fn parseUnionType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(p, '(') orelse return null;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);
    try list.append(alloc, try parseUnionMemberType(alloc, p) orelse return error.MalformedWebIDL);

    while (true) {
        try parse_keyword(p, .@"or") orelse break;
        try list.append(alloc, try parseUnionMemberType(alloc, p) orelse return error.MalformedWebIDL);
    }
    try parse_symbol(p, ')') orelse return error.MalformedWebIDL;
    if (list.items.len == 1) return error.MalformedWebIDL;
}

// UnionMemberType ::
//     ExtendedAttributeList? DistinguishableType
//     UnionType Null?
fn parseUnionMemberType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseExtendedAttributeList(alloc, p)) |_| {
        if (try parse_keyword(p, .any)) |_| return error.MalformedWebIDL;
        _ = try parseDistinguishableType(alloc, p) orelse return error.MalformedWebIDL;
        return;
    }
    if (try parse_keyword(p, .any)) |_| return error.MalformedWebIDL;
    if (try parseDistinguishableType(alloc, p)) |_| {
        return;
    }
    _ = try parseUnionType(alloc, p) orelse return null;
    _ = try parse_symbol(p, '?');
}

// DistinguishableType ::
//     PrimitiveType Null?
//     StringType Null?
//     identifier Null?
//     sequence < TypeWithExtendedAttributes > Null?
//     object Null?
//     symbol Null?
//     BufferRelatedType Null?
//     FrozenArray < TypeWithExtendedAttributes > Null?
//     ObservableArray < TypeWithExtendedAttributes > Null?
//     RecordType Null?
//     undefined Null?
fn parseDistinguishableType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = blk: {
        _ = blk2: {
            if (try parse_keyword(p, .sequence)) |_| break :blk2;
            if (try parse_keyword(p, .FrozenArray)) |_| break :blk2;
            if (try parse_keyword(p, .ObservableArray)) |_| break :blk2;
            break :blk;
        };
        try parse_symbol(p, '<') orelse return error.MalformedWebIDL;
        _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
        try parse_symbol(p, '>') orelse return error.MalformedWebIDL;
        _ = try parse_symbol(p, '?');
        return;
    };
    _ = blk: {
        if (try parse_keyword(p, .object)) |_| break :blk;
        if (try parse_keyword(p, .symbol)) |_| break :blk;
        if (try parse_keyword(p, .undefined)) |_| break :blk;
        if (try parsePrimitiveType(p)) |_| break :blk;
        if (try parseStringType(p)) |_| break :blk;
        if (try parseBufferRelatedType(p)) |_| break :blk;
        if (try parseRecordType(alloc, p)) |_| break :blk;
        if (try parse_name(alloc, p)) |_| break :blk;
        return null;
    };
    _ = try parse_symbol(p, '?');
}

// PrimitiveType ::
//     UnsignedIntegerType
//     UnrestrictedFloatType
//     boolean
//     byte
//     octet
//     bigint
fn parsePrimitiveType(p: *Parser) anyerror!?w.TypeIndex {
    if (try parseUnsignedIntegerType(p)) |y| return y;
    if (try parseUnrestrictedFloatType(p)) |y| return y;
    if (try parse_keyword(p, .boolean)) |_| return .boolean;
    if (try parse_keyword(p, .byte)) |_| return .byte;
    if (try parse_keyword(p, .octet)) |_| return .octet;
    if (try parse_keyword(p, .bigint)) |_| return .bigint;
    return null;
}

// UnrestrictedFloatType ::
//     unrestricted FloatType
//     FloatType
fn parseUnrestrictedFloatType(p: *Parser) anyerror!?w.TypeIndex {
    if (try parse_keyword(p, .unrestricted)) |_| {
        const t = try parseFloatType(p) orelse return error.MalformedWebIDL;
        return switch (t) {
            .float => .unrestricted_float,
            .double => .unrestricted_double,
            else => unreachable,
        };
    }
    const t = try parseFloatType(p) orelse return null;
    return t;
}

// FloatType ::
//     float
//     double
fn parseFloatType(p: *Parser) anyerror!?w.TypeIndex {
    if (try parse_keyword(p, .float)) |_| return .float;
    if (try parse_keyword(p, .double)) |_| return .double;
    return null;
}

// UnsignedIntegerType ::
//     unsigned IntegerType
//     IntegerType
fn parseUnsignedIntegerType(p: *Parser) anyerror!?w.TypeIndex {
    if (try parse_keyword(p, .unsigned)) |_| {
        const t = try parseIntegerType(p) orelse return error.MalformedWebIDL;
        return switch (t) {
            .short => .unsigned_short,
            .long => .unsigned_long,
            .long_long => .unsigned_long_long,
            else => unreachable,
        };
    }
    const t = try parseIntegerType(p) orelse return null;
    return t;
}

// IntegerType ::
//     short
//     long long?
fn parseIntegerType(p: *Parser) anyerror!?w.TypeIndex {
    if (try parse_keyword(p, .short)) |_| return .short;

    if (try parse_keyword(p, .long)) |_| {
        if (try parse_keyword(p, .long)) |_| return .long_long;
        return .long;
    }
    return null;
}

// StringType ::
//     ByteString
//     DOMString
//     USVString
fn parseStringType(p: *Parser) anyerror!?w.TypeIndex {
    if (try parse_keyword(p, .ByteString)) |_| return .ByteString;
    if (try parse_keyword(p, .DOMString)) |_| return .DOMString;
    if (try parse_keyword(p, .USVString)) |_| return .USVString;
    return null;
}

// PromiseType ::
//     Promise < Type >
fn parsePromiseType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .Promise) orelse return null;
    try parse_symbol(p, '<') orelse return error.MalformedWebIDL;
    _ = try parseType(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '>') orelse return error.MalformedWebIDL;
}

// RecordType ::
//     record < StringType , TypeWithExtendedAttributes >
fn parseRecordType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(p, .record) orelse return null;
    try parse_symbol(p, '<') orelse return error.MalformedWebIDL;
    _ = try parseStringType(p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, ',') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(p, '>') orelse return error.MalformedWebIDL;
}

// BufferRelatedType ::
//     ArrayBuffer
//     SharedArrayBuffer
//     DataView
//     Int8Array
//     Int16Array
//     Int32Array
//     Uint8Array
//     Uint16Array
//     Uint32Array
//     Uint8ClampedArray
//     BigInt64Array
//     BigUint64Array
//     Float32Array
//     Float64Array
fn parseBufferRelatedType(p: *Parser) anyerror!?w.TypeIndex {
    if (try parse_keyword(p, .ArrayBuffer)) |_| return .ArrayBuffer;
    if (try parse_keyword(p, .SharedArrayBuffer)) |_| return .SharedArrayBuffer;
    if (try parse_keyword(p, .DataView)) |_| return .DataView;
    if (try parse_keyword(p, .Int8Array)) |_| return .Int8Array;
    if (try parse_keyword(p, .Int16Array)) |_| return .Int16Array;
    if (try parse_keyword(p, .Int32Array)) |_| return .Int32Array;
    if (try parse_keyword(p, .Uint8Array)) |_| return .Uint8Array;
    if (try parse_keyword(p, .Uint16Array)) |_| return .Uint16Array;
    if (try parse_keyword(p, .Uint32Array)) |_| return .Uint32Array;
    if (try parse_keyword(p, .Uint8ClampedArray)) |_| return .Uint8ClampedArray;
    if (try parse_keyword(p, .BigInt64Array)) |_| return .BigInt64Array;
    if (try parse_keyword(p, .BigUint64Array)) |_| return .BigUint64Array;
    if (try parse_keyword(p, .Float32Array)) |_| return .Float32Array;
    if (try parse_keyword(p, .Float64Array)) |_| return .Float64Array;
    return null;
}

// ExtendedAttributeList ::
//     [ ExtendedAttribute (, ExtendedAttribute)* ]
fn parseExtendedAttributeList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(p, '[') orelse return null;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);
    try list.append(alloc, try parseExtendedAttribute(alloc, p) orelse return);

    while (true) {
        try parse_symbol(p, ',') orelse break;
        try list.append(alloc, try parseExtendedAttribute(alloc, p) orelse return error.MalformedWebIDL);
    }
    try parse_symbol(p, ']') orelse return error.MalformedWebIDL;
}

// ExtendedAttribute ::
//     ( ExtendedAttributeInner? ) ExtendedAttributeRest?
//     [ ExtendedAttributeInner? ] ExtendedAttributeRest?
//     { ExtendedAttributeInner? } ExtendedAttributeRest?
//     Other ExtendedAttributeRest?
// ExtendedAttributeRest ::
//     ExtendedAttribute
// ExtendedAttributeInner? ::
//     ( ExtendedAttributeInner? ) ExtendedAttributeInner?
//     [ ExtendedAttributeInner? ] ExtendedAttributeInner?
//     { ExtendedAttributeInner? } ExtendedAttributeInner?
//     OtherOrComma ExtendedAttributeInner?
// Other ::
//     integer
//     decimal
//     identifier
//     string
//     other
//     -
//     -Infinity
//     .
//     ...
//     :
//     ;
//     <
//     =
//     >
//     ?
//     *
//     ByteString
//     DOMString
//     FrozenArray
//     Infinity
//     NaN
//     ObservableArray
//     Promise
//     USVString
//     any
//     bigint
//     boolean
//     byte
//     double
//     false
//     float
//     long
//     null
//     object
//     octet
//     or
//     optional
//     record
//     sequence
//     short
//     symbol
//     true
//     unsigned
//     undefined
//     ArgumentNameKeyword
//     BufferRelatedType
// OtherOrComma ::
//     Other
//     ,

// ExtendedAttributeNoArgs ::
//     identifier
// ExtendedAttributeArgList ::
//     identifier ( ArgumentList )
// ExtendedAttributeIdent ::
//     identifier = identifier
// ExtendedAttributeWildcard ::
//     identifier = *
// ExtendedAttributeIdentList ::
//     identifier = ( IdentifierList )
// ExtendedAttributeNamedArgList ::
//     identifier = identifier ( ArgumentList )

fn parseExtendedAttribute(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    const name_index = try parse_name(alloc, p) orelse return null;
    const name_len: u32 = @bitCast(p.parser.data.items[@intFromEnum(name_index)..][1..5].*);
    const name = p.parser.data.items[@intFromEnum(name_index)..][5..][0..name_len];
    {
        if (std.mem.eql(u8, name, "LenientSetter")) try p.warnings.append(alloc, "Renamed to [LegacyLenientSetter]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "LenientThis")) try p.warnings.append(alloc, "Renamed to [LegacyLenientThis]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "OverrideBuiltins")) try p.warnings.append(alloc, "Renamed to [LegacyOverrideBuiltIns]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "TreatNonObjectAsNull")) try p.warnings.append(alloc, "Renamed to [LegacyTreatNonObjectAsNull]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "Unforgeable")) try p.warnings.append(alloc, "Renamed to [LegacyUnforgeable]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "NamedConstructor")) try p.warnings.append(alloc, "Renamed to [LegacyFactoryFunction]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "TreatNullAs")) try p.warnings.append(alloc, "Renamed to [LegacyNullToEmptyString]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "NoInterfaceObject")) try p.warnings.append(alloc, "Renamed to [LegacyNoInterfaceObject]; see https://github.com/whatwg/webidl/pull/870");
        if (std.mem.eql(u8, name, "Constructor")) try p.warnings.append(alloc, "Constructors should now be represented as a `constructor()` operation on the interface instead of a `[Constructor]` extended attribute; see https://webidl.spec.whatwg.org/#idl-constructors");
    }
    if (try parse_symbol(p, '(')) |_| {
        _ = try parseArgumentList(alloc, p);
        _ = try parse_symbol(p, ')') orelse return error.MalformedWebIDL;
        return; //ExtendedAttributeArgList
    }
    _ = try parse_symbol(p, '=') orelse {
        return; //ExtendedAttributeNoArgs
    };
    if (try parse_symbol(p, '*')) |_| {
        return; //ExtendedAttributeWildcard
    }
    if (try parse_symbol(p, '(')) |_| {
        var list = std.ArrayListUnmanaged(w.IdentifierIndex){};
        defer list.deinit(alloc);
        try list.append(alloc, try parse_name(alloc, p) orelse return error.MalformedWebIDL);
        while (true) {
            _ = try parse_symbol(p, ',') orelse break;
            try list.append(alloc, try parse_name(alloc, p) orelse return error.MalformedWebIDL);
        }
        _ = try parse_symbol(p, ')') orelse return error.MalformedWebIDL;
        return; //ExtendedAttributeIdentList
    }
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    if (try parse_symbol(p, '(')) |_| {
        _ = try parseArgumentList(alloc, p);
        _ = try parse_symbol(p, ')') orelse return error.MalformedWebIDL;
        return; //ExtendedAttributeNamedArgList
    }
    return; //ExtendedAttributeIdent
}

//
//

// integer     =  -?([1-9][0-9]*|0[Xx][0-9A-Fa-f]+|0[0-7]*)
fn parse_integer(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.ValueIndex {
    const start = p.parser.idx;
    _ = try p.eatByte('-');
    if (try p.eatByte('0')) |_| {
        if (try p.eatAnyScalar("xX")) |_| {
            var at_least_one = false;
            while (true) {
                if (try p.eatRange('0', '9') != null or try p.eatRange('A', 'F') != null or try p.eatRange('a', 'f') != null) {
                    at_least_one = true;
                    continue;
                }
                break;
            }
            if (!at_least_one) return error.MalformedWebIDL;
            const end = p.parser.idx;
            return try p.addInteger(alloc, .{ start, end }, 16);
        }
        while (try p.eatRange('0', '7')) |_| {}
        const end = p.parser.idx;
        return try p.addInteger(alloc, .{ start, end }, 8);
    }
    _ = try p.eatRange('1', '9') orelse return null;
    while (try p.eatRange('0', '9')) |_| {}
    const end = p.parser.idx;
    return try p.addInteger(alloc, .{ start, end }, 10);
}

// decimal     =  -?(([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][+-]?[0-9]+)?|[0-9]+[Ee][+-]?[0-9]+)
fn parse_decimal(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = alloc;
    _ = p;
    // TODO:
    return null;
}

// identifier  =  [_-]?[A-Za-z][0-9A-Z_a-z-]*
fn parse_identifier(p: *Parser) anyerror!?struct { usize, usize, bool } {
    var start = p.parser.idx;
    var escaped = false;

    if (try p.eatByte('_')) |_| {
        start += 1;
        escaped = true;
    } else if (try p.eatByte('-')) |_| {
        //
    }
    _ = try p.eatAnyScalar("_-");
    _ = try p.eatRange('A', 'Z') orelse try p.eatRange('a', 'z') orelse {
        p.parser.idx = start; // need to reset in case we ate a '_' or '-'
        return null;
    };
    var cont = true;
    while (cont) {
        cont = false;
        cont = cont or try p.eatRange('0', '9') != null;
        cont = cont or try p.eatRange('A', 'Z') != null;
        cont = cont or try p.eatRange('a', 'z') != null;
        cont = cont or try p.eatByte('_') != null;
        cont = cont or try p.eatByte('-') != null;
    }
    const end = p.parser.idx;
    try skip_whitespace(p);
    return .{ start, end, escaped };
}

// string      =  "[^"]*"
fn parse_string(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.StringIndex {
    _ = try p.eatByte('"') orelse return null;
    const start = p.parser.idx;
    while (true) {
        if (try p.eatByte('"')) |_| break;
        p.parser.idx += 1;
    }
    const end = p.parser.idx;
    try skip_whitespace(p);
    return try p.addStr(alloc, p.parser.temp.items[start..end]);
}

// whitespace  =  [\t\n\r ]+
fn parse_whitespace(p: *Parser) anyerror!bool {
    var ret = false;
    var old: usize = 0;
    var iteration: usize = 0;
    while (p.parser.idx > old or iteration == 0) : (iteration += 1) {
        old = p.parser.idx;
        try p.peekAmt(1) orelse break;

        var cont = true;
        while (cont) {
            cont = false;
            cont = cont or try p.trimByte(' ') > 0;
            cont = cont or try p.trimByte('\n') > 0;
            cont = cont or try p.trimByte('\r') > 0;
            cont = cont or try p.trimByte('\t') > 0;
            ret = ret or cont;
        }
    }
    return ret;
}

// comment     =  \/\/.*|\/\*(.|\n)*?\*\/
fn parse_comment(p: *Parser) anyerror!bool {
    if (try p.eat("//")) |_| {
        _ = try p.eatUntil('\n') orelse return error.MalformedWebIDL;
        return true;
    }
    if (try p.eat("/*")) |_| {
        _ = try p.eatUntilStr("*/") orelse return error.MalformedWebIDL;
        return true;
    }
    return false;
}

//
//

fn parse_keyword(p: *Parser, s: Keyword) !?void {
    const start = p.parser.idx;
    const s_start, const s_end, _ = try parse_identifier(p) orelse return null;
    const ident = p.parser.temp.items[s_start..s_end];
    if (std.mem.eql(u8, ident, @tagName(s))) return;
    p.parser.idx = start;
    return null;
}

const Keyword = enum {
    @"-Infinity",
    @"async",
    @"const",
    @"enum",
    @"or",
    ArrayBuffer,
    BigInt64Array,
    BigUint64Array,
    ByteString,
    DOMString,
    DataView,
    Float32Array,
    Float64Array,
    FrozenArray,
    Infinity,
    Int16Array,
    Int32Array,
    Int8Array,
    NaN,
    ObservableArray,
    Promise,
    SharedArrayBuffer,
    USVString,
    Uint16Array,
    Uint32Array,
    Uint8Array,
    Uint8ClampedArray,
    any,
    attribute,
    bigint,
    boolean,
    byte,
    callback,
    constructor,
    deleter,
    dictionary,
    double,
    false,
    float,
    getter,
    includes,
    inherit,
    interface,
    iterable,
    long,
    maplike,
    mixin,
    namespace,
    null,
    object,
    octet,
    optional,
    partial,
    readonly,
    record,
    required,
    sequence,
    setlike,
    setter,
    short,
    static,
    stringifier,
    symbol,
    true,
    typedef,
    undefined,
    unrestricted,
    unsigned,
};

fn parse_symbol(p: *Parser, comptime c: u8) !?void {
    _ = try p.eatByte(c) orelse return null;
    try skip_whitespace(p);
}

fn skip_whitespace(p: *Parser) anyerror!void {
    while (try parse_whitespace(p) or try parse_comment(p)) {}
}

fn parse_name(alloc: std.mem.Allocator, p: *Parser) anyerror!?w.IdentifierIndex {
    const start, const end, const escaped = try parse_identifier(p) orelse return null;
    const name = p.parser.temp.items[start..end];
    if (std.mem.eql(u8, name, "constructor")) return error.MalformedWebIDL;
    if (std.mem.eql(u8, name, "toString")) return error.MalformedWebIDL;
    @setEvalBranchQuota(10_000);
    if (!escaped and std.meta.stringToEnum(Keyword, name) != null) return error.MalformedWebIDL;
    return try p.addIdent(alloc, .{ start, end });
}
