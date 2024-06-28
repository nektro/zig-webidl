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
    _ = try p.addStr(alloc, "");

    // const root = try parseDefinitionsPrecise(alloc, &p, @TypeOf(inreader).Error || Error);
    const root = try parseDefinitions(alloc, &p);
    if (p.avail() > 0) {
        std.log.warn("avail: {d}", .{p.avail()});
        std.log.warn("avail: {s}", .{p.parser.temp.items[p.parser.idx..]});
        return error.MalformedWebIDL;
    }
    const data = try p.parser.data.toOwnedSlice(alloc);

    return .{
        .data = data,
        .root = root,
    };
}

fn parseDefinitionsPrecise(alloc: std.mem.Allocator, p: *Parser, comptime E: type) E!void {
    return @errorCast(parseDefinitions(alloc, p));
}

// Definitions ::
//     (ExtendedAttributeList? Definition)*
fn parseDefinitions(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    try skip_whitespace(alloc, p);
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
fn parseArgumentNameKeyword(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .@"async")) |_| return;
    if (try parse_keyword(alloc, p, .attribute)) |_| return;
    if (try parse_keyword(alloc, p, .callback)) |_| return;
    if (try parse_keyword(alloc, p, .@"const")) |_| return;
    if (try parse_keyword(alloc, p, .constructor)) |_| return;
    if (try parse_keyword(alloc, p, .deleter)) |_| return;
    if (try parse_keyword(alloc, p, .dictionary)) |_| return;
    if (try parse_keyword(alloc, p, .@"enum")) |_| return;
    if (try parse_keyword(alloc, p, .getter)) |_| return;
    if (try parse_keyword(alloc, p, .includes)) |_| return;
    if (try parse_keyword(alloc, p, .inherit)) |_| return;
    if (try parse_keyword(alloc, p, .interface)) |_| return;
    if (try parse_keyword(alloc, p, .iterable)) |_| return;
    if (try parse_keyword(alloc, p, .maplike)) |_| return;
    if (try parse_keyword(alloc, p, .mixin)) |_| return;
    if (try parse_keyword(alloc, p, .namespace)) |_| return;
    if (try parse_keyword(alloc, p, .partial)) |_| return;
    if (try parse_keyword(alloc, p, .readonly)) |_| return;
    if (try parse_keyword(alloc, p, .required)) |_| return;
    if (try parse_keyword(alloc, p, .setlike)) |_| return;
    if (try parse_keyword(alloc, p, .setter)) |_| return;
    if (try parse_keyword(alloc, p, .static)) |_| return;
    if (try parse_keyword(alloc, p, .stringifier)) |_| return;
    if (try parse_keyword(alloc, p, .typedef)) |_| return;
    if (try parse_keyword(alloc, p, .unrestricted)) |_| return;
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
    if (try parse_keyword(alloc, p, .callback)) |_| {
        if (try parse_name(alloc, p)) |_| {
            try parse_symbol(alloc, p, '=') orelse return error.MalformedWebIDL;
            _ = try parseType(alloc, p) orelse return error.MalformedWebIDL;
            _ = try parseOptionalArgumentList(alloc, p) orelse return error.MalformedWebIDL;
            try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
            return;
        }
        if (try parse_keyword(alloc, p, .interface)) |_| {
            _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
            try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;
            while (true) {
                _ = try parseExtendedAttributeList(alloc, p);

                if (try parseConst(alloc, p)) |_| continue;
                if (try parseRegularOperation(alloc, p)) |_| continue;
                break;
            }
            try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
            try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;

            return;
        }
        return null;
    }
    if (try parse_keyword(alloc, p, .interface)) |_| {
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
    try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;
    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parseInterfaceMember(alloc, p) orelse break;
    }
    try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// Partial ::
//     partial PartialDefinition
// PartialDefinition ::
//     interface PartialInterfaceOrPartialMixin
//     PartialDictionary
//     Namespace
fn parsePartial(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .partial) orelse return null;

    if (try parse_keyword(alloc, p, .interface)) |_| {
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
    if (try parsePartialInterfaceRest(alloc, p)) |_| return;
    if (try parseMixinRest(alloc, p)) |_| return;
    return null;
}

// PartialInterfaceRest ::
//     identifier { PartialInterfaceMembers } ;
// PartialInterfaceMembers ::
//     (ExtendedAttributeList? PartialInterfaceMember)*
fn parsePartialInterfaceRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parse_name(alloc, p) orelse return null;
    try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;
    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parsePartialInterfaceMember(alloc, p) orelse break;
    }
    try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
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
    if (try parseOperation(alloc, p)) |_| return;
    if (try parseConst(alloc, p)) |_| return;
    return null;
}

// Inheritance ::
//     : identifier
fn parseInheritance(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(alloc, p, ':') orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
}

// MixinRest ::
//     mixin identifier { MixinMembers } ;
// MixinMembers ::
//     (ExtendedAttributeList? MixinMember)*
fn parseMixinRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parse_keyword(alloc, p, .mixin) orelse return null;

    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;
    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parseMixinMember(alloc, p) orelse break;
    }
    try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// MixinMember ::
//     Const
//     RegularOperation
//     Stringifier
//     readonly? AttributeRest
fn parseMixinMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseConst(alloc, p)) |_| return;
    if (try parseRegularOperation(alloc, p)) |_| return;
    if (try parseStringifier(alloc, p)) |_| return;

    _ = try parse_keyword(alloc, p, .readonly);
    _ = try parseAttributeRest(alloc, p) orelse return null;
    return;
}

// IncludesStatement ::
//     identifier includes identifier ;
fn parseIncludesStatement(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parse_name(alloc, p) orelse return null;
    _ = try parse_keyword(alloc, p, .includes) orelse return error.MalformedWebIDL;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// Const ::
//     const ConstType identifier = ConstValue ;
fn parseConst(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .@"const") orelse return null;
    _ = try parseConstType(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '=') orelse return error.MalformedWebIDL;
    _ = try parseConstValue(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
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
fn parseBooleanLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .true)) |_| return;
    if (try parse_keyword(alloc, p, .false)) |_| return;
    return null;
}

// FloatLiteral ::
//     decimal
//     -Infinity
//     Infinity
//     NaN
fn parseFloatLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_decimal(alloc, p)) |_| return;
    if (try parse_keyword(alloc, p, .@"-Infinity")) |_| return;
    if (try parse_keyword(alloc, p, .Infinity)) |_| return;
    if (try parse_keyword(alloc, p, .NaN)) |_| return;
    return null;
}

// ConstType ::
//     PrimitiveType
//     identifier
fn parseConstType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parsePrimitiveType(alloc, p)) |_| return;
    if (try parse_name(alloc, p)) |_| return;
    return null;
}

// ReadOnlyMember ::
//     readonly ReadOnlyMemberRest
// ReadOnlyMemberRest ::
//     AttributeRest
//     MaplikeRest
//     SetlikeRest
fn parseReadOnlyMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .readonly) orelse return null;

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
    try parse_keyword(alloc, p, .inherit) orelse return null;
    _ = try parseAttributeRest(alloc, p) orelse return error.MalformedWebIDL;
}

// AttributeRest ::
//     attribute TypeWithExtendedAttributes AttributeName ;
fn parseAttributeRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .attribute) orelse return null;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parseAttributeName(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// AttributeName ::
//     identifier
//     async
//     required
fn parseAttributeName(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .@"async")) |_| return;
    if (try parse_keyword(alloc, p, .required)) |_| return;
    if (try parse_name(alloc, p)) |_| return;
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
    if (try parse_keyword(alloc, p, .undefined)) |_| return;
    if (try parse_keyword(alloc, p, .null)) |_| return;

    if (try parse_symbol(alloc, p, '[')) |_| {
        try parse_symbol(alloc, p, ']') orelse return error.MalformedWebIDL;
        return;
    }
    if (try parse_symbol(alloc, p, '{')) |_| {
        try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
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
    if (try parse_keyword(alloc, p, .getter)) |_| return;
    if (try parse_keyword(alloc, p, .setter)) |_| return;
    if (try parse_keyword(alloc, p, .deleter)) |_| return;
    return null;
}

// OperationRest ::
//     OperationName? OptionalArgumentList ;
fn parseOperationRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseOperationName(alloc, p);
    _ = try parseOptionalArgumentList(alloc, p) orelse return null; //FIXME:
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// OperationName ::
//     includes
//     identifier
fn parseOperationName(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .includes)) |_| return;
    if (try parse_name(alloc, p)) |_| return; //
    return null;
}

// ArgumentList ::
//     Argument (, Argument)*
fn parseArgumentList(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);
    try list.append(alloc, try parseArgument(alloc, p) orelse return);

    while (true) {
        try parse_symbol(alloc, p, ',') orelse break;
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

    if (try parse_keyword(alloc, p, .optional)) |_| {
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
fn parseArgumentName(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseArgumentNameKeyword(alloc, p)) |_| return;
    if (try parse_name(alloc, p)) |_| return; //
    return null;
}

// Ellipsis ::
//     ...
fn parseEllipsis(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try p.eatByte('.') orelse return null;
    _ = try p.eatByte('.') orelse return error.MalformedWebIDL;
    _ = try p.eatByte('.') orelse return error.MalformedWebIDL;
    try skip_whitespace(alloc, p);
}

// Constructor ::
//     constructor OptionalArgumentList ;
fn parseConstructor(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .constructor) orelse return null;
    _ = try parseOptionalArgumentList(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// Stringifier ::
//     stringifier StringifierRest
// StringifierRest ::
//     readonly? AttributeRest
//     ;
fn parseStringifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .stringifier) orelse return null;

    if (try parse_symbol(alloc, p, ';')) |_| return;

    _ = try parse_keyword(alloc, p, .readonly);
    _ = try parseAttributeRest(alloc, p) orelse return error.MalformedWebIDL;
}

// StaticMember ::
//     static StaticMemberRest
// StaticMemberRest ::
//     readonly? AttributeRest
//     RegularOperation
fn parseStaticMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .static) orelse return null;

    if (try parse_keyword(alloc, p, .readonly)) |_| {
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
    try parse_keyword(alloc, p, .iterable) orelse return null;
    try parse_symbol(alloc, p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = if (try parse_symbol(alloc, p, ',') == null) null else (try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL);
    try parse_symbol(alloc, p, '>') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// AsyncIterable ::
//     async iterable < TypeWithExtendedAttributes OptionalType? > OptionalArgumentList? ;
// OptionalType ::
//     , TypeWithExtendedAttributes
fn parseAsyncIterable(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .@"async") orelse return null;
    try parse_keyword(alloc, p, .iterable) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = if (try parse_symbol(alloc, p, ',') == null) null else (try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL);
    try parse_symbol(alloc, p, '>') orelse return error.MalformedWebIDL;
    _ = try parseOptionalArgumentList(alloc, p);
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// OptionalArgumentList ::
//     ( ArgumentList? )
fn parseOptionalArgumentList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(alloc, p, '(') orelse return null;
    _ = try parseArgumentList(alloc, p);
    try parse_symbol(alloc, p, ')') orelse return error.MalformedWebIDL;
}

// ReadWriteMaplike ::
//     MaplikeRest
fn parseReadWriteMaplike(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    return parseMaplikeRest(alloc, p);
}

// MaplikeRest ::
//     maplike < TypeWithExtendedAttributes , TypeWithExtendedAttributes > ;
fn parseMaplikeRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .maplike) orelse return null;
    try parse_symbol(alloc, p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ',') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '>') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// ReadWriteSetlike ::
//     SetlikeRest
fn parseReadWriteSetlike(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    return parseSetlikeRest(alloc, p);
}

// SetlikeRest ::
//     setlike < TypeWithExtendedAttributes > ;
fn parseSetlikeRest(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .setlike) orelse return null;
    try parse_symbol(alloc, p, '<') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '>') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// Namespace ::
//     namespace identifier { NamespaceMembers? } ;
// NamespaceMembers? ::
//     (ExtendedAttributeList? NamespaceMember)+
fn parseNamespace(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .namespace) orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);

    while (true) {
        _ = try parseExtendedAttributeList(alloc, p);
        _ = try parseNamespaceMember(alloc, p) orelse break;
    }
    try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// NamespaceMember ::
//     RegularOperation
//     readonly AttributeRest
//     Const
fn parseNamespaceMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .readonly)) |_| {
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
    try parse_keyword(alloc, p, .dictionary) orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parseInheritance(alloc, p);
    try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);

    while (true) {
        _ = try parseDictionaryMember(alloc, p) orelse break;
    }
    try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// DictionaryMember ::
//     ExtendedAttributeList? DictionaryMemberRest
// DictionaryMemberRest ::
//     required TypeWithExtendedAttributes identifier ;
//     Type identifier Default? ;
fn parseDictionaryMember(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = try parseExtendedAttributeList(alloc, p);

    if (try parse_keyword(alloc, p, .required)) |_| {
        _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
        _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
        try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
        return;
    }
    if (try parseType(alloc, p)) |_| {
        _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
        try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
        return;
    }
    return null;
}

// PartialDictionary ::
//     dictionary identifier { DictionaryMembers? } ;
// DictionaryMembers? ::
//     DictionaryMember+
fn parsePartialDictionary(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .dictionary) orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);

    while (true) {
        _ = try parseDictionaryMember(alloc, p) orelse break;
    }
    try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// Default ::
//     = DefaultValue
fn parseDefault(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(alloc, p, '=') orelse return null;
    _ = try parseDefaultValue(alloc, p) orelse return error.MalformedWebIDL;
}

// Enum ::
//     enum identifier { EnumValueList } ;
// EnumValueList ::
//     string (, string)*
fn parseEnum(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .@"enum") orelse return null;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '{') orelse return error.MalformedWebIDL;

    var list = std.ArrayListUnmanaged(w.StringIndex){};
    defer list.deinit(alloc);
    try list.append(alloc, try parse_string(alloc, p) orelse return error.MalformedWebIDL);

    while (true) {
        try parse_symbol(alloc, p, ',') orelse break;
        try list.append(alloc, try parse_string(alloc, p) orelse continue);
    }
    try parse_symbol(alloc, p, '}') orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// Typedef ::
//     typedef TypeWithExtendedAttributes identifier ;
fn parseTypedef(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .typedef) orelse return null;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ';') orelse return error.MalformedWebIDL;
}

// Type ::
//     SingleType
//     UnionType Null?
fn parseType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseSingleType(alloc, p)) |_| return;

    _ = try parseUnionType(alloc, p) orelse return null;
    _ = try parse_symbol(alloc, p, '?');
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
    if (try parse_keyword(alloc, p, .any)) |_| return;
    if (try parsePromiseType(alloc, p)) |_| return;
    if (try parseDistinguishableType(alloc, p)) |_| return;
    return null;
}

// UnionType ::
//     ( UnionMemberType (or UnionMemberType)* )
fn parseUnionType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(alloc, p, '(') orelse return null;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);
    try list.append(alloc, try parseUnionMemberType(alloc, p) orelse return error.MalformedWebIDL);

    while (true) {
        try parse_keyword(alloc, p, .@"or") orelse break;
        try list.append(alloc, try parseUnionMemberType(alloc, p) orelse return error.MalformedWebIDL);
    }
    try parse_symbol(alloc, p, ')') orelse return error.MalformedWebIDL;
    if (list.items.len == 1) return error.MalformedWebIDL;
}

// UnionMemberType ::
//     ExtendedAttributeList? DistinguishableType
//     UnionType Null?
fn parseUnionMemberType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseExtendedAttributeList(alloc, p)) |_| {
        if (try parse_keyword(alloc, p, .any)) |_| return error.MalformedWebIDL;
        _ = try parseDistinguishableType(alloc, p) orelse return error.MalformedWebIDL;
        return;
    }
    if (try parse_keyword(alloc, p, .any)) |_| return error.MalformedWebIDL;
    if (try parseDistinguishableType(alloc, p)) |_| {
        return;
    }
    _ = try parseUnionType(alloc, p) orelse return null;
    _ = try parseNull(alloc, p);
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
            if (try parse_keyword(alloc, p, .sequence)) |_| break :blk2;
            if (try parse_keyword(alloc, p, .FrozenArray)) |_| break :blk2;
            if (try parse_keyword(alloc, p, .ObservableArray)) |_| break :blk2;
            break :blk;
        };
        try parse_symbol(alloc, p, '<') orelse return error.MalformedWebIDL;
        _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
        try parse_symbol(alloc, p, '>') orelse return error.MalformedWebIDL;
        _ = try parse_symbol(alloc, p, '?');
        return;
    };
    _ = blk: {
        if (try parse_keyword(alloc, p, .object)) |_| break :blk;
        if (try parse_keyword(alloc, p, .symbol)) |_| break :blk;
        if (try parse_keyword(alloc, p, .undefined)) |_| break :blk;
        if (try parsePrimitiveType(alloc, p)) |_| break :blk;
        if (try parseStringType(alloc, p)) |_| break :blk;
        if (try parseBufferRelatedType(alloc, p)) |_| break :blk;
        if (try parseRecordType(alloc, p)) |_| break :blk;
        if (try parse_name(alloc, p)) |_| break :blk;
        return null;
    };
    _ = try parse_symbol(alloc, p, '?');
}

// PrimitiveType ::
//     UnsignedIntegerType
//     UnrestrictedFloatType
//     boolean
//     byte
//     octet
//     bigint
fn parsePrimitiveType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parseUnsignedIntegerType(alloc, p)) |_| return;
    if (try parseUnrestrictedFloatType(alloc, p)) |_| return;
    if (try parse_keyword(alloc, p, .boolean)) |_| return;
    if (try parse_keyword(alloc, p, .byte)) |_| return;
    if (try parse_keyword(alloc, p, .octet)) |_| return;
    if (try parse_keyword(alloc, p, .bigint)) |_| return;
    return null;
}

// UnrestrictedFloatType ::
//     unrestricted FloatType
//     FloatType
fn parseUnrestrictedFloatType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .unrestricted)) |_| {
        _ = try parseFloatType(alloc, p) orelse return null;
        return;
    }
    _ = try parseFloatType(alloc, p) orelse return null;
    return;
}

// FloatType ::
//     float
//     double
fn parseFloatType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .float)) |_| return;
    if (try parse_keyword(alloc, p, .double)) |_| return;
    return null;
}

// UnsignedIntegerType ::
//     unsigned IntegerType
//     IntegerType
fn parseUnsignedIntegerType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .unsigned)) |_| {
        _ = try parseIntegerType(alloc, p) orelse return null;
        return;
    }
    _ = try parseIntegerType(alloc, p) orelse return null;
    return;
}

// IntegerType ::
//     short
//     long long?
fn parseIntegerType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .short)) |_| return;

    _ = try parse_keyword(alloc, p, .long) orelse return null;
    _ = try parse_keyword(alloc, p, .long);
}

// StringType ::
//     ByteString
//     DOMString
//     USVString
fn parseStringType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .ByteString)) |_| return;
    if (try parse_keyword(alloc, p, .DOMString)) |_| return;
    if (try parse_keyword(alloc, p, .USVString)) |_| return;
    return null;
}

// PromiseType ::
//     Promise < Type >
fn parsePromiseType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .Promise) orelse return null;
    try parse_symbol(alloc, p, '<') orelse return error.MalformedWebIDL;
    _ = try parseType(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '>') orelse return error.MalformedWebIDL;
}

// RecordType ::
//     record < StringType , TypeWithExtendedAttributes >
fn parseRecordType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_keyword(alloc, p, .record) orelse return null;
    try parse_symbol(alloc, p, '<') orelse return error.MalformedWebIDL;
    _ = try parseStringType(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, ',') orelse return error.MalformedWebIDL;
    _ = try parseTypeWithExtendedAttributes(alloc, p) orelse return error.MalformedWebIDL;
    try parse_symbol(alloc, p, '>') orelse return error.MalformedWebIDL;
}

// Null? ::
//     ?
fn parseNull(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    return parse_symbol(alloc, p, '?');
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
fn parseBufferRelatedType(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    if (try parse_keyword(alloc, p, .ArrayBuffer)) |_| return;
    if (try parse_keyword(alloc, p, .SharedArrayBuffer)) |_| return;
    if (try parse_keyword(alloc, p, .DataView)) |_| return;
    if (try parse_keyword(alloc, p, .Int8Array)) |_| return;
    if (try parse_keyword(alloc, p, .Int16Array)) |_| return;
    if (try parse_keyword(alloc, p, .Int32Array)) |_| return;
    if (try parse_keyword(alloc, p, .Uint8Array)) |_| return;
    if (try parse_keyword(alloc, p, .Uint16Array)) |_| return;
    if (try parse_keyword(alloc, p, .Uint32Array)) |_| return;
    if (try parse_keyword(alloc, p, .Uint8ClampedArray)) |_| return;
    if (try parse_keyword(alloc, p, .BigInt64Array)) |_| return;
    if (try parse_keyword(alloc, p, .BigUint64Array)) |_| return;
    if (try parse_keyword(alloc, p, .Float32Array)) |_| return;
    if (try parse_keyword(alloc, p, .Float64Array)) |_| return;
    return null;
}

// ExtendedAttributeList ::
//     [ ExtendedAttribute (, ExtendedAttribute)* ]
fn parseExtendedAttributeList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    try parse_symbol(alloc, p, '[') orelse return null;

    var list = std.ArrayListUnmanaged(void){};
    defer list.deinit(alloc);
    try list.append(alloc, try parseExtendedAttribute(alloc, p) orelse return);

    while (true) {
        try parse_symbol(alloc, p, ',') orelse break;
        try list.append(alloc, try parseExtendedAttribute(alloc, p) orelse return error.MalformedWebIDL);
    }
    try parse_symbol(alloc, p, ']') orelse return error.MalformedWebIDL;
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
    _ = try parse_name(alloc, p) orelse return null;
    if (try parse_symbol(alloc, p, '(')) |_| {
        _ = try parseArgumentList(alloc, p);
        _ = try parse_symbol(alloc, p, ')') orelse return error.MalformedWebIDL;
        return; //ExtendedAttributeArgList
    }
    _ = try parse_symbol(alloc, p, '=') orelse {
        return; //ExtendedAttributeNoArgs
    };
    if (try parse_symbol(alloc, p, '*')) |_| {
        return; //ExtendedAttributeWildcard
    }
    if (try parse_symbol(alloc, p, '(')) |_| {
        var list = std.ArrayListUnmanaged(w.StringIndex){};
        defer list.deinit(alloc);
        try list.append(alloc, try p.addIdent(alloc, try parse_name(alloc, p) orelse return error.MalformedWebIDL));
        while (true) {
            _ = try parse_symbol(alloc, p, ',') orelse break;
            try list.append(alloc, try p.addIdent(alloc, try parse_name(alloc, p) orelse return error.MalformedWebIDL));
        }
        _ = try parse_symbol(alloc, p, ')') orelse return error.MalformedWebIDL;
        return; //ExtendedAttributeIdentList
    }
    _ = try parse_name(alloc, p) orelse return error.MalformedWebIDL;
    if (try parse_symbol(alloc, p, '(')) |_| {
        _ = try parseArgumentList(alloc, p);
        _ = try parse_symbol(alloc, p, ')') orelse return error.MalformedWebIDL;
        return; //ExtendedAttributeNamedArgList
    }
    return; //ExtendedAttributeIdent
}

//
//

// integer     =  -?([1-9][0-9]*|0[Xx][0-9A-Fa-f]+|0[0-7]*)
fn parse_integer(alloc: std.mem.Allocator, p: *Parser) anyerror!?[2]usize {
    _ = alloc;
    const start = p.parser.idx;

    _ = try p.eatAnyScalar("-");
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
            return .{ start, end };
        }
        while (try p.eatRange('0', '7')) |_| {}
        const end = p.parser.idx;
        return .{ start, end };
    }
    _ = try p.eatRange('1', '9') orelse return null;
    while (try p.eatRange('0', '9')) |_| {}
    const end = p.parser.idx;
    return .{ start, end };
}

// decimal     =  -?(([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][+-]?[0-9]+)?|[0-9]+[Ee][+-]?[0-9]+)
fn parse_decimal(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = alloc;
    _ = p;
    // TODO:
    return null;
}

// identifier  =  [_-]?[A-Za-z][0-9A-Z_a-z-]*
fn parse_identifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?[2]usize {
    var start = p.parser.idx;

    if (try p.eatByte('_')) |_| {
        start += 1;
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
        cont = cont or try p.eatByte('-') != null;
    }
    const end = p.parser.idx;
    try skip_whitespace(alloc, p);
    return .{ start, end };
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
    try skip_whitespace(alloc, p);
    return try p.addStr(alloc, p.parser.temp.items[start..end]);
}

// whitespace  =  [\t\n\r ]+
fn parse_whitespace(alloc: std.mem.Allocator, p: *Parser) anyerror!bool {
    _ = alloc;
    var ret = false;
    var old: usize = 0;
    while (p.parser.idx > old) {
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
fn parse_comment(alloc: std.mem.Allocator, p: *Parser) anyerror!bool {
    _ = alloc;
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

// other       =  [^\t\n\r 0-9A-Za-z]
fn parse_other(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    _ = alloc;
    _ = p;
    @compileError("unimplemented");
}

//
//

fn parse_keyword(alloc: std.mem.Allocator, p: *Parser, s: Keyword) !?void {
    const start = p.parser.idx;
    const s_start, const s_end = try parse_identifier(alloc, p) orelse return null;
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

fn parse_symbol(alloc: std.mem.Allocator, p: *Parser, comptime c: u8) !?void {
    _ = try p.eatByte(c) orelse return null;
    try skip_whitespace(alloc, p);
}

fn skip_whitespace(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    while (try parse_whitespace(alloc, p) or try parse_comment(alloc, p)) {}
}

fn parse_name(alloc: std.mem.Allocator, p: *Parser) anyerror!?[2]usize {
    const start, const end = try parse_identifier(alloc, p) orelse return null;
    const name = p.parser.temp.items[start..end];
    if (std.mem.eql(u8, name, "constructor")) return error.MalformedWebIDL;
    if (std.mem.eql(u8, name, "toString")) return error.MalformedWebIDL;
    return .{ start, end };
}
