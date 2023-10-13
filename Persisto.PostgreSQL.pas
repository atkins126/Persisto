﻿unit Persisto.PostgreSQL;

interface

uses Persisto, Persisto.Mapping;

type
  TDatabaseManipulatorPostgreSQL = class(TDatabaseManipulator, IDatabaseManipulator)
  private
    function GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
    function GetFieldType(const Field: TField): String;
    function GetSchemaTablesScripts: TArray<String>;
    function GetSpecialFieldType(const Field: TField): String;
  end;

implementation

uses System.SysUtils;

{ TDatabaseManipulatorPostgreSQL }

function TDatabaseManipulatorPostgreSQL.GetDefaultValue(const DefaultConstraint: TDefaultConstraint): String;
const
  DEFAULT_VALUE: array[TAutoGeneratedType] of String = ('', 'current_date', 'localtime(0)', 'localtimestamp(0)', 'gen_random_uuid()', 'gen_random_uuid()', 'nextval(''%0:s'')', '%1:s');

begin
  var SequenceName := EmptyStr;

  if Assigned(DefaultConstraint.Sequence) then
    SequenceName := DefaultConstraint.Sequence.Name;

  Result := Format(DEFAULT_VALUE[DefaultConstraint.AutoGeneratedType], [SequenceName, DefaultConstraint.FixedValue]);
end;

function TDatabaseManipulatorPostgreSQL.GetFieldType(const Field: TField): String;
begin
  case Field.FieldType.TypeKind of
    tkInteger: Result := 'int';
    tkEnumeration: Result := 'smallint';
    tkFloat: Result := 'numeric';
    tkChar,
    tkWChar: Result := 'char';
    tkInt64: Result := 'bigint';
    tkString,
    tkLString,
    tkWString,
    tkUString: Result := 'varchar';
    else Result := EmptyStr;
  end;
end;

function TDatabaseManipulatorPostgreSQL.GetSchemaTablesScripts: TArray<String>;
begin
  Result := [
      'create or replace temp view PersistoDatabaseSequence as (select sequence_name Id, sequence_name Name from information_schema.sequences)',
      'create or replace temp view PersistoDatabaseTable as (select table_name Id, table_name Name from information_schema.tables where table_schema = ''public'')',
      'create or replace temp view PersistoDatabaseTableField as (select cast(table_name || ''#'' || column_name as varchar(500)) Id, table_name IdTable, column_name Name from information_schema.columns where table_schema = ''public'')'
    ];
end;

function TDatabaseManipulatorPostgreSQL.GetSpecialFieldType(const Field: TField): String;
const
  SPECIAL_TYPE_MAPPING: array[TDatabaseSpecialType] of String = ('', 'date', 'timestamp', 'time', 'text', 'uuid', 'boolean');

begin
  Result := SPECIAL_TYPE_MAPPING[Field.SpecialType];
end;

end.

