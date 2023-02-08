﻿unit Delphi.ORM.Database.Metadata.Manipulator;

interface

uses System.Generics.Collections, Delphi.ORM.Database.Metadata, Delphi.ORM.Mapper, Delphi.ORM.Database.Connection;

type
  TMetadataManipulator = class(TInterfacedObject)
  private
    FConnection: IDatabaseConnection;
  protected
    function GetAutoGeneratedValue(const DefaultConstraint: TDefaultConstraint): String; virtual; abstract;
    function GetDefaultConstraintName(const Field: TField): String;
    function GetFieldCollation(const Field: TField): String;
    function GetFieldDefaultConstratint(const Field: TField): String;
    function GetFieldTypeDefinition(Field: TField): String;
    function GetFieldType(const Field: TField): String; virtual; abstract;
    function GetSpecialFieldType(const Field: TField): String; virtual; abstract;

    procedure CreateDefaultConstraint(const Field: TField);
    procedure CreateField(const Field: TField);
    procedure CreateForeignKey(const ForeignKey: TForeignKey);
    procedure CreateIndex(const Index: TIndex);
    procedure CreateTable(const Table: TTable);
    procedure CreateTempField(const Field: TField);
    procedure DropDefaultConstraint(const Field: TDatabaseField);
    procedure DropField(const Field: TDatabaseField);
    procedure DropIndex(const Index: TDatabaseIndex);
    procedure DropForeignKey(const ForeignKey: TDatabaseForeignKey);
    procedure DropTable(const Table: TDatabaseTable);
    procedure RenameField(const SourceField, DestinyField: TField);
    procedure UpdateField(const SourceField, DestinyField: TField);
  public
    constructor Create(const Connection: IDatabaseConnection);

    function GetFieldDefinition(const Field: TField): String;

    property Connection: IDatabaseConnection read FConnection;
  end;

implementation

uses System.SysUtils, Delphi.ORM.Attributes;

{ TMetadataManipulator }

constructor TMetadataManipulator.Create(const Connection: IDatabaseConnection);
begin
  inherited Create;

  FConnection := Connection;
end;

procedure TMetadataManipulator.CreateDefaultConstraint(const Field: TField);
begin
  raise Exception.Create('Not implemented!');
end;

procedure TMetadataManipulator.CreateField(const Field: TField);
begin
  Connection.ExecuteDirect(Format('alter table %s add %s', [Field.Table.DatabaseName, GetFieldDefinition(Field)]));
end;

procedure TMetadataManipulator.CreateForeignKey(const ForeignKey: TForeignKey);
begin
  Connection.ExecuteDirect(Format('alter table %s add constraint %s foreign key (%s) references %s (%s)', [ForeignKey.Table.DatabaseName,
    ForeignKey.DatabaseName, ForeignKey.Field.DatabaseName, ForeignKey.ParentTable.DatabaseName, ForeignKey.ParentTable.PrimaryKey.DatabaseName]));
end;

procedure TMetadataManipulator.CreateIndex(const Index: TIndex);

  function GetFieldList: String;
  begin
    Result := EmptyStr;

    for var Field in Index.Fields do
    begin
      if not Result.IsEmpty then
        Result := Result + ', ';

      Result := Result + Field.DatabaseName;
    end;
  end;

begin
  if Index.PrimaryKey then
    Connection.ExecuteDirect(Format('alter table %s add constraint %s primary key (%s)', [Index.Table.DatabaseName, Index.DatabaseName, GetFieldList]))
  else
    Connection.ExecuteDirect(Format('create index %s on %s (%s)', [Index.DatabaseName, Index.Table.DatabaseName, GetFieldList]));
end;

procedure TMetadataManipulator.CreateTable(const Table: TTable);
begin
  var Fields := EmptyStr;

  for var Field in Table.Fields do
    if not Field.IsManyValueAssociation then
    begin
      if not Fields.IsEmpty then
        Fields := Fields + ',';

      Fields := Fields + GetFieldDefinition(Field);
    end;

  Connection.ExecuteDirect(Format('create table %s (%s)', [Table.DatabaseName, Fields]));
end;

procedure TMetadataManipulator.CreateTempField(const Field: TField);
begin
  CreateField(Field);
end;

procedure TMetadataManipulator.DropDefaultConstraint(const Field: TDatabaseField);
begin
  Connection.ExecuteDirect(Format('alter table %s drop constraint %s', [Field.Table.Name, Field.DefaultConstraint.Name]));
end;

procedure TMetadataManipulator.DropField(const Field: TDatabaseField);
begin
  Connection.ExecuteDirect(Format('alter table %s drop column %s', [Field.Table.Name, Field.Name]));
end;

procedure TMetadataManipulator.DropForeignKey(const ForeignKey: TDatabaseForeignKey);
begin
  Connection.ExecuteDirect(Format('alter table %s drop constraint %s', [ForeignKey.Table.Name, ForeignKey.Name]));
end;

procedure TMetadataManipulator.DropIndex(const Index: TDatabaseIndex);
begin
  Connection.ExecuteDirect(Format('drop index %s on %s', [Index.Name, Index.Table.Name]));
end;

procedure TMetadataManipulator.DropTable(const Table: TDatabaseTable);
begin
  Connection.ExecuteDirect(Format('drop table %s', [Table.Name]));
end;

function TMetadataManipulator.GetDefaultConstraintName(const Field: TField): String;
begin
  Result := Format('DF_%s_%s', [Field.Table.DatabaseName, Field.DatabaseName]);
end;

function TMetadataManipulator.GetFieldCollation(const Field: TField): String;
begin
  Result := EmptyStr;

  if not Field.Collation.IsEmpty then
    Result := Format(' collate %s', [Field.Collation]);
end;

function TMetadataManipulator.GetFieldDefaultConstratint(const Field: TField): String;
begin
  Result := EmptyStr;

  if Assigned(Field.DefaultConstraint) then
    Result := Format(' constraint %s default(%s)', [GetDefaultConstraintName(Field), GetAutoGeneratedValue(Field.DefaultConstraint)]);
end;

function TMetadataManipulator.GetFieldDefinition(const Field: TField): String;
const
  IS_NULL_VALUE: array[Boolean] of String = ('', 'not ');

begin
  Result := Format('%s %s %snull%s%s', [Field.DatabaseName, GetFieldTypeDefinition(Field), IS_NULL_VALUE[Field.Required], GetFieldCollation(Field),
    GetFieldDefaultConstratint(Field)]);
end;

function TMetadataManipulator.GetFieldTypeDefinition(Field: TField): String;
begin
  if Field.SpecialType = stNotDefined then
  begin
    Result := GetFieldType(Field);

    if Field.FieldType.TypeKind in [tkFloat, tkUString, tkWChar] then
    begin
      var Size := Field.Size.ToString;

      if Field.FieldType.TypeKind = tkFloat then
        Size := Size + ',' + Field.Scale.ToString;

      Result := Format('%s(%s)', [Result, Size]);
    end;
  end
  else
    Result := GetSpecialFieldType(Field);
end;

procedure TMetadataManipulator.RenameField(const SourceField, DestinyField: TField);
begin
  raise Exception.Create('Not implemented!');
end;

procedure TMetadataManipulator.UpdateField(const SourceField, DestinyField: TField);
begin
  Connection.ExecuteDirect(Format('update %s set %s = %s', [SourceField.Table.DatabaseName, DestinyField.DatabaseName, SourceField.DatabaseName]));
end;

end.

