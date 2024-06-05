//! Parser for Web Interface Design Language
//! https://webidl.spec.whatwg.org/

const std = @import("std");
const string = []const u8;
const tracer = @import("tracer");
const extras = @import("extras");
const Parser = @import("./Parser.zig");
const w = @import("./types.zig");

pub fn parse(alloc: std.mem.Allocator, path: string, inreader: anytype) !w.Document {
    //
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

    _ = alloc;
    _ = path;
    _ = inreader;

    @panic("TODO");
}

// Definitions ::
//     (ExtendedAttributeList? Definition)*

// Definition ::
//     CallbackOrInterfaceOrMixin
//     Namespace
//     Partial
//     Dictionary
//     Enum
//     Typedef
//     IncludesStatement

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

// CallbackOrInterfaceOrMixin ::
//     callback CallbackRestOrInterface
//     interface InterfaceOrMixin

// InterfaceOrMixin ::
//     InterfaceRest
//     MixinRest

// InterfaceRest ::
//     identifier Inheritance? { InterfaceMembers? } ;

// Partial ::
//     partial PartialDefinition

// PartialDefinition ::
//     interface PartialInterfaceOrPartialMixin
//     PartialDictionary
//     Namespace

// PartialInterfaceOrPartialMixin ::
//     PartialInterfaceRest
//     MixinRest

// PartialInterfaceRest ::
//     identifier { PartialInterfaceMembers? } ;

// InterfaceMembers ::
//     (ExtendedAttributeList? InterfaceMember)*

// InterfaceMember ::
//     PartialInterfaceMember
//     Constructor

// PartialInterfaceMembers ::
//     (ExtendedAttributeList? PartialInterfaceMember)+

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

// Inheritance ::
//     : identifier

// MixinRest ::
//     mixin identifier { MixinMembers? } ;

// MixinMembers ::
//     (ExtendedAttributeList? MixinMember)+

// MixinMember ::
//     Const
//     RegularOperation
//     Stringifier
//     OptionalReadOnly? AttributeRest

// IncludesStatement ::
//     identifier includes identifier ;

// CallbackRestOrInterface ::
//     CallbackRest
//     interface identifier { CallbackInterfaceMembers? } ;

// CallbackInterfaceMembers ::
//     (ExtendedAttributeList? CallbackInterfaceMember)+

// CallbackInterfaceMember ::
//     Const
//     RegularOperation

// Const ::
//     const ConstType identifier = ConstValue ;

// ConstValue ::
//     BooleanLiteral
//     FloatLiteral
//     integer

// BooleanLiteral ::
//     true
//     false

// FloatLiteral ::
//     decimal
//     -Infinity
//     Infinity
//     NaN

// ConstType ::
//     PrimitiveType
//     identifier

// ReadOnlyMember ::
//     readonly ReadOnlyMemberRest

// ReadOnlyMemberRest ::
//     AttributeRest
//     MaplikeRest
//     SetlikeRest

// ReadWriteAttribute ::
//     AttributeRest

// InheritAttribute ::
//     inherit AttributeRest

// AttributeRest ::
//     attribute TypeWithExtendedAttributes AttributeName ;

// AttributeName ::
//     AttributeNameKeyword
//     identifier

// AttributeNameKeyword ::
//     async
//     required

// OptionalReadOnly ::
//     readonly

// DefaultValue ::
//     ConstValue
//     string
//     [ ]
//     { }
//     null
//     undefined

// Operation ::
//     RegularOperation
//     SpecialOperation

// RegularOperation ::
//     Type OperationRest

// SpecialOperation ::
//     Special RegularOperation

// Special ::
//     getter
//     setter
//     deleter

// OperationRest ::
//     OptionalOperationName? ( ArgumentList? ) ;

// OptionalOperationName ::
//     OperationName

// OperationName ::
//     OperationNameKeyword
//     identifier

// OperationNameKeyword ::
//     includes

// ArgumentList ::
//     Argument (, Argument)*

// Argument ::
//     ExtendedAttributeList? ArgumentRest

// ArgumentRest ::
//     optional TypeWithExtendedAttributes ArgumentName Default?
//     Type Ellipsis? ArgumentName

// ArgumentName ::
//     ArgumentNameKeyword
//     identifier

// Ellipsis ::
//     ...

// Constructor ::
//     constructor ( ArgumentList? ) ;

// Stringifier ::
//     stringifier StringifierRest

// StringifierRest ::
//     OptionalReadOnly? AttributeRest
//     ;

// StaticMember ::
//     static StaticMemberRest

// StaticMemberRest ::
//     OptionalReadOnly? AttributeRest
//     RegularOperation

// Iterable ::
//     iterable < TypeWithExtendedAttributes OptionalType? > ;

// OptionalType ::
//     , TypeWithExtendedAttributes

// AsyncIterable ::
//     async iterable < TypeWithExtendedAttributes OptionalType? > OptionalArgumentList? ;

// OptionalArgumentList? ::
//     ( ArgumentList? )

// ReadWriteMaplike ::
//     MaplikeRest

// MaplikeRest ::
//     maplike < TypeWithExtendedAttributes , TypeWithExtendedAttributes > ;

// ReadWriteSetlike ::
//     SetlikeRest

// SetlikeRest ::
//     setlike < TypeWithExtendedAttributes > ;

// Namespace ::
//     namespace identifier { NamespaceMembers? } ;

// NamespaceMembers? ::
//     (ExtendedAttributeList? NamespaceMember)+

// NamespaceMember ::
//     RegularOperation
//     readonly AttributeRest
//     Const

// Dictionary ::
//     dictionary identifier Inheritance? { DictionaryMembers? } ;

// DictionaryMembers? ::
//     DictionaryMember+

// DictionaryMember ::
//     ExtendedAttributeList? DictionaryMemberRest

// DictionaryMemberRest ::
//     required TypeWithExtendedAttributes identifier ;
//     Type identifier Default? ;

// PartialDictionary ::
//     dictionary identifier { DictionaryMembers? } ;

// Default ::
//     = DefaultValue

// Enum ::
//     enum identifier { EnumValueList } ;

// EnumValueList ::
//     string EnumValueListComma?

// EnumValueListComma ::
//     , EnumValueListString?

// EnumValueListString ::
//     string EnumValueListComma?

// CallbackRest ::
//     identifier = Type ( ArgumentList? ) ;

// Typedef ::
//     typedef TypeWithExtendedAttributes identifier ;

// Type ::
//     SingleType
//     UnionType Null?

// TypeWithExtendedAttributes ::
//     ExtendedAttributeList? Type

// SingleType ::
//     DistinguishableType
//     any
//     PromiseType

// UnionType ::
//     ( UnionMemberType (or UnionMemberType)* )

// UnionMemberType ::
//     ExtendedAttributeList? DistinguishableType
//     UnionType Null?

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

// PrimitiveType ::
//     UnsignedIntegerType
//     UnrestrictedFloatType
//     boolean
//     byte
//     octet
//     bigint

// UnrestrictedFloatType ::
//     unrestricted FloatType
//     FloatType

// FloatType ::
//     float
//     double

// UnsignedIntegerType ::
//     unsigned IntegerType
//     IntegerType

// IntegerType ::
//     short
//     long OptionalLong?
// OptionalLong ::
//     long

// StringType ::
//     ByteString
//     DOMString
//     USVString

// PromiseType ::
//     Promise < Type >

// RecordType ::
//     record < StringType , TypeWithExtendedAttributes >

// Null? ::
//     ?

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

// ExtendedAttributeList ::
//     [ ExtendedAttribute (, ExtendedAttribute)* ]

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

// IdentifierList ::
//     identifier (, identifier)*

// ExtendedAttributeNoArgs ::
//     identifier

// ExtendedAttributeArgList ::
//     identifier ( ArgumentList? )

// ExtendedAttributeIdent ::
//     identifier = identifier

// ExtendedAttributeWildcard ::
//     identifier = *

// ExtendedAttributeIdentList ::
//     identifier = ( IdentifierList )

// ExtendedAttributeNamedArgList ::
//     identifier = identifier ( ArgumentList? )

//
//

// integer     =  -?([1-9][0-9]*|0[Xx][0-9A-Fa-f]+|0[0-7]*)

// decimal     =  -?(([0-9]+\.[0-9]*|[0-9]*\.[0-9]+)([Ee][+-]?[0-9]+)?|[0-9]+[Ee][+-]?[0-9]+)

// identifier  =  [_-]?[A-Za-z][0-9A-Z_a-z-]*

// string      =  "[^"]*"

// whitespace  =  [\t\n\r ]+

// comment     =  \/\/.*|\/\*(.|\n)*?\*\/

// other       =  [^\t\n\r 0-9A-Za-z]
