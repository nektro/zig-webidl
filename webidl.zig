//! Parser for Web Interface Design Language
//! https://webidl.spec.whatwg.org/

const std = @import("std");
const string = []const u8;
const tracer = @import("tracer");
const extras = @import("extras");
const Parser = @import("./Parser.zig");
const j = @import("./types.zig");

inline fn w(val: anytype) ?W(@TypeOf(val)) {
    return val catch null;
}

fn W(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .ErrorUnion => |v| v.payload,
        else => unreachable,
    };
}

pub fn parse(alloc: std.mem.Allocator, path: string, inreader: anytype) Error!j.Document {
    //
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    _ = path;

    var counter = std.io.countingReader(inreader);
    const anyreader = extras.AnyReader.from(counter.reader());
    var p = Parser.init(alloc, anyreader);
    defer p.deinit();

    _ = try p.addStr("");

    const defs = try parseDefinitions(&p);
    _ = defs;
    return j.Document{
        //
    };
}

pub const Error = std.mem.Allocator.Error || error{ InvalidIDL, TODO, Null };

/// Definitions ::
///     ExtendedAttributeList Definition Definitions
///     ε
fn parseDefinitions(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Definition ::
///     CallbackOrInterfaceOrMixin
///     Namespace
///     Partial
///     Dictionary
///     Enum
///     Typedef
///     IncludesStatement
fn parseDefinition(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ArgumentNameKeyword ::
///     async
///     attribute
///     callback
///     const
///     constructor
///     deleter
///     dictionary
///     enum
///     getter
///     includes
///     inherit
///     interface
///     iterable
///     maplike
///     mixin
///     namespace
///     partial
///     readonly
///     required
///     setlike
///     setter
///     static
///     stringifier
///     typedef
///     unrestricted
fn parseArgumentNameKeyword(p: *Parser) !j.ArgumentNameKeyword {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// CallbackOrInterfaceOrMixin ::
///     callback CallbackRestOrInterface
///     interface InterfaceOrMixin
fn parseCallbackOrInterfaceOrMixin(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// InterfaceOrMixin ::
///     InterfaceRest
///     MixinRest
fn parseInterfaceOrMixin(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// InterfaceRest ::
///     identifier Inheritance { InterfaceMembers } ;
fn parseInterfaceRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Partial ::
///     partial PartialDefinition
fn parsePartial(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PartialDefinition ::
///     interface PartialInterfaceOrPartialMixin
///     PartialDictionary
///     Namespace
fn parsePartialDefinition(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PartialInterfaceOrPartialMixin ::
///     PartialInterfaceRest
///     MixinRest
fn parsePartialInterfaceOrPartialMixin(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PartialInterfaceRest ::
///     identifier { PartialInterfaceMembers } ;
fn parsePartialInterfaceRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// InterfaceMembers ::
///     ExtendedAttributeList InterfaceMember InterfaceMembers
///     ε
fn parseInterfaceMembers(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// InterfaceMember ::
///     PartialInterfaceMember
///     Constructor
fn parseInterfaceMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PartialInterfaceMembers ::
///     ExtendedAttributeList PartialInterfaceMember PartialInterfaceMembers
///     ε
fn parsePartialInterfaceMembers(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PartialInterfaceMember ::
///     Const
///     Operation
///     Stringifier
///     StaticMember
///     Iterable
///     AsyncIterable
///     ReadOnlyMember
///     ReadWriteAttribute
///     ReadWriteMaplike
///     ReadWriteSetlike
///     InheritAttribute
fn parsePartialInterfaceMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Inheritance ::
///     : identifier
///     ε
fn parseInheritance(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// MixinRest ::
///     mixin identifier { MixinMembers } ;
fn parseMixinRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// MixinMembers ::
///     ExtendedAttributeList MixinMember MixinMembers
///     ε
fn parseMixinMembers(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// MixinMember ::
///     Const
///     RegularOperation
///     Stringifier
///     OptionalReadOnly AttributeRest
fn parseMixinMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// IncludesStatement ::
///     identifier includes identifier ;
fn parseIncludesStatement(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// CallbackRestOrInterface ::
///     CallbackRest
///     interface identifier { CallbackInterfaceMembers } ;
fn parseCallbackRestOrInterface(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// CallbackInterfaceMembers ::
///     ExtendedAttributeList CallbackInterfaceMember CallbackInterfaceMembers
///     ε
fn parseCallbackInterfaceMembers(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// CallbackInterfaceMember ::
///     Const
///     RegularOperation
fn parseCallbackInterfaceMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Const ::
///     const ConstType identifier = ConstValue ;
fn parseConst(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ConstValue ::
///     BooleanLiteral
///     FloatLiteral
///     integer
fn parseConstValue(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// BooleanLiteral ::
///     true
///     false
fn parseBooleanLiteral(p: *Parser) !bool {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// FloatLiteral ::
///     decimal
///     -Infinity
///     Infinity
///     NaN
fn parseFloatLiteral(p: *Parser) !f32 {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ConstType ::
///     PrimitiveType
///     identifier
fn parseConstType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ReadOnlyMember ::
///     readonly ReadOnlyMemberRest
fn parseReadOnlyMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ReadOnlyMemberRest ::
///     AttributeRest
///     MaplikeRest
///     SetlikeRest
fn parseReadOnlyMemberRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ReadWriteAttribute ::
///     AttributeRest
fn parseReadWriteAttribute(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// InheritAttribute ::
///     inherit AttributeRest
fn parseInheritAttribute(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// AttributeRest ::
///     attribute TypeWithExtendedAttributes AttributeName ;
fn parseAttributeRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// AttributeName ::
///     AttributeNameKeyword
///     identifier
fn parseAttributeName(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// AttributeNameKeyword ::
///     async
///     required
fn parseAttributeNameKeyword(p: *Parser) !j.AttributeNameKeyword {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OptionalReadOnly ::
///     readonly
///     ε
fn parseOptionalReadOnly(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// DefaultValue ::
///     ConstValue
///     string
///     [ ]
///     { }
///     null
///     undefined
fn parseDefaultValue(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Operation ::
///     RegularOperation
///     SpecialOperation
fn parseOperation(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// RegularOperation ::
///     Type OperationRest
fn parseRegularOperation(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// SpecialOperation ::
///     Special RegularOperation
fn parseSpecialOperation(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Special ::
///     getter
///     setter
///     deleter
fn parseSpecial(p: *Parser) !j.Special {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OperationRest ::
///     OptionalOperationName ( ArgumentList ) ;
fn parseOperationRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OptionalOperationName ::
///     OperationName
///     ε
fn parseOptionalOperationName(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OperationName ::
///     OperationNameKeyword
///     identifier
fn parseOperationName(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OperationNameKeyword ::
///     includes
fn parseOperationNameKeyword(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ArgumentList ::
///     Argument Arguments
///     ε
/// Arguments ::
///     , Argument Arguments
///     ε
fn parseArgumentList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Argument ::
///     ExtendedAttributeList ArgumentRest
fn parseArgument(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ArgumentRest ::
///     optional TypeWithExtendedAttributes ArgumentName Default
///     Type Ellipsis ArgumentName
fn parseArgumentRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ArgumentName ::
///     ArgumentNameKeyword
///     identifier
fn parseArgumentName(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Ellipsis ::
///     ...
///     ε
fn parseEllipsis(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Constructor ::
///     constructor ( ArgumentList ) ;
fn parseConstructor(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Stringifier ::
///     stringifier StringifierRest
fn parseStringifier(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// StringifierRest ::
///     OptionalReadOnly AttributeRest
///     ;
fn parseStringifierRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// StaticMember ::
///     static StaticMemberRest
fn parseStaticMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// StaticMemberRest ::
///     OptionalReadOnly AttributeRest
///     RegularOperation
fn parseStaticMemberRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Iterable ::
///     iterable < TypeWithExtendedAttributes OptionalType > ;
fn parseIterable(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OptionalType ::
///     , TypeWithExtendedAttributes
///     ε
fn parseOptionalType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// AsyncIterable ::
///     async iterable < TypeWithExtendedAttributes OptionalType > OptionalArgumentList ;
fn parseAsyncIterable(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OptionalArgumentList ::
///     ( ArgumentList )
///     ε
fn parseOptionalArgumentList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ReadWriteMaplike ::
///     MaplikeRest
fn parseReadWriteMaplike(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// MaplikeRest ::
///     maplike < TypeWithExtendedAttributes , TypeWithExtendedAttributes > ;
fn parseMaplikeRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ReadWriteSetlike ::
///     SetlikeRest
fn parseReadWriteSetlike(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// SetlikeRest ::
///     setlike < TypeWithExtendedAttributes > ;
fn parseSetlikeRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Namespace ::
///     namespace identifier { NamespaceMembers } ;
fn parseNamespace(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// NamespaceMembers ::
///     ExtendedAttributeList NamespaceMember NamespaceMembers
///     ε
fn parseNamespaceMembers(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// NamespaceMember ::
///     RegularOperation
///     readonly AttributeRest
///     Const
fn parseNamespaceMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Dictionary ::
///     dictionary identifier Inheritance { DictionaryMembers } ;
fn parseDictionary(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// DictionaryMembers ::
///     DictionaryMember DictionaryMembers
///     ε
fn parseDictionaryMembers(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// DictionaryMember ::
///     ExtendedAttributeList DictionaryMemberRest
fn parseDictionaryMember(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// DictionaryMemberRest ::
///     required TypeWithExtendedAttributes identifier ;
///     Type identifier Default ;
fn parseDictionaryMemberRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PartialDictionary ::
///     dictionary identifier { DictionaryMembers } ;
fn parsePartialDictionary(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Default ::
///     = DefaultValue
///     ε
fn parseDefault(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Enum ::
///     enum identifier { EnumValueList } ;
fn parseEnum(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// EnumValueList ::
///     string EnumValueListComma
fn parseEnumValueList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// EnumValueListComma ::
///     , EnumValueListString
///     ε
fn parseEnumValueListComma(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// EnumValueListString ::
///     string EnumValueListComma
///     ε
fn parseEnumValueListString(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// CallbackRest ::
///     identifier = Type ( ArgumentList ) ;
fn parseCallbackRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Typedef ::
///     typedef TypeWithExtendedAttributes identifier ;
fn parseTypedef(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Type ::
///     SingleType
///     UnionType Null
fn parseType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// TypeWithExtendedAttributes ::
///     ExtendedAttributeList Type
fn parseTypeWithExtendedAttributes(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// SingleType ::
///     DistinguishableType
///     any
///     PromiseType
fn parseSingleType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// UnionType ::
///     ( UnionMemberType or UnionMemberType UnionMemberTypes )
fn parseUnionType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// UnionMemberType ::
///     ExtendedAttributeList DistinguishableType
///     UnionType Null
fn parseUnionMemberType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// UnionMemberTypes ::
///     or UnionMemberType UnionMemberTypes
///     ε
fn parseUnionMemberTypes(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// DistinguishableType ::
///     PrimitiveType Null
///     StringType Null
///     identifier Null
///     sequence < TypeWithExtendedAttributes > Null
///     object Null
///     symbol Null
///     BufferRelatedType Null
///     FrozenArray < TypeWithExtendedAttributes > Null
///     ObservableArray < TypeWithExtendedAttributes > Null
///     RecordType Null
///     undefined Null
fn parseDistinguishableType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PrimitiveType ::
///     UnsignedIntegerType
///     UnrestrictedFloatType
///     boolean
///     byte
///     octet
///     bigint
fn parsePrimitiveType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// UnrestrictedFloatType ::
///     unrestricted FloatType
///     FloatType
fn parseUnrestrictedFloatType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// FloatType ::
///     float
///     double
fn parseFloatType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// UnsignedIntegerType ::
///     unsigned IntegerType
///     IntegerType
fn parseUnsignedIntegerType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// IntegerType ::
///     short
///     long OptionalLong
fn parseIntegerType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OptionalLong ::
///     long
///     ε
fn parseOptionalLong(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// StringType ::
///     ByteString
///     DOMString
///     USVString
fn parseStringType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// PromiseType ::
///     Promise < Type >
fn parsePromiseType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// RecordType ::
///     record < StringType , TypeWithExtendedAttributes >
fn parseRecordType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Null ::
///     ?
///     ε
fn parseNull(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// BufferRelatedType ::
///     ArrayBuffer
///     SharedArrayBuffer
///     DataView
///     Int8Array
///     Int16Array
///     Int32Array
///     Uint8Array
///     Uint16Array
///     Uint32Array
///     Uint8ClampedArray
///     BigInt64Array
///     BigUint64Array
///     Float32Array
///     Float64Array
fn parseBufferRelatedType(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeList ::
///     [ ExtendedAttribute ExtendedAttributes ]
///     ε
fn parseExtendedAttributeList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributes ::
///     , ExtendedAttribute ExtendedAttributes
///     ε
fn parseExtendedAttributes(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttribute ::
///     ( ExtendedAttributeInner ) ExtendedAttributeRest
///     [ ExtendedAttributeInner ] ExtendedAttributeRest
///     { ExtendedAttributeInner } ExtendedAttributeRest
///     Other ExtendedAttributeRest
fn parseExtendedAttribute(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeRest ::
///     ExtendedAttribute
///     ε
fn parseExtendedAttributeRest(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeInner ::
///     ( ExtendedAttributeInner ) ExtendedAttributeInner
///     [ ExtendedAttributeInner ] ExtendedAttributeInner
///     { ExtendedAttributeInner } ExtendedAttributeInner
///     OtherOrComma ExtendedAttributeInner
///     ε
fn parseExtendedAttributeInner(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Other ::
///     integer
///     decimal
///     identifier
///     string
///     other
///     -
///     -Infinity
///     .
///     ...
///     :
///     ;
///     <
///     =
///     >
///     ?
///     *
///     ByteString
///     DOMString
///     FrozenArray
///     Infinity
///     NaN
///     ObservableArray
///     Promise
///     USVString
///     any
///     bigint
///     boolean
///     byte
///     double
///     false
///     float
///     long
///     null
///     object
///     octet
///     or
///     optional
///     record
///     sequence
///     short
///     symbol
///     true
///     unsigned
///     undefined
///     ArgumentNameKeyword
///     BufferRelatedType
fn parseOther(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// OtherOrComma ::
///     Other
///     ,
fn parseOtherOrComma(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// IdentifierList ::
///     identifier Identifiers
fn parseIdentifierList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// Identifiers ::
///     , identifier Identifiers
///     ε
fn parseIdentifiers(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeNoArgs ::
///     identifier
fn parseExtendedAttributeNoArgs(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeArgList ::
///     identifier ( ArgumentList )
fn parseExtendedAttributeArgList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeIdent ::
///     identifier = identifier
fn parseExtendedAttributeIdent(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeWildcard ::
///     identifier = *
fn parseExtendedAttributeWildcard(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeIdentList ::
///     identifier = ( IdentifierList )
fn parseExtendedAttributeIdentList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// ExtendedAttributeNamedArgList ::
///     identifier = identifier ( ArgumentList )
fn parseExtendedAttributeNamedArgList(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

//
//

/// integer     =  -?([1-9][0-9]*|0[Xx][0-9A-Fa-f]+|0[0-7]*)/
fn parse_integer(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// decimal     =  -?(([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][+-]?[0-9]+)?|[0-9]+[Ee][+-]?[0-9]+)/
fn parse_decimal(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// identifier  =  [_-]?[A-Za-z][0-9A-Z_a-z-]*/
fn parse_identifier(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// string      =  "[^"]*"/
fn parse_string(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// whitespace  =  [\t\n\r ]+/
fn parse_whitespace(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// comment     =  \/\/.*|\/\*(.|\n)*?\*\//
fn parse_comment(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}

/// other       =  [^\t\n\r 0-9A-Za-z]/
fn parse_other(p: *Parser) Error!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.parser.idx});
    defer t.end();

    return error.TODO;
}
