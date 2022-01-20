﻿unit Delphi.ORM.Mapper;

interface

uses System.TypInfo, System.Rtti, System.Generics.Collections, System.Generics.Defaults, System.SysUtils, Delphi.ORM.Attributes;

type
  TField = class;
  TForeignKey = class;
  TManyValueAssociation = class;
  TMapper = class;
  TTable = class;

  EClassWithoutPrimaryKeyDefined = class(Exception)
  public
    constructor Create(Table: TTable);
  end;

  EClassWithPrimaryKeyNullable = class(Exception)
  public
    constructor Create(Table: TTable);
  end;

  EInvalidEnumeratorName = class(Exception)
  public
    constructor Create(Enumeration: TRttiEnumerationType; EnumeratorValue: String);
  end;

  EManyValueAssociationLinkError = class(Exception)
  public
    constructor Create(ParentTable, ChildTable: TTable);
  end;

  ETableNotFound = class(Exception)
  public
    constructor Create(TheClass: TClass);
  end;

  ECanSetValueForFieldPrimaryKeyReference = class(Exception)
  public
    constructor Create;
  end;

  TTable = class
  private
    FBaseTable: TTable;
    FClassTypeInfo: TRttiInstanceType;
    FDatabaseName: String;
    FFields: TArray<TField>;
    FForeignKeys: TArray<TForeignKey>;
    FIsSingleTableInheritance: Boolean;
    FManyValueAssociations: TArray<TManyValueAssociation>;
    FMapper: TMapper;
    FName: String;
    FPrimaryKey: TField;
  public
    constructor Create(TypeInfo: TRttiInstanceType);

    destructor Destroy; override;

    function FindField(const FieldName: String; var Field: TField): Boolean;
    function GetCacheKey(const Instance: TObject): String; overload;
    function GetCacheKey(const PrimaryKeyValue: Variant): String; overload;

    property BaseTable: TTable read FBaseTable;
    property ClassTypeInfo: TRttiInstanceType read FClassTypeInfo;
    property DatabaseName: String read FDatabaseName;
    property Fields: TArray<TField> read FFields;
    property ForeignKeys: TArray<TForeignKey> read FForeignKeys;
    property IsSingleTableInheritance: Boolean read FIsSingleTableInheritance;
    property ManyValueAssociations: TArray<TManyValueAssociation> read FManyValueAssociations;
    property Mapper: TMapper read FMapper;
    property Name: String read FName write FName;
    property PrimaryKey: TField read FPrimaryKey;
  end;

  TField = class
  private
    FAutoGenerated: Boolean;
    FDatabaseName: String;
    FDefaultValue: TValue;
    FFieldType: TRttiType;
    FForeignKey: TForeignKey;
    FInPrimaryKey: Boolean;
    FIsForeignKey: Boolean;
    FIsJoinLink: Boolean;
    FIsLazy: Boolean;
    FIsManyValueAssociation: Boolean;
    FIsNullable: Boolean;
    FName: String;
    FTable: TTable;
    FPropertyInfo: TRttiInstanceProperty;
    FReadOnly: Boolean;
  public
    function ConvertVariant(const Value: Variant): TValue;
    function GetAsString(const Instance: TObject): String; overload;
    function GetAsString(const Value: TValue): String; overload;
    function GetValue(const Instance: TObject): TValue; virtual;

    procedure SetValue(const Instance: TObject; const Value: TValue); overload; virtual;
    procedure SetValue(const Instance: TObject; const Value: Variant); overload;

    property AutoGenerated: Boolean read FAutoGenerated;
    property DatabaseName: String read FDatabaseName;
    property DefaultValue: TValue read FDefaultValue;
    property FieldType: TRttiType read FFieldType;
    property ForeignKey: TForeignKey read FForeignKey;
    property InPrimaryKey: Boolean read FInPrimaryKey;
    property IsForeignKey: Boolean read FIsForeignKey;
    property IsJoinLink: Boolean read FIsJoinLink;
    property IsLazy: Boolean read FIsLazy;
    property IsManyValueAssociation: Boolean read FIsManyValueAssociation;
    property IsNullable: Boolean read FIsNullable;
    property Name: String read FName;
    property PropertyInfo: TRttiInstanceProperty read FPropertyInfo;
    property ReadOnly: Boolean read FReadOnly;
    property Table: TTable read FTable;
  end;

  TFieldPrimaryKeyReference = class(TField)
  public
    constructor Create;

    function GetValue(const Instance: TObject): TValue; override;

    procedure SetValue(const Instance: TObject; const Value: TValue); override;
  end;

  TFieldAlias = record
  private
    FTableAlias: String;
    FField: TField;
  public
    constructor Create(TableAlias: String; Field: TField);

    property Field: TField read FField write FField;
    property TableAlias: String read FTableAlias write FTableAlias;
  end;

  TForeignKey = class
  private
    FParentTable: TTable;
    FField: TField;
    FManyValueAssociation: TManyValueAssociation;
    FIsInheritedLink: Boolean;
    FCascade: TCascadeTypes;
  public
    property Cascade: TCascadeTypes read FCascade;
    property Field: TField read FField;
    property IsInheritedLink: Boolean read FIsInheritedLink;
    property ManyValueAssociation: TManyValueAssociation read FManyValueAssociation;
    property ParentTable: TTable read FParentTable;
  end;

  TManyValueAssociation = class
  private
    FChildTable: TTable;
    FField: TField;
    FForeignKey: TForeignKey;
  public
    constructor Create(Field: TField; ChildTable: TTable; ForeignKey: TForeignKey);

    property ChildTable: TTable read FChildTable;
    property Field: TField read FField write FField;
    property ForeignKey: TForeignKey read FForeignKey;
  end;

  TMapper = class
  private
    class var [Unsafe] FDefault: TMapper;

    class constructor Create;
    class destructor Destroy;
  private
    FContext: TRttiContext;
    FTables: TDictionary<TRttiInstanceType, TTable>;
    FLateLoadTables: TList<TTable>;

    function CheckAttribute<T: TCustomAttribute>(TypeInfo: TRttiType): Boolean;
    function GetDefaultValue(AProperty: TRttiProperty): TValue;
    function GetFieldDatabaseName(Field: TField): String;
    function GetNameAttribute<T: TCustomNameAttribute>(TypeInfo: TRttiNamedObject; var Name: String): Boolean;
    function GetManyValuAssociationLinkName(Field: TField): String;
    function GetPrimaryKeyPropertyName(TypeInfo: TRttiInstanceType): String;
    function GetTableDatabaseName(Table: TTable): String;
    function GetTables: TArray<TTable>;
    function IsSingleTableInheritance(RttiType: TRttiType): Boolean;
    function LoadClassInTable(TypeInfo: TRttiInstanceType): TTable;
    function LoadTable(TypeInfo: TRttiInstanceType): TTable;

    procedure AddTableForeignKey(const Table: TTable; const Field: TField; const ForeignTable: TTable; const IsInheritedLink: Boolean); overload;
    procedure AddTableForeignKey(const Table: TTable; const Field: TField; const ClassInfoType: TRttiInstanceType); overload;
    procedure LoadFieldInfo(const Table: TTable; const PropertyInfo: TRttiInstanceProperty; const Field: TField);
    procedure LoadTableFields(TypeInfo: TRttiInstanceType; const Table: TTable);
    procedure LoadTableForeignKeys(const Table: TTable);
    procedure LoadTableInfo(TypeInfo: TRttiInstanceType; const Table: TTable);
    procedure LoadTableManyValueAssociations(Table: TTable);
  public
    constructor Create;

    destructor Destroy; override;

    function FindTable(ClassInfo: PTypeInfo): TTable; overload;
    function FindTable(ClassInfo: TClass): TTable; overload;
    function LoadClass(ClassInfo: TClass): TTable;
    function TryFindTable(ClassInfo: PTypeInfo; var Table: TTable): Boolean;

    procedure LoadAll;

    property Tables: TArray<TTable> read GetTables;

    class property Default: TMapper read FDefault;
  end;

implementation

uses System.Variants, Delphi.ORM.Rtti.Helper, Delphi.ORM.Nullable, Delphi.ORM.Lazy, Delphi.ORM.Cache;

function SortFieldFunction(const Left, Right: TField): Integer;

  function FieldPriority(const Field: TField): Integer;
  begin
    if Field.InPrimaryKey then
      Result := 1
    else if Field.IsLazy then
      Result := 2
    else if Field.IsForeignKey then
      Result := 3
    else if Field.IsManyValueAssociation then
      Result := 4
    else
      Result := 2;
  end;

begin
  Result := FieldPriority(Left) - FieldPriority(Right);

  if Result = 0 then
    Result := CompareStr(Left.DatabaseName, Right.DatabaseName);
end;

function CreateFieldComparer: IComparer<TField>;
begin
  Result := TDelegatedComparer<TField>.Create(SortFieldFunction);
end;

{ TMapper }

procedure TMapper.AddTableForeignKey(const Table: TTable; const Field: TField; const ClassInfoType: TRttiInstanceType);
begin
  AddTableForeignKey(Table, Field, LoadTable(ClassInfoType), False);
end;

procedure TMapper.AddTableForeignKey(const Table: TTable; const Field: TField; const ForeignTable: TTable; const IsInheritedLink: Boolean);
begin
  if Assigned(ForeignTable.PrimaryKey) then
  begin
    var ForeignKey := TForeignKey.Create;
    ForeignKey.FField := Field;
    ForeignKey.FIsInheritedLink := IsInheritedLink;
    ForeignKey.FParentTable := ForeignTable;

    Field.FForeignKey := ForeignKey;
    Table.FForeignKeys := Table.FForeignKeys + [ForeignKey];

    if IsInheritedLink or Field.PropertyInfo.HasAttribute<InsertCascadeAttribute> then
      ForeignKey.FCascade := ForeignKey.FCascade + [ctInsert];

    if IsInheritedLink or Field.PropertyInfo.HasAttribute<UpdateCascadeAttribute> then
      ForeignKey.FCascade := ForeignKey.FCascade + [ctUpdate];
  end
  else
    raise EClassWithoutPrimaryKeyDefined.Create(ForeignTable);
end;

function TMapper.CheckAttribute<T>(TypeInfo: TRttiType): Boolean;
begin
  Result := False;

  for var TypeToCompare in TypeInfo.GetAttributes do
    if TypeToCompare is T then
      Exit(True);
end;

class constructor TMapper.Create;
begin
  FDefault := TMapper.Create;
end;

constructor TMapper.Create;
begin
  inherited;

  FContext := TRttiContext.Create;
  FLateLoadTables := TList<TTable>.Create;
  FTables := TObjectDictionary<TRttiInstanceType, TTable>.Create([doOwnsValues]);
end;

destructor TMapper.Destroy;
begin
  FLateLoadTables.Free;

  FTables.Free;

  FContext.Free;

  inherited;
end;

function TMapper.FindTable(ClassInfo: PTypeInfo): TTable;
begin
  if not TryFindTable(ClassInfo, Result) then
    raise ETableNotFound.Create(ClassInfo.TypeData.ClassType);
end;

function TMapper.FindTable(ClassInfo: TClass): TTable;
begin
  Result := FindTable(ClassInfo.ClassInfo);
end;

function TMapper.GetDefaultValue(AProperty: TRttiProperty): TValue;
begin
  var Attribute := AProperty.GetAttribute<DefaultValueAttribute>;

  if Assigned(Attribute) then
    case AProperty.PropertyType.TypeKind of
      tkChar,
      tkLString,
      tkString,
      tkUString,
      tkWChar,
      tkWString: Result := Attribute.Value;

      tkEnumeration:
      begin
        var EnumType := TRttiEnumerationType(AProperty.PropertyType);
        var Names := EnumType.GetNames;

        for var A := Low(Names) to High(Names) do
          if Names[A] = Attribute.Value then
            Exit(TValue.FromOrdinal(AProperty.PropertyType.Handle, A));

        raise EInvalidEnumeratorName.Create(EnumType, Attribute.Value);
      end;

      tkFloat:
      begin
        if AProperty.PropertyType.Handle = System.TypeInfo(TDate) then
          Result := StrToDate(Attribute.Value, TFormatSettings.Invariant)
        else if AProperty.PropertyType.Handle = System.TypeInfo(TTime) then
          Result := StrToTime(Attribute.Value, TFormatSettings.Invariant)
        else if AProperty.PropertyType.Handle = System.TypeInfo(TDateTime) then
          Result := StrToDateTime(Attribute.Value, TFormatSettings.Invariant)
        else
          Result := StrToFloat(Attribute.Value, TFormatSettings.Invariant)
      end;

      tkInteger,
      tkInt64: Result := StrToInt(Attribute.Value);
    end
  else
    Result := TValue.Empty;
end;

function TMapper.GetFieldDatabaseName(Field: TField): String;
begin
  if not GetNameAttribute<FieldNameAttribute>(Field.PropertyInfo, Result) then
  begin
    Result := Field.Name;

    if Field.IsForeignKey then
      Result := 'Id' + Result;
  end;
end;

function TMapper.GetManyValuAssociationLinkName(Field: TField): String;
begin
  if not GetNameAttribute<ManyValueAssociationLinkNameAttribute>(Field.PropertyInfo, Result) then
    Result := Field.Table.Name;
end;

function TMapper.GetNameAttribute<T>(TypeInfo: TRttiNamedObject; var Name: String): Boolean;
begin
  var Attribute := TypeInfo.GetAttribute<T>;
  Result := Assigned(Attribute);

  if Result then
    Name := Attribute.Name;
end;

function TMapper.GetPrimaryKeyPropertyName(TypeInfo: TRttiInstanceType): String;
begin
  var Attribute := TypeInfo.GetAttribute<PrimaryKeyAttribute>;

  if Assigned(Attribute) then
    Result := Attribute.Name
  else
    Result := 'Id';
end;

function TMapper.GetTableDatabaseName(Table: TTable): String;
begin
  if not GetNameAttribute<TableNameAttribute>(Table.ClassTypeInfo, Result) then
    Result := Table.Name;
end;

function TMapper.GetTables: TArray<TTable>;
begin
  Result := FTables.Values.ToArray;
end;

function TMapper.IsSingleTableInheritance(RttiType: TRttiType): Boolean;
begin
  Result := RttiType.GetAttribute<SingleTableInheritanceAttribute> <> nil;
end;

class destructor TMapper.Destroy;
begin
  FDefault.Free;
end;

procedure TMapper.LoadAll;
begin
  FTables.Clear;

  for var TypeInfo in FContext.GetTypes do
    if CheckAttribute<EntityAttribute>(TypeInfo) then
      LoadClassInTable(TypeInfo.AsInstance);
end;

function TMapper.LoadClass(ClassInfo: TClass): TTable;
begin
  Result := LoadClassInTable(FContext.GetType(ClassInfo).AsInstance);
end;

function TMapper.LoadClassInTable(TypeInfo: TRttiInstanceType): TTable;
begin
  Result := LoadTable(TypeInfo);

  for var Table in FLateLoadTables do
    LoadTableManyValueAssociations(Table);

  FLateLoadTables.Clear;
end;

procedure TMapper.LoadFieldInfo(const Table: TTable; const PropertyInfo: TRttiInstanceProperty; const Field: TField);
begin
  Field.FAutoGenerated := PropertyInfo.GetAttribute<AutoGeneratedAttribute> <> nil;
  Field.FFieldType := PropertyInfo.PropertyType;
  Field.FName := PropertyInfo.Name;
  Field.FPropertyInfo := PropertyInfo;
  Field.FTable := Table;
  Table.FFields := Table.FFields + [Field];

  Field.FDefaultValue := GetDefaultValue(PropertyInfo);
  Field.FIsLazy := IsLazyLoading(Field.FieldType);
  Field.FIsManyValueAssociation := Field.FieldType.IsArray;
  Field.FIsNullable := Field.FieldType.IsRecord and IsNullableType(Field.FieldType);

  Field.FIsForeignKey := Field.FieldType.IsInstance or Field.IsLazy;
  Field.FIsJoinLink := Field.IsForeignKey or Field.IsManyValueAssociation;

  if Field.IsNullable then
    Field.FFieldType := GetNullableRttiType(Field.FieldType)
  else if Field.IsLazy then
    Field.FFieldType := GetLazyLoadingRttiType(Field.FieldType);

  Field.FDatabaseName := GetFieldDatabaseName(Field);
end;

function TMapper.LoadTable(TypeInfo: TRttiInstanceType): TTable;
begin
  if not TryFindTable(TypeInfo.Handle, Result) and not IsSingleTableInheritance(TypeInfo) then
  begin
    Result := TTable.Create(TypeInfo);
    Result.FMapper := Self;
    Result.FName := TypeInfo.Name.Substring(1);

    Result.FDatabaseName := GetTableDatabaseName(Result);

    FTables.Add(TypeInfo, Result);

    FLateLoadTables.Add(Result);

    LoadTableInfo(TypeInfo, Result);
  end;
end;

procedure TMapper.LoadTableFields(TypeInfo: TRttiInstanceType; const Table: TTable);
begin
  var PrimaryKeyFieldName := GetPrimaryKeyPropertyName(TypeInfo);

  for var Prop in TypeInfo.GetDeclaredProperties do
    if Prop.Visibility = mvPublished then
      LoadFieldInfo(Table, Prop as TRttiInstanceProperty, TField.Create);

  for var Field in Table.Fields do
    if Field.Name = PrimaryKeyFieldName then
    begin
      Field.FInPrimaryKey := True;
      Table.FPrimaryKey := Field;

      if Field.IsNullable then
        raise EClassWithPrimaryKeyNullable.Create(Table);
    end;
end;

procedure TMapper.LoadTableForeignKeys(const Table: TTable);
begin
  for var Field in Table.Fields do
    if Field.IsForeignKey then
      AddTableForeignKey(Table, Field, Field.FieldType.AsInstance);
end;

procedure TMapper.LoadTableInfo(TypeInfo: TRttiInstanceType; const Table: TTable);
begin
  var BaseClass := TypeInfo.BaseType;
  Table.FIsSingleTableInheritance := IsSingleTableInheritance(BaseClass);

  if not Table.IsSingleTableInheritance and (BaseClass.MetaclassType <> TObject) then
    Table.FBaseTable := LoadClassInTable(BaseClass);

  LoadTableFields(TypeInfo, Table);

  if Table.IsSingleTableInheritance then
    LoadTableFields(Table.ClassTypeInfo.BaseType, Table);

  if Assigned(Table.BaseTable) then
  begin
    var Field := TFieldPrimaryKeyReference.Create;

    LoadFieldInfo(Table, Table.BaseTable.PrimaryKey.PropertyInfo, Field);

    Field.FAutoGenerated := False;
    Field.FFieldType := Table.BaseTable.ClassTypeInfo;
    Table.FPrimaryKey := Table.BaseTable.PrimaryKey;

    AddTableForeignKey(Table, Field, Table.BaseTable, True);
  end;

  TArray.Sort<TField>(Table.FFields, CreateFieldComparer);

  LoadTableForeignKeys(Table);
end;

procedure TMapper.LoadTableManyValueAssociations(Table: TTable);
begin
  for var Field in Table.Fields do
    if Field.IsManyValueAssociation then
    begin
      var ChildTable := LoadTable(Field.FieldType.AsArray.ElementType.AsInstance);
      var LinkName := GetManyValuAssociationLinkName(Field);
      var ManyValueAssociation: TManyValueAssociation := nil;

      for var ForeignKey in ChildTable.ForeignKeys do
        if (ForeignKey.ParentTable = Table) and (ForeignKey.Field.Name = LinkName) then
          ManyValueAssociation := TManyValueAssociation.Create(Field, ChildTable, ForeignKey);

      if Assigned(ManyValueAssociation) then
        Table.FManyValueAssociations := Table.FManyValueAssociations + [ManyValueAssociation]
      else
        raise EManyValueAssociationLinkError.Create(Table, ChildTable);
    end;
end;

function TMapper.TryFindTable(ClassInfo: PTypeInfo; var Table: TTable): Boolean;
begin
  Result := FTables.TryGetValue(FContext.GetType(ClassInfo).AsInstance, Table);
end;

{ TTable }

constructor TTable.Create(TypeInfo: TRttiInstanceType);
begin
  inherited Create;

  FClassTypeInfo := TypeInfo;
end;

destructor TTable.Destroy;
begin
  for var Field in Fields do
    Field.Free;

  for var ForeignKey in ForeignKeys do
    ForeignKey.Free;

  for var ManyValueAssociation in ManyValueAssociations do
    ManyValueAssociation.Free;

  inherited;
end;

function TTable.FindField(const FieldName: String; var Field: TField): Boolean;
begin
  Result := False;

  for var TableField in Fields do
    if TableField.Name = FieldName then
    begin
      Field := TableField;

      Exit(True);
    end;
end;

function TTable.GetCacheKey(const PrimaryKeyValue: Variant): String;
begin
  var KeyValue: TValue;

  if Assigned(PrimaryKey) then
    KeyValue := PrimaryKey.ConvertVariant(PrimaryKeyValue)
  else
    KeyValue := EmptyStr;

  Result := TCache.GenerateKey(ClassTypeInfo, KeyValue);
end;

function TTable.GetCacheKey(const Instance: TObject): String;
begin
  var KeyValue: TValue;

  if Assigned(PrimaryKey) then
    KeyValue := PrimaryKey.GetValue(Instance)
  else
    KeyValue := EmptyStr;

  Result := TCache.GenerateKey(Instance.ClassType, KeyValue);
end;

{ TFieldAlias }

constructor TFieldAlias.Create(TableAlias: String; Field: TField);
begin
  FField := Field;
  FTableAlias := TableAlias;
end;

{ TManyValueAssociation }

constructor TManyValueAssociation.Create(Field: TField; ChildTable: TTable; ForeignKey: TForeignKey);
begin
  inherited Create;

  FChildTable := ChildTable;
  FField := Field;
  FForeignKey := ForeignKey;
  FForeignKey.FManyValueAssociation := Self;
end;

{ TField }

function TField.GetAsString(const Instance: TObject): String;
begin
  Result := GetAsString(GetValue(Instance));
end;

function TField.ConvertVariant(const Value: Variant): TValue;
begin
  if VarIsNull(Value) then
    Result := TValue.Empty
  else if FieldType is TRttiEnumerationType then
    Result := TValue.FromOrdinal(FieldType.Handle, Value)
  else if FieldType.Handle = System.TypeInfo(TGUID) then
    Result := TValue.From(StringToGuid(Value))
  else
    Result := TValue.FromVariant(Value);
end;

function TField.GetAsString(const Value: TValue): String;
begin
  if Value.IsEmpty then
    Result := 'null'
  else
    case FieldType.TypeKind of
      tkChar,
      tkLString,
      tkRecord,
      tkString,
      tkUString,
      tkWChar,
      tkWString: Result := QuotedStr(Value.GetAsString);

      tkClass:
      begin
        var PrimaryKey := Table.Mapper.FindTable(FieldType.AsInstance.MetaclassType).PrimaryKey;

        if Value.Kind = tkClass then
          Result := PrimaryKey.GetAsString(Value.AsObject)
        else
          Result := PrimaryKey.GetAsString(Value);
      end;

      tkFloat:
      begin
        if FieldType.Handle = System.TypeInfo(TDate) then
          Result := QuotedStr(DateToStr(Value.AsExtended, TValue.FormatSettings))
        else if FieldType.Handle = System.TypeInfo(TDateTime) then
          Result := QuotedStr(DateTimeToStr(Value.AsExtended, TValue.FormatSettings))
        else if FieldType.Handle = System.TypeInfo(TTime) then
          Result := QuotedStr(TimeToStr(Value.AsExtended, TValue.FormatSettings))
        else
          Result := FloatToStr(Value.AsExtended, TValue.FormatSettings);
      end;

      tkEnumeration,
      tkInteger,
      tkInt64:
        Result := Value.GetAsString;

      else raise Exception.Create('Type not mapped!');
    end;
end;

function TField.GetValue(const Instance: TObject): TValue;
begin
  Result := PropertyInfo.GetValue(Instance);

  if IsNullable then
    Result := GetNullableAccess(Result).GetValue
  else if IsLazy then
  begin
    var LazyAccess := GetLazyLoadingAccess(Result);

    if LazyAccess.Loaded then
      Result := LazyAccess.GetValue
    else
      Result := LazyAccess.GetKey;
  end;
end;

procedure TField.SetValue(const Instance: TObject; const Value: TValue);
begin
  if IsNullable then
    GetNullableAccess(PropertyInfo.GetValue(Instance)).SetValue(Value)
  else if IsLazy then
  begin
    var LazyAccess := GetLazyLoadingAccess(PropertyInfo.GetValue(Instance));

    LazyAccess.SetValue(Value);
  end
  else
    PropertyInfo.SetValue(Instance, Value);
end;

procedure TField.SetValue(const Instance: TObject; const Value: Variant);
begin
  SetValue(Instance, ConvertVariant(Value));
end;

{ EManyValueAssociationLinkError }

constructor EManyValueAssociationLinkError.Create(ParentTable, ChildTable: TTable);
begin
  inherited CreateFmt('The link between %s and %s can''t be maded. Check if it exists, as the same name of the parent table or has the attribute defining the name of the link!',
    [ParentTable.ClassTypeInfo.Name, ChildTable.ClassTypeInfo.Name]);
end;

{ EClassWithPrimaryKeyNullable }

constructor EClassWithPrimaryKeyNullable.Create(Table: TTable);
begin
  inherited CreateFmt('The primary key of the class %s is nullable, it''s not accepted!', [Table.ClassTypeInfo.Name]);
end;

{ EInvalidEnumeratorName }

constructor EInvalidEnumeratorName.Create(Enumeration: TRttiEnumerationType; EnumeratorValue: String);
begin
  inherited CreateFmt('Enumerator name ''%s'' is invalid to the enumeration ''%s''', [EnumeratorValue, Enumeration.Name]);
end;

{ ETableNotFound }

constructor ETableNotFound.Create(TheClass: TClass);
begin
  inherited CreateFmt('The class %s not found!', [TheClass.ClassName])
end;

{ EClassWithoutPrimaryKeyDefined }

constructor EClassWithoutPrimaryKeyDefined.Create(Table: TTable);
begin
  inherited CreateFmt('You must define a primary key for class %s!', [Table.ClassTypeInfo.Name])
end;

{ TFieldPrimaryKeyReference }

constructor TFieldPrimaryKeyReference.Create;
begin
  inherited;

  FReadOnly := True;
end;

function TFieldPrimaryKeyReference.GetValue(const Instance: TObject): TValue;
begin
  Result := TValue.From(Instance).Cast(Instance.ClassParent.ClassInfo, False);
end;

procedure TFieldPrimaryKeyReference.SetValue(const Instance: TObject; const Value: TValue);
begin
  raise ECanSetValueForFieldPrimaryKeyReference.Create;
end;

{ ECanSetValueForFieldPrimaryKeyReference }

constructor ECanSetValueForFieldPrimaryKeyReference.Create;
begin
  inherited Create('Can''t set value for the primary key reference field!');
end;

end.

