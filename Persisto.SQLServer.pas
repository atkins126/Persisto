﻿unit Persisto.SQLServer;

interface

uses System.Generics.Collections, Data.DB, Persisto, Persisto.Mapping;

type
  TDatabaseManipulatorSQLServer = class(TDatabaseManipulator, IDatabaseManipulator)
  private
    FFieldSpecialTypeMapping: TDictionary<String, TDatabaseSpecialType>;
    FFieldTypeMapping: TDictionary<String, TTypeKind>;

    function CreateSequence(const Sequence: TSequence): String;
    function CreateTempField(const Field: TField): String;
    function DropIndex(const Index: TDatabaseIndex): String;
    function GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
    function GetFieldType(const Field: TField): String;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const Field: TField): String;
    function MakeInsertStatement(const Table: TTable; const Params: TParams): String;
    function RenameField(const Current, Destiny: TField): String;
  public
    constructor Create;

    destructor Destroy; override;
  end;

const
  TABLE_LOAD_SQL =
       'select T.name TableName,' +
              'C.name ColumnName,' +
              'Ty.name TypeName,' +
              'C.max_length Size,' +
              'C.precision Precision,' +
              'C.scale Scale,' +
              'C.is_nullable Nullable,' +
              'C.collation_name Collation,' +
              'DC.name DefaultName,' +
              'DC.definition DefaultValue ' +
         'from sys.tables T ' +
         'join sys.columns C ' +
           'on C.object_id = T.object_id ' +
         'join sys.types Ty ' +
           'on Ty.user_type_id = C.user_type_id ' +
    'left join sys.default_constraints DC ' +
           'on DC.object_id = C.default_object_id ' +
     'order by TableName, ColumnName';

  INDEX_LOAD_SQL =
      'select T.name TableName,' +
             'I.name IndexName,' +
             'CI.name IndexColumnName,' +
             'I.is_primary_key PrimaryKey,' +
             'I.is_unique [Unique] ' +
        'from sys.tables T ' +
        'join sys.indexes I ' +
          'on I.object_id = T.object_id ' +
        'join sys.index_columns IC ' +
          'on IC.object_id = T.object_id ' +
         'and IC.index_id = I.index_id ' +
        'join sys.columns CI ' +
          'on CI.object_id = IC.object_id ' +
         'and CI.column_id = IC.column_id ' +
    'order by TableName, IndexName, IC.index_column_id';

  FOREIGN_KEY_LOAD_SQL =
      'select T.name TableName,' +
             'FK.name ForeignKeyName,' +
             'PC.name ParentColumnName,' +
             'RT.name ReferenceTableName,' +
             'PR.name ReferenceColumnName ' +
        'from sys.tables T ' +
        'join sys.foreign_keys FK ' +
          'on FK.parent_object_id = T.object_id ' +
        'join sys.foreign_key_columns FKC ' +
          'on FKC.constraint_object_id = FK.object_id ' +
        'join sys.columns PC ' +
          'on PC.object_id = FKC.parent_object_id ' +
         'and PC.column_id = FKC.parent_column_id ' +
        'join sys.tables RT ' +
          'on RT.object_id = FK.referenced_object_id ' +
        'join sys.columns PR ' +
          'on PR.object_id = FKC.referenced_object_id ' +
         'and PR.column_id = FKC.referenced_column_id ' +
    'order by TableName, ForeignKeyName, FKC.constraint_column_id';

  SEQUENCE_LOAD_SQL =
    'select Name ' +
      'from sys.sequences';

const
  FIELD_SPECIAL_TYPE_MAPPING: array[TDatabaseSpecialType] of String = ('', 'date', 'datetime', 'time', 'varchar(max)', 'uniqueidentifier', 'bit');
  FIELD_TYPE_MAPPING: array[System.TTypeKind] of String = ('', 'int', '', 'tinyint', 'numeric', '', '', '', '', 'char', '', '', '', '', '', '', 'bigint', '', 'varchar', '', '', '', '');
  SPECIAL_TYPE_IN_SYSTEM_TYPE: array[TDatabaseSpecialType] of TTypeKind = (tkUnknown, tkFloat, tkFloat, tkFloat, tkUString, tkUString, tkEnumeration);

implementation

uses System.Variants, System.SysUtils, Winapi.ActiveX;

{ TDatabaseManipulatorSQLServer }

constructor TDatabaseManipulatorSQLServer.Create;
begin
  inherited;

  FFieldTypeMapping := TDictionary<String, System.TTypeKind>.Create;
  FFieldSpecialTypeMapping := TDictionary<String, TDatabaseSpecialType>.Create;

  for var AType := Low(System.TTypeKind) to High(System.TTypeKind) do
    if not FIELD_TYPE_MAPPING[AType].IsEmpty then
      FFieldTypeMapping.Add(FIELD_TYPE_MAPPING[AType], AType);

  for var AType := Succ(Low(TDatabaseSpecialType)) to High(TDatabaseSpecialType) do
  begin
    FFieldSpecialTypeMapping.Add(FIELD_SPECIAL_TYPE_MAPPING[AType], AType);

    FFieldTypeMapping.Add(FIELD_SPECIAL_TYPE_MAPPING[AType], SPECIAL_TYPE_IN_SYSTEM_TYPE[AType]);
  end;

  FFieldSpecialTypeMapping.Add('text', stText);

  FFieldTypeMapping.Add('text', tkUString);
end;

function TDatabaseManipulatorSQLServer.CreateSequence(const Sequence: TSequence): String;
begin
  Result := Format('create sequence %s increment by 1 start with 1', [Sequence.Name]);
end;

function TDatabaseManipulatorSQLServer.CreateTempField(const Field: TField): String;
begin
  if Field.Required then
  begin
    Field.DefaultConstraint := TDefaultConstraint.Create;
    Field.DefaultConstraint.AutoGeneratedType := agtFixedValue;
    if Field.SpecialType = stUniqueIdentifier then
      Field.DefaultConstraint.FixedValue := '''00000000-0000-0000-0000-000000000000'''
    else
      Field.DefaultConstraint.FixedValue := '0';
  end;

  inherited;
end;

destructor TDatabaseManipulatorSQLServer.Destroy;
begin
  FFieldTypeMapping.Free;

  FFieldSpecialTypeMapping.Free;

  inherited;
end;

function TDatabaseManipulatorSQLServer.DropIndex(const Index: TDatabaseIndex): String;
begin
//  if Index.PrimaryKey then
//    ExecuteDirect(Format('alter table %s drop constraint %s', [Index.Table.Name, Index.Name]))
//  else
//    inherited;
end;

function TDatabaseManipulatorSQLServer.GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
const
  INTERNAL_FUNCTIONS: array[TAutoGeneratedType] of String = ('', 'cast(getdate() as date)', 'cast(getdate() as time)', 'getdate()', 'newsequentialid()', 'newid()',
    'next value for [%0:s]', '%1:s');

begin
  var SequenceName := EmptyStr;

  if Assigned(DefaultConstraint.Sequence) then
    SequenceName := DefaultConstraint.Sequence.Name;

  Result := Format(INTERNAL_FUNCTIONS[DefaultConstraint.AutoGeneratedType], [SequenceName, DefaultConstraint.FixedValue]);
end;

function TDatabaseManipulatorSQLServer.GetFieldType(const Field: TField): String;
begin
  Result := FIELD_TYPE_MAPPING[Field.FieldType.TypeKind]
end;

function TDatabaseManipulatorSQLServer.GetSchemaTablesScripts: TArray<String>;
begin

end;

function TDatabaseManipulatorSQLServer.GetSpecialFieldType(const Field: TField): String;
begin
  Result := FIELD_SPECIAL_TYPE_MAPPING[Field.SpecialType];
end;

//procedure TDatabaseManipulatorSQLServer.LoadSchema(const Schema: TDatabaseSchema);
//const
//  COLUMN_COLLATION_INDEX = 7;
//  COLUMN_DEFAULT_NAME_INDEX = 8;
//  COLUMN_DEFAULT_VALUE_INDEX = 9;
//  COLUMN_NAME_INDEX = 1;
//  COLUMN_NULLABLE_INDEX = 6;
//  COLUMN_PRECISION_INDEX = 4;
//  COLUMN_SCALE_INDEX = 5;
//  COLUMN_SIZE_INDEX = 3;
//  COLUMN_TYPE_INDEX = 2;
//  FOREIGN_KEY_NAME_INDEX = 1;
//  FOREIGN_KEY_PARENT_FIELD_NAME_INDEX = 2;
//  FOREIGN_KEY_REFERENCE_NAME_INDEX = 3;
//  FOREIGN_KEY_REFERENCE_FIELD_NAME_INDEX = 4;
//  INDEX_FIELD_NAME_INDEX = 2;
//  INDEX_NAME_INDEX = 1;
//  INDEX_PRIMARY_KEY_INDEX = 3;
//  INDEX_UNIQUE_INDEX = 4;
//  SEQUENCE_NAME = 0;
//  TABLE_NAME_INDEX = 0;
//
//var
//  Cursor: IDatabaseCursor;
//
//  ForeignKey: TDatabaseForeignKey;
//
//  Index: TDatabaseIndex;
//
//  Table: TDatabaseTable;
//
//  Field: TDatabaseField;
//
//  procedure LoadDefaultValue;
//  begin
//    var DefaultName := VarToStr(Cursor.GetFieldValue(COLUMN_DEFAULT_NAME_INDEX));
//    var DefaultValue := VarToStr(Cursor.GetFieldValue(COLUMN_DEFAULT_VALUE_INDEX));
//
//    if not DefaultName.IsEmpty then
//      TDatabaseDefaultConstraintSQLServer.Create(Field, DefaultName, DefaultValue);
//  end;
//
//  procedure LoadFieldInfo;
//  begin
//    Field := TDatabaseField.Create(Table, Cursor.GetFieldValue(COLUMN_NAME_INDEX));
//    Field.Collation := VarToStr(Cursor.GetFieldValue(COLUMN_COLLATION_INDEX));
//    Field.Required := Cursor.GetFieldValue(COLUMN_NULLABLE_INDEX) = 0;
//    Field.Scale := Cursor.GetFieldValue(COLUMN_SCALE_INDEX);
//    Field.Size := Cursor.GetFieldValue(COLUMN_SIZE_INDEX);
//    var FieldType := Cursor.GetFieldValue(COLUMN_TYPE_INDEX);
//
//    if FFieldTypeMapping.ContainsKey(FieldType) then
//      Field.FieldType := FFieldTypeMapping[FieldType];
//
//    if (Field.FieldType = tkUString) and (Field.Size = Word(-1)) then
//      FieldType := 'varchar(max)'
//    else if Field.FieldType = tkFloat then
//      Field.Size := Cursor.GetFieldValue(COLUMN_PRECISION_INDEX);
//
//    if FFieldSpecialTypeMapping.ContainsKey(FieldType) then
//      Field.SpecialType := FFieldSpecialTypeMapping[FieldType];
//
//    LoadDefaultValue;
//  end;
//
//begin
////  Cursor := OpenCursor(TABLE_LOAD_SQL);
//
//  while Cursor.Next do
//  begin
//    var TableName := Cursor.GetFieldValue(TABLE_NAME_INDEX);
//
//    Table := Schema.Table[TableName];
//
//    if not Assigned(Table) then
//      Table := TDatabaseTable.Create(Schema, TableName);
//
//    LoadFieldInfo;
//  end;
//
////  Cursor := OpenCursor(INDEX_LOAD_SQL);
//
//  while Cursor.Next do
//  begin
//    var IndexName: String := Cursor.GetFieldValue(INDEX_NAME_INDEX);
//    Table := Schema.Table[Cursor.GetFieldValue(TABLE_NAME_INDEX)];
//
//    Index := Table.Index[IndexName];
//
//    if not Assigned(Index) then
//    begin
//      Index := TDatabaseIndex.Create(Table, IndexName);
//      Index.PrimaryKey := Cursor.GetFieldValue(INDEX_PRIMARY_KEY_INDEX);
//      Index.Unique := Cursor.GetFieldValue(INDEX_UNIQUE_INDEX);
//    end;
//
//    Index.Fields := Index.Fields + [Table.Field[Cursor.GetFieldValue(INDEX_FIELD_NAME_INDEX)]];
//  end;
//
////  Cursor := OpenCursor(FOREIGN_KEY_LOAD_SQL);
//
//  while Cursor.Next do
//  begin
//    var ForeignKeyName: String := Cursor.GetFieldValue(FOREIGN_KEY_NAME_INDEX);
//    var ReferenceTable := Schema.Table[Cursor.GetFieldValue(FOREIGN_KEY_REFERENCE_NAME_INDEX)];
//    Table := Schema.Table[Cursor.GetFieldValue(TABLE_NAME_INDEX)];
//
//    ForeignKey := Table.ForeignKey[ForeignKeyName];
//
//    if not Assigned(ForeignKey) then
//      ForeignKey := TDatabaseForeignKey.Create(Table, ForeignKeyName, ReferenceTable);
//
//    ForeignKey.Fields := ForeignKey.Fields + [Table.Field[Cursor.GetFieldValue(FOREIGN_KEY_PARENT_FIELD_NAME_INDEX)]];
//    ForeignKey.FieldsReference := ForeignKey.FieldsReference + [ReferenceTable.Field[Cursor.GetFieldValue(FOREIGN_KEY_REFERENCE_FIELD_NAME_INDEX)]];
//  end;
//
////  Cursor := OpenCursor(SEQUENCE_LOAD_SQL);
//
//  while Cursor.Next do
//    Schema.Sequences.Add(TDatabaseSequence.Create(Cursor.GetFieldValue(SEQUENCE_NAME)));
//end;

function TDatabaseManipulatorSQLServer.MakeInsertStatement(const Table: TTable; const Params: TParams): String;
begin
  var FieldNames := EmptyStr;
  var ParamNames := EmptyStr;
  var ReturningFields := EmptyStr;

  for var A := 0 to Pred(Params.Count) do
  begin
    if not FieldNames.IsEmpty then
    begin
      FieldNames := FieldNames + ',';
      ParamNames := ParamNames + ',';
    end;

    FieldNames := FieldNames + Params[A].Name;
    ParamNames := ParamNames + ':' + Params[A].Name;
  end;

  for var Field in Table.ReturningFields do
  begin
    if not ReturningFields.IsEmpty then
      ReturningFields := ReturningFields + ',';

    ReturningFields := ReturningFields + Format('Inserted.%s', [Field.DatabaseName]);
  end;

  Result := 'insert into %s(%s)';

  if not ReturningFields.IsEmpty then
    Result := Result + Format('output %s ', [ReturningFields]);

  Result := Result + 'values(%s)';

  Result := Format(Result, [Table.DatabaseName, FieldNames, ParamNames]);
end;

function TDatabaseManipulatorSQLServer.RenameField(const Current, Destiny: TField): String;
begin
//  ExecuteDirect(Format('exec sp_rename ''%s.%s'', ''%s'', ''column''', [Current.Table.DatabaseName, Current.DatabaseName, Destiny.DatabaseName]));
end;

end.

