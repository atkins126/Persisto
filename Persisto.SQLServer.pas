﻿unit Persisto.SQLServer;

interface

uses Data.DB, Persisto;

type
  TDatabaseManipulatorSQLServer = class(TDatabaseManipulator, IDatabaseManipulator)
  private
    function CreateDatabase(const DatabaseName: String): String;
    function DropDatabase(const DatabaseName: String): String;
    function GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
    function GetFieldType(const Field: TField): String;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const Field: TField): String;
    function MakeInsertStatement(const Table: TTable; const Params: TParams): String;
  end;

implementation

uses System.Rtti, System.TypInfo, System.SysUtils, System.Classes, Persisto.Mapping;

{ TDatabaseManipulatorSQLServer }

function TDatabaseManipulatorSQLServer.CreateDatabase(const DatabaseName: String): String;
begin
  Result := Format('create database %s', [DatabaseName]);
end;

function TDatabaseManipulatorSQLServer.DropDatabase(const DatabaseName: String): String;
begin
  Result := Format('drop database if exists %s', [DatabaseName]);
end;

function TDatabaseManipulatorSQLServer.GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
const
  INTERNAL_FUNCTIONS: array [TAutoGeneratedType] of String = ('', 'cast(getdate() as date)', 'cast(getdate() as time)', 'getdate()', 'newsequentialid()', 'newid()',
    'next value for [%0:s]', '%1:s');

begin
  var SequenceName := EmptyStr;

  if Assigned(DefaultConstraint.Sequence) then
    SequenceName := DefaultConstraint.Sequence.Name;

  Result := Format(INTERNAL_FUNCTIONS[DefaultConstraint.AutoGeneratedType], [SequenceName, DefaultConstraint.FixedValue]);
end;

function TDatabaseManipulatorSQLServer.GetFieldType(const Field: TField): String;
begin
  case Field.FieldType.TypeKind of
    tkInteger:
      Result := 'int';
    tkEnumeration:
      Result := 'tinyint';
    tkFloat:
      Result := 'numeric';
    tkChar, tkWChar:
      Result := 'char';
    tkInt64:
      Result := 'bigint';
    tkString, tkLString, tkWString, tkUString:
      Result := 'varchar';
  else
    Result := EmptyStr;
  end;
end;

function TDatabaseManipulatorSQLServer.GetSchemaTablesScripts: TArray<String>;
const
  DEFAULT_CONSTRAINT_SQL =
    'select cast(parent_object_id as varchar(20)) + ''.'' + cast(parent_column_id as varchar(20)) Id,' +
           'name,' +
           'substring(definition, 2, len(definition) - 2) Value ' +
      'from sys.default_constraints';

  FOREING_KEY_SQL =
    'select cast(object_id as varchar(20)) Id,' +
           'name,' +
           'cast(parent_object_id as varchar(20)) IdTable,' +
           'cast(referenced_object_id as varchar(20)) IdReferenceTable,' +
           'null ReferenceField ' +
      'from sys.foreign_keys FK';

  FOREING_KEY_COLUMS_SQL =
    'select cast(FKC.constraint_object_id as varchar(20)) + ''.'' + cast(constraint_column_id as varchar(20)) Id,' +
           'cast(FKC.constraint_object_id as varchar(20)) IdForeignKey,' +
           'RC.name ' +
      'from sys.foreign_keys FK ' +
      'join sys.foreign_key_columns FKC ' +
        'on FKC.constraint_object_id = FK.object_id ' +
      'join sys.columns RC ' +
        'on RC.object_id = FKC.referenced_object_id ' +
       'and RC.column_id = FKC.referenced_column_id';

  PRIMARY_KEY_CONSTRAINT_SQL =
    'select cast(PK.object_id as varchar(20)) Id,' +
           'PK.name,' +
           'C.name FieldName ' +
      'from sys.key_constraints PK ' +
      'join sys.index_columns IC ' +
        'on IC.object_id = PK.parent_object_id ' +
       'and IC.index_id = PK.unique_index_id ' +
      'join sys.columns C ' +
        'on C.object_id = IC.object_id ' +
       'and C.column_id = IC.column_id ' +
     'where PK.type = ''PK''';

  SEQUENCES_SQL =
    'select cast(object_id as varchar(20)) Id,' +
            'name ' +
      'from sys.sequences';

  TABLE_SQL =
       'select cast(T.object_id as varchar(20)) Id,' +
              'cast(PK.object_id as varchar(20)) IdPrimaryKeyConstraint,' +
              'T.name ' +
         'from sys.tables T ' +
    'left join sys.key_constraints PK ' +
           'on PK.parent_object_id = T.object_id ' +
          'and PK.type = ''PK''';

  COLUMNS_SQL =
    'select cast(C.object_id as varchar(20)) + ''.'' + cast(C.column_id as varchar(20)) Id,' +
           '(select cast(DF.parent_object_id as varchar(20)) + ''.'' + cast(DF.parent_column_id as varchar(20)) ' +
              'from sys.default_constraints DF ' +
             'where DF.parent_object_id = C.object_id ' +
               'and DF.parent_column_id = C.column_id) IdDefaultConstraint,' +
           'cast(T.object_id as varchar(20)) IdTable,' +
           'case system_type_id ' +
              // String
              'when 167 then 5 ' +
              // Integer
              'when 56 then 1 ' +
              // Char
              'when 175 then 2 ' +
              // Enumeration
              'when 48 then 3 ' +
              // Float
              'when 108 then 4 ' +
              // Int64
              'when 127 then 16 ' +
              'else 0 ' +
           'end FieldType,'+
           'C.name,' +
           'iif(C.is_nullable = 0, 1, 0) Required,'+
           'C.scale Scale,' +
           'C.max_length Size,' +
           'case system_type_id ' +
              // Date
              'when 40 then 1 ' +
              // DateTime
              'when 61 then 2 ' +
              // Time
              'when 41 then 3 ' +
              // Text
              'when 167 then iif(max_length = -1, 4, 0)  ' +
              // Unique Identifier
              'when 36 then 5 ' +
              // Boolean
              'when 104 then 6 ' +
              'else 0 ' +
           'end SpecialType '+
      'from sys.columns C ' +
      'join sys.tables T ' +
        'on T.object_id = C.object_id';

  function CreateView(const Name, SQL: String): String;
  begin
    Result := Format('create or alter view PersistoDatabase%s as (%s)', [Name, SQL]);
  end;

begin
  Result := [
    CreateView('DefaultConstraint', DEFAULT_CONSTRAINT_SQL),
    CreateView('ForeignKey', FOREING_KEY_SQL),
    CreateView('Sequence', SEQUENCES_SQL),
    CreateView('Table', TABLE_SQL),
    CreateView('TableField', COLUMNS_SQL),
    CreateView('PrimaryKeyConstraint', PRIMARY_KEY_CONSTRAINT_SQL)
    ];
end;

function TDatabaseManipulatorSQLServer.GetSpecialFieldType(const Field: TField): String;
const
  FIELD_SPECIAL_TYPE_MAPPING: array [TDatabaseSpecialType] of String = ('', 'date', 'datetime', 'time', 'varchar(max)', 'uniqueidentifier', 'bit');

begin
  Result := FIELD_SPECIAL_TYPE_MAPPING[Field.SpecialType];
end;

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

  Result := 'insert into %0:s';

  if Params.Count > 0 then
    Result := Result + '(%1:s)';

  if not ReturningFields.IsEmpty then
    Result := Result + Format(' output %s ', [ReturningFields]);

  if Params.Count = 0 then
    Result := Result + 'default values'
  else
    Result := Result + 'values(%2:s)';

  Result := Format(Result, [Table.DatabaseName, FieldNames, ParamNames]);
end;

end.

