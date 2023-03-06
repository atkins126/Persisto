﻿unit Delphi.ORM.Mapper;

interface

uses System.TypInfo, System.Rtti, System.Generics.Collections, System.Generics.Defaults, System.SysUtils, Delphi.ORM.Attributes, Delphi.ORM.Lazy;

type
  TField = class;
  TForeignKey = class;
  TIndex = class;
  TManyValueAssociation = class;
  TMapper = class;
  TTable = class;

  EChildTableMustHasToHaveAPrimaryKey = class(Exception)
  public
    constructor Create(ChildTable: TTable);
  end;

  EClassWithoutPrimaryKeyDefined = class(Exception)
  public
    constructor Create(Table: TTable);
  end;

  EClassWithPrimaryKeyNullable = class(Exception)
  public
    constructor Create(Table: TTable);
  end;

  EFieldIndexNotFound = class(Exception)
  public
    constructor Create(const Table: TTable; const FieldName: String);
  end;

  EForeignKeyToSingleTableInheritanceTable = class(Exception)
  public
    constructor Create(ParentTable: TRttiInstanceType);
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

  TTableObject = class
  private
    FTable: TTable;
  public
    constructor Create(const Table: TTable);

    property Table: TTable read FTable;
  end;

  TTable = class
  private
    FBaseTable: TTable;
    FClassTypeInfo: TRttiInstanceType;
    FDatabaseName: String;
    FFields: TArray<TField>;
    FForeignKeys: TArray<TForeignKey>;
    FIndexes: TArray<TIndex>;
    FManyValueAssociations: TArray<TManyValueAssociation>;
    FMapper: TMapper;
    FName: String;
    FPrimaryKey: TField;

    function GetField(const FieldName: String): TField;
  public
    constructor Create(TypeInfo: TRttiInstanceType);

    destructor Destroy; override;

    function FindField(const FieldName: String; var Field: TField): Boolean;
    function GetCacheKey(const Instance: TObject): String; overload;
    function GetCacheKey(const PrimaryKeyValue: Variant): String; overload;

    property BaseTable: TTable read FBaseTable;
    property ClassTypeInfo: TRttiInstanceType read FClassTypeInfo;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property Field[const FieldName: String]: TField read GetField; default;
    property Fields: TArray<TField> read FFields write FFields;
    property ForeignKeys: TArray<TForeignKey> read FForeignKeys;
    property Indexes: TArray<TIndex> read FIndexes;
    property ManyValueAssociations: TArray<TManyValueAssociation> read FManyValueAssociations;
    property Mapper: TMapper read FMapper;
    property Name: String read FName write FName;
    property PrimaryKey: TField read FPrimaryKey;
  end;

  TDefaultConstraint = class
  private
    FAutoGeneratedType: TAutoGeneratedType;
    FSequenceName: String;
    FFixedValue: String;
  public
    property AutoGeneratedType: TAutoGeneratedType read FAutoGeneratedType write FAutoGeneratedType;
    property FixedValue: String read FFixedValue write FFixedValue;
    property SequenceName: String read FSequenceName write FSequenceName;
  end;

  TField = class(TTableObject)
  private
    FCollation: String;
    FDatabaseName: String;
    FDefaultConstraint: TDefaultConstraint;
    FFieldType: TRttiType;
    FForeignKey: TForeignKey;
    FInPrimaryKey: Boolean;
    FIsForeignKey: Boolean;
    FIsJoinLink: Boolean;
    FIsLazy: Boolean;
    FIsManyValueAssociation: Boolean;
    FIsNullable: Boolean;
    FIsReadOnly: Boolean;
    FManyValueAssociation: TManyValueAssociation;
    FName: String;
    FPropertyInfo: TRttiInstanceProperty;
    FRequired: Boolean;
    FScale: Word;
    FSize: Word;
    FSpecialType: TDatabaseSpecialType;

    function GetAutoGenerated: Boolean;
  public
    destructor Destroy; override;

    function ConvertVariant(const Value: Variant): TValue;
    function GetAsString(const Instance: TObject): String; overload;
    function GetAsString(const Value: TValue): String; overload;
    function GetPropertyValue(const Instance: TObject): TValue;
    function GetValue(const Instance: TObject): TValue; virtual;
    function HasValue(const Instance: TObject; var Value: TValue): Boolean;

    procedure SetValue(const Instance: TObject; const Value: TValue); overload; virtual;
    procedure SetValue(const Instance: TObject; const Value: Variant); overload;

    property AutoGenerated: Boolean read GetAutoGenerated;
    property Collation: String read FCollation write FCollation;
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property DefaultConstraint: TDefaultConstraint read FDefaultConstraint write FDefaultConstraint;
    property FieldType: TRttiType read FFieldType write FFieldType;
    property ForeignKey: TForeignKey read FForeignKey write FForeignKey;
    property InPrimaryKey: Boolean read FInPrimaryKey;
    property IsForeignKey: Boolean read FIsForeignKey write FIsForeignKey;
    property IsJoinLink: Boolean read FIsJoinLink;
    property IsLazy: Boolean read FIsLazy;
    property IsManyValueAssociation: Boolean read FIsManyValueAssociation;
    property IsReadOnly: Boolean read FIsReadOnly;
    property ManyValueAssociation: TManyValueAssociation read FManyValueAssociation;
    property Name: String read FName write FName;
    property PropertyInfo: TRttiInstanceProperty read FPropertyInfo;
    property Required: Boolean read FRequired write FRequired;
    property Scale: Word read FScale write FScale;
    property Size: Word read FSize write FSize;
    property SpecialType: TDatabaseSpecialType read FSpecialType write FSpecialType;
  end;

  TFieldAlias = record
  private
    FField: TField;
    FTableAlias: String;
  public
    constructor Create(TableAlias: String; Field: TField);

    property Field: TField read FField write FField;
    property TableAlias: String read FTableAlias write FTableAlias;
  end;

  TForeignKey = class(TTableObject)
  private
    FDatabaseName: String;
    FField: TField;
    FIsInheritedLink: Boolean;
    FManyValueAssociation: TManyValueAssociation;
    FParentTable: TTable;
  public
    property DatabaseName: String read FDatabaseName;
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
    constructor Create(const Field: TField; const ChildTable: TTable; const ForeignKey: TForeignKey);

    property ChildTable: TTable read FChildTable;
    property Field: TField read FField write FField;
    property ForeignKey: TForeignKey read FForeignKey;
  end;

  TIndex = class(TTableObject)
  private
    FDatabaseName: String;
    FFields: TArray<TField>;
    FPrimaryKey: Boolean;
    FUnique: Boolean;
  public
    property DatabaseName: String read FDatabaseName write FDatabaseName;
    property Fields: TArray<TField> read FFields write FFields;
    property PrimaryKey: Boolean read FPrimaryKey write FPrimaryKey;
    property Unique: Boolean read FUnique write FUnique;
  end;

  TMapper = class
  private
    class var [Unsafe] FDefault: TMapper;

    class constructor Create;
    class destructor Destroy;
  private
    FContext: TRttiContext;
    FDefaultCollation: String;
    FDelayLoadTable: TList<TTable>;
    FSingleTableInheritanceClasses: TDictionary<TClass, Boolean>;
    FTables: TDictionary<TRttiInstanceType, TTable>;

    function CheckAttribute<T: TCustomAttribute>(const TypeInfo: TRttiType): Boolean;
    function CreateIndex(const Table: TTable; const Name: String): TIndex;
    function GetFieldDatabaseName(const Field: TField): String;
    function GetNameAttribute<T: TCustomNameAttribute>(const TypeInfo: TRttiNamedObject; var Name: String): Boolean;
    function GetManyValuAssociationLinkName(const Field: TField): String;
    function GetPrimaryKeyPropertyName(const TypeInfo: TRttiInstanceType): String;
    function GetSingleTableInheritanceClasses: TArray<TClass>;
    function GetTableDatabaseName(const Table: TTable): String;
    function GetTables: TArray<TTable>;
    function IsSingleTableInheritance(const RttiType: TRttiInstanceType): Boolean;
    function LoadTable(const TypeInfo: TRttiInstanceType): TTable;

    procedure AddTableForeignKey(const Table: TTable; const Field: TField; const ForeignTable: TTable; const IsInheritedLink: Boolean); overload;
    procedure AddTableForeignKey(const Table: TTable; const Field: TField; const ClassInfoType: TRttiInstanceType); overload;
    procedure LoadDefaultConstraint(const Field: TField);
    procedure LoadDelayedTables;
    procedure LoadFieldInfo(const Table: TTable; const PropertyInfo: TRttiInstanceProperty; const Field: TField);
    procedure LoadFieldTypeInfo(const Field: TField);
    procedure LoadTableFields(const TypeInfo: TRttiInstanceType; const Table: TTable);
    procedure LoadTableForeignKeys(const Table: TTable);
    procedure LoadTableIndexes(const TypeInfo: TRttiInstanceType; const Table: TTable);
    procedure LoadTableInfo(const TypeInfo: TRttiInstanceType; const Table: TTable);
    procedure LoadTableManyValueAssociations(const Table: TTable);
    procedure SetSingleTableInheritanceClasses(const Value: TArray<TClass>);
  public
    constructor Create;

    destructor Destroy; override;

    function FindTable(const ClassInfo: PTypeInfo): TTable; overload;
    function FindTable(const ClassInfo: TClass): TTable; overload;
    function LoadClass(const ClassInfo: TClass): TTable;
    function TryFindTable(const ClassInfo: PTypeInfo; var Table: TTable): Boolean;

    procedure LoadAll; overload;
    procedure LoadAll(const Schema: TArray<TClass>); overload;

    property DefaultCollation: String read FDefaultCollation write FDefaultCollation;
    property SingleTableInheritanceClasses: TArray<TClass> read GetSingleTableInheritanceClasses write SetSingleTableInheritanceClasses;
    property Tables: TArray<TTable> read GetTables;

    class property Default: TMapper read FDefault;
  end;

implementation

uses System.Variants, Delphi.ORM.Rtti.Helper, Delphi.ORM.Nullable, Delphi.ORM.Cache, Delphi.ORM.Lazy.Manipulator, Delphi.ORM.Nullable.Manipulator;

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
  var ParentTable := LoadTable(ClassInfoType);

  if Assigned(ParentTable) then
    AddTableForeignKey(Table, Field, ParentTable, False)
  else
    raise EForeignKeyToSingleTableInheritanceTable.Create(ClassInfoType);
end;

procedure TMapper.AddTableForeignKey(const Table: TTable; const Field: TField; const ForeignTable: TTable; const IsInheritedLink: Boolean);

  function GetForeignKeyName: String;
  begin
    if not GetNameAttribute<ForeignKeyNameAttribute>(Field.PropertyInfo, Result) then
      Result := Format('FK_%s_%s_%s', [Table.DatabaseName, ForeignTable.DatabaseName, Field.DatabaseName]);
  end;

begin
  if Assigned(ForeignTable.PrimaryKey) then
  begin
    var
    ForeignKey := TForeignKey.Create(Table);
    ForeignKey.FDatabaseName := GetForeignKeyName;
    ForeignKey.FField := Field;
    ForeignKey.FIsInheritedLink := IsInheritedLink;
    ForeignKey.FParentTable := ForeignTable;

    Field.FForeignKey := ForeignKey;
    Table.FForeignKeys := Table.FForeignKeys + [ForeignKey];

    LoadFieldTypeInfo(Field);
  end
  else
    raise EClassWithoutPrimaryKeyDefined.Create(ForeignTable);
end;

function TMapper.CheckAttribute<T>(const TypeInfo: TRttiType): Boolean;
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
  FDelayLoadTable := TList<TTable>.Create;
  FSingleTableInheritanceClasses := TDictionary<TClass, Boolean>.Create;
  FTables := TObjectDictionary<TRttiInstanceType, TTable>.Create([doOwnsValues]);
end;

function TMapper.CreateIndex(const Table: TTable; const Name: String): TIndex;
begin
  Result := TIndex.Create(Table);
  Result.DatabaseName := Name;

  Table.FIndexes := Table.Indexes + [Result];
end;

destructor TMapper.Destroy;
begin
  FContext.Free;

  FDelayLoadTable.Free;

  FSingleTableInheritanceClasses.Free;

  FTables.Free;

  inherited;
end;

function TMapper.FindTable(const ClassInfo: PTypeInfo): TTable;
begin
  if not TryFindTable(ClassInfo, Result) then
    raise ETableNotFound.Create(ClassInfo.TypeData.ClassType);
end;

function TMapper.FindTable(const ClassInfo: TClass): TTable;
begin
  Result := FindTable(ClassInfo.ClassInfo);
end;

function TMapper.GetFieldDatabaseName(const Field: TField): String;
begin
  if not GetNameAttribute<FieldNameAttribute>(Field.PropertyInfo, Result) then
  begin
    Result := Field.Name;

    if Field.IsForeignKey then
      Result := 'Id' + Result;
  end;
end;

function TMapper.GetManyValuAssociationLinkName(const Field: TField): String;
begin
  if not GetNameAttribute<ManyValueAssociationLinkNameAttribute>(Field.PropertyInfo, Result) then
    Result := Field.Table.Name;
end;

function TMapper.GetNameAttribute<T>(const TypeInfo: TRttiNamedObject; var Name: String): Boolean;
begin
  var Attribute := TypeInfo.GetAttribute<T>;
  Result := Assigned(Attribute);

  if Result then
    Name := Attribute.Name;
end;

function TMapper.GetPrimaryKeyPropertyName(const TypeInfo: TRttiInstanceType): String;
begin
  var Attribute := TypeInfo.GetAttribute<PrimaryKeyAttribute>;

  if Assigned(Attribute) then
    Result := Attribute.Name
  else
    Result := 'Id';
end;

function TMapper.GetSingleTableInheritanceClasses: TArray<TClass>;
begin
  Result := FSingleTableInheritanceClasses.Keys.ToArray;
end;

function TMapper.GetTableDatabaseName(const Table: TTable): String;
begin
  if not GetNameAttribute<TableNameAttribute>(Table.ClassTypeInfo, Result) then
    Result := Table.Name;
end;

function TMapper.GetTables: TArray<TTable>;
begin
  Result := FTables.Values.ToArray;
end;

function TMapper.IsSingleTableInheritance(const RttiType: TRttiInstanceType): Boolean;
begin
  Result := FSingleTableInheritanceClasses.ContainsKey(RttiType.MetaclassType);
end;

class destructor TMapper.Destroy;
begin
  FDefault.Free;
end;

procedure TMapper.LoadAll;
begin
  LoadAll(nil);
end;

procedure TMapper.LoadAll(const Schema: TArray<TClass>);
begin
  var SchemaList := EmptyStr;

  FTables.Clear;

  for var AClass in Schema do
    SchemaList := Format('%s;%s;', [SchemaList, AClass.UnitName]);

  for var TypeInfo in FContext.GetTypes do
    if CheckAttribute<EntityAttribute>(TypeInfo) and (SchemaList.IsEmpty or (SchemaList.IndexOf(Format(';%s;', [TypeInfo.AsInstance.DeclaringUnitName])) > -1)) then
      LoadTable(TypeInfo.AsInstance);

  LoadDelayedTables;
end;

function TMapper.LoadClass(const ClassInfo: TClass): TTable;
begin
  Result := LoadTable(FContext.GetType(ClassInfo).AsInstance);

  LoadDelayedTables;
end;

procedure TMapper.LoadDefaultConstraint(const Field: TField);
begin
  var Attribute := Field.PropertyInfo.GetAttribute<TAutoGeneratedAttribute>;

  if Assigned(Attribute) then
  begin
    Field.FDefaultConstraint := TDefaultConstraint.Create;
    Field.FDefaultConstraint.AutoGeneratedType := Attribute.&Type;

    if Attribute is SequenceAttribute then
      Field.FDefaultConstraint.SequenceName := SequenceAttribute(Attribute).Name;

    if Attribute is FixedValueAttribute then
      Field.FDefaultConstraint.FixedValue := FixedValueAttribute(Attribute).Value;
  end;
end;

procedure TMapper.LoadDelayedTables;
begin
  while FDelayLoadTable.Count > 0 do
    LoadTableManyValueAssociations(FDelayLoadTable.ExtractAt(0));
end;

procedure TMapper.LoadFieldInfo(const Table: TTable; const PropertyInfo: TRttiInstanceProperty; const Field: TField);
begin
  Field.FFieldType := PropertyInfo.PropertyType;
  Field.FIsReadOnly := not PropertyInfo.IsWritable;
  Field.FName := PropertyInfo.Name;
  Field.FPropertyInfo := PropertyInfo;
  Field.FTable := Table;
  Table.FFields := Table.FFields + [Field];

  Field.FIsLazy := TLazyManipulator.IsLazyLoading(Field.PropertyInfo);
  Field.FIsNullable := TNullableManipulator.IsNullable(Field.PropertyInfo);

  if Field.FIsNullable then
    Field.FFieldType := TNullableManipulator.GetNullableType(Field.PropertyInfo)
  else if Field.IsLazy then
    Field.FFieldType := TLazyManipulator.GetLazyLoadingType(Field.PropertyInfo);

  Field.FIsForeignKey := Field.FieldType.IsInstance;
  Field.FIsManyValueAssociation := Field.FieldType.IsArray;
  Field.FRequired := PropertyInfo.HasAttribute<RequiredAttribute> or not Field.FIsNullable and not(Field.FieldType.TypeKind in [tkClass]);

  Field.FDatabaseName := GetFieldDatabaseName(Field);
  Field.FIsJoinLink := Field.IsForeignKey or Field.IsManyValueAssociation;

  if not Field.IsForeignKey then
    LoadFieldTypeInfo(Field);

  LoadDefaultConstraint(Field);
end;

procedure TMapper.LoadFieldTypeInfo(const Field: TField);
begin
  if Field.IsForeignKey then
  begin
    Field.FFieldType := Field.ForeignKey.ParentTable.PrimaryKey.FieldType;
    Field.FScale := Field.ForeignKey.ParentTable.PrimaryKey.Scale;
    Field.FSize := Field.ForeignKey.ParentTable.PrimaryKey.Size;
    Field.FSpecialType := Field.ForeignKey.ParentTable.PrimaryKey.SpecialType;
  end
  else
  begin
    var FieldInfo := Field.PropertyInfo.GetAttribute<FieldInfoAttribute>;

    if Assigned(FieldInfo) then
    begin
      Field.FScale := FieldInfo.Scale;
      Field.FSize := FieldInfo.Size;
      Field.FSpecialType := FieldInfo.SpecialType;
    end
    else if Field.FieldType.Handle = TypeInfo(TDate) then
      Field.FSpecialType := stDate
    else if Field.FieldType.Handle = TypeInfo(TDateTime) then
      Field.FSpecialType := stDateTime
    else if Field.FieldType.Handle = TypeInfo(TTime) then
      Field.FSpecialType := stTime
    else if Field.FieldType.Handle = TypeInfo(Boolean) then
      Field.FSpecialType := stBoolean;
  end;
end;

function TMapper.LoadTable(const TypeInfo: TRttiInstanceType): TTable;
begin
  if not TryFindTable(TypeInfo.Handle, Result) and not IsSingleTableInheritance(TypeInfo) then
  begin
    Result := TTable.Create(TypeInfo);
    Result.FMapper := Self;
    Result.FName := TypeInfo.Name.Substring(1);

    Result.FDatabaseName := GetTableDatabaseName(Result);

    FTables.Add(TypeInfo, Result);

    FDelayLoadTable.Add(Result);

    LoadTableInfo(TypeInfo, Result);
  end;
end;

procedure TMapper.LoadTableFields(const TypeInfo: TRttiInstanceType; const Table: TTable);
begin
  var PrimaryKeyFieldName := GetPrimaryKeyPropertyName(TypeInfo);

  for var Prop in TypeInfo.GetDeclaredProperties do
    if Prop.Visibility = mvPublished then
      LoadFieldInfo(Table, Prop as TRttiInstanceProperty, TField.Create(Table));

  for var Field in Table.Fields do
    if Field.Name = PrimaryKeyFieldName then
    begin
      Field.FInPrimaryKey := True;

      if not Assigned(Table.FPrimaryKey) then
      begin
        var PrimaryKeyIndex := CreateIndex(Table, Format('PK_%s', [Table.DatabaseName]));
        PrimaryKeyIndex.Fields := [Field];
        PrimaryKeyIndex.PrimaryKey := True;
        PrimaryKeyIndex.Unique := True;
      end;

      Table.FPrimaryKey := Field;

      if Field.FIsNullable then
        raise EClassWithPrimaryKeyNullable.Create(Table);
    end;
end;

procedure TMapper.LoadTableForeignKeys(const Table: TTable);
begin
  for var Field in Table.Fields do
    if Field.IsForeignKey then
      AddTableForeignKey(Table, Field, Field.FieldType.AsInstance);
end;

procedure TMapper.LoadTableIndexes(const TypeInfo: TRttiInstanceType; const Table: TTable);
begin
  for var Attribute in TypeInfo.GetAttributes do
    if Attribute is IndexAttribute then
    begin
      var IndexInfo := IndexAttribute(Attribute);

      var Index := CreateIndex(Table, IndexInfo.Name);
      Index.Unique := Attribute is UniqueKeyAttribute;

      for var FieldName in IndexInfo.Fields.Split([';']) do
      begin
        var Field: TField;

        if not Table.FindField(FieldName, Field) then
          raise EFieldIndexNotFound.Create(Table, FieldName);

        Index.Fields := Index.Fields + [Field];
      end;
    end;
end;

procedure TMapper.LoadTableInfo(const TypeInfo: TRttiInstanceType; const Table: TTable);
begin
  var BaseClassInfo := TypeInfo.BaseType as TRttiInstanceType;
  var IsSingleTableInheritance := IsSingleTableInheritance(BaseClassInfo);

  if not IsSingleTableInheritance and (BaseClassInfo.MetaclassType <> TObject) then
    Table.FBaseTable := LoadTable(BaseClassInfo);

  LoadTableFields(TypeInfo, Table);

  if IsSingleTableInheritance then
    while Assigned(BaseClassInfo) do
    begin
      LoadTableFields(BaseClassInfo, Table);

      BaseClassInfo := BaseClassInfo.BaseType;
    end;

  if Assigned(Table.BaseTable) then
  begin
    var Field := TField.Create(Table);

    LoadFieldInfo(Table, Table.BaseTable.PrimaryKey.PropertyInfo, Field);

    Table.FPrimaryKey := Table.BaseTable.PrimaryKey;

    AddTableForeignKey(Table, Field, Table.BaseTable, True);
  end;

  TArray.Sort<TField>(Table.FFields, CreateFieldComparer);

  LoadTableForeignKeys(Table);

  LoadTableIndexes(TypeInfo, Table);
end;

procedure TMapper.LoadTableManyValueAssociations(const Table: TTable);
begin
  for var Field in Table.Fields do
    if Field.IsManyValueAssociation then
    begin
      var ChildTable := LoadTable(Field.FieldType.AsArray.ElementType.AsInstance);
      var LinkName := GetManyValuAssociationLinkName(Field);

      for var ForeignKey in ChildTable.ForeignKeys do
        if (ForeignKey.ParentTable = Table) and (ForeignKey.Field.Name = LinkName) then
          if Assigned(ChildTable.PrimaryKey) then
            Field.FManyValueAssociation := TManyValueAssociation.Create(Field, ChildTable, ForeignKey)
          else
            raise EChildTableMustHasToHaveAPrimaryKey.Create(ChildTable);

      if Assigned(Field.ManyValueAssociation) then
        Table.FManyValueAssociations := Table.FManyValueAssociations + [Field.ManyValueAssociation]
      else
        raise EManyValueAssociationLinkError.Create(Table, ChildTable);
    end;
end;

procedure TMapper.SetSingleTableInheritanceClasses(const Value: TArray<TClass>);
begin
  for var AValue in Value do
    FSingleTableInheritanceClasses.Add(AValue, True);
end;

function TMapper.TryFindTable(const ClassInfo: PTypeInfo; var Table: TTable): Boolean;
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

  for var Index in Indexes do
    Index.Free;

  inherited;
end;

function TTable.FindField(const FieldName: String; var Field: TField): Boolean;
begin
  Field := nil;
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

function TTable.GetField(const FieldName: String): TField;
begin
  FindField(FieldName, Result);
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

constructor TManyValueAssociation.Create(const Field: TField; const ChildTable: TTable; const ForeignKey: TForeignKey);
begin
  inherited Create;

  FChildTable := ChildTable;
  FField := Field;
  FForeignKey := ForeignKey;
  FForeignKey.FManyValueAssociation := Self;
end;

{ TField }

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

destructor TField.Destroy;
begin
  FDefaultConstraint.Free;

  inherited;
end;

function TField.GetAsString(const Value: TValue): String;
begin
  if Value.IsEmpty then
    Result := 'null'
  else
    case SpecialType of
      stDate:
        Result := QuotedStr(DateToStr(Value.AsExtended, TValue.FormatSettings));
      stDateTime:
        begin
          DateTimeToString(Result, 'dddddd', Value.AsExtended, TValue.FormatSettings);

          Result := QuotedStr(Result);
        end;
      stTime:
        Result := QuotedStr(TimeToStr(Value.AsExtended, TValue.FormatSettings))
    else
      case Value.Kind of
        tkChar, tkLString, tkRecord, tkString, tkUString, tkWChar, tkWString:
          Result := QuotedStr(Value.GetAsString);

        tkClass:
          Result := ForeignKey.ParentTable.PrimaryKey.GetAsString(Value.AsObject);

        tkFloat:
          Result := FloatToStr(Value.AsExtended, TValue.FormatSettings);

        tkEnumeration, tkInteger, tkInt64:
          Result := Value.GetAsString;

      else
        raise Exception.Create('Type not mapped!');
      end;
    end;
end;

function TField.GetAutoGenerated: Boolean;
begin
  Result := Assigned(FDefaultConstraint);
end;

function TField.GetAsString(const Instance: TObject): String;
begin
  Result := GetAsString(GetValue(Instance));
end;

function TField.GetPropertyValue(const Instance: TObject): TValue;
begin
  Result := PropertyInfo.GetValue(Instance);
end;

function TField.GetValue(const Instance: TObject): TValue;
begin
  HasValue(Instance, Result);
end;

function TField.HasValue(const Instance: TObject; var Value: TValue): Boolean;
begin
  if IsLazy then
  begin
    var Manipulator := TLazyManipulator.GetManipulator(Instance, PropertyInfo);

    if Manipulator.HasValue then
      if Manipulator.Loaded then
        Value := Manipulator.Value
      else
        Value := Manipulator.Key
    else
      Value := TValue.Empty;
  end
  else if FIsNullable then
    Value := TNullableManipulator.GetManipulator(Instance, PropertyInfo).Value
  else
    Value := GetPropertyValue(Instance);

  Result := not Value.IsEmpty;
end;

procedure TField.SetValue(const Instance: TObject; const Value: TValue);
begin
  if FIsNullable then
    TNullableManipulator.GetManipulator(Instance, PropertyInfo).Value := Value
  else if IsLazy then
    TLazyManipulator.GetManipulator(Instance, PropertyInfo).Value := Value
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

{ EChildTableMustHasToHaveAPrimaryKey }

constructor EChildTableMustHasToHaveAPrimaryKey.Create(ChildTable: TTable);
begin
  inherited CreateFmt('The child table %s hasn''t a primary key, check the implementation!', [ChildTable.ClassTypeInfo.Name]);
end;

{ EForeignKeyToSingleTableInheritanceTable }

constructor EForeignKeyToSingleTableInheritanceTable.Create(ParentTable: TRttiInstanceType);
begin
  inherited CreateFmt('The parent table %s can''t be single inheritence table, check the implementation!', [ParentTable.Name]);
end;

{ EFieldIndexNotFound }

constructor EFieldIndexNotFound.Create(const Table: TTable; const FieldName: String);
begin
  inherited CreateFmt('Field "%s" not found in the table "%s"!', [Table.Name, FieldName]);
end;

{ TTableObject }

constructor TTableObject.Create(const Table: TTable);
begin
  inherited Create;

  FTable := Table;
end;

end.
