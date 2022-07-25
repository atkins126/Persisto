﻿unit Delphi.ORM.Cache;

interface

uses System.Rtti, System.SysUtils, System.Generics.Collections;

type
  ICache = interface
    ['{E910CEFC-7423-4307-B805-0B313BF46735}']
    function Add(const Key: String; const Value: TObject): TObject; overload;
    function Get(const Key: String; var Value: TObject): Boolean;
  end;

  TCache = class(TInterfacedObject, ICache)
  private
{$IFDEF DCC}
    FReadWriteControl: IReadWriteSync;
{$ENDIF}
    FValues: TDictionary<String, TObject>;

    function Add(const Key: String; const Value: TObject): TObject; overload;
    function Get(const Key: String; var Value: TObject): Boolean;

    class function GenerateKey(const KeyName: String; const KeyValue: TValue): String; overload;
  public
    constructor Create;

    destructor Destroy; override;

    class function GenerateKey(AClass: TClass; const KeyValue: TValue): String; overload;
    class function GenerateKey(RttiType: TRttiType; const KeyValue: TValue): String; overload;
  end;

implementation

uses Delphi.ORM.Rtti.Helper;

{ TCache }

function TCache.Add(const Key: String; const Value: TObject): TObject;
begin
  Result := Value;

{$IFDEF DCC}
  FReadWriteControl.BeginWrite;
{$ENDIF}

  try
    FValues.Add(Key, Value);
  finally
{$IFDEF DCC}
    FReadWriteControl.EndWrite;
{$ENDIF}
  end;
end;

constructor TCache.Create;
begin
  inherited;

{$IFDEF DCC}
  FReadWriteControl := TMultiReadExclusiveWriteSynchronizer.Create;
{$ENDIF}
  FValues := TObjectDictionary<String, TObject>.Create([doOwnsValues]);
end;

destructor TCache.Destroy;
begin
  FValues.Free;

  inherited;
end;

class function TCache.GenerateKey(RttiType: TRttiType; const KeyValue: TValue): String;
begin
  Result := GenerateKey(RttiType.QualifiedName, KeyValue);
end;

class function TCache.GenerateKey(const KeyName: String; const KeyValue: TValue): String;
begin
  Result := Format('%s.%s', [KeyName, KeyValue.GetAsString]);
end;

class function TCache.GenerateKey(AClass: TClass; const KeyValue: TValue): String;
begin
{$IFDEF DCC}
  Result := GenerateKey(AClass.QualifiedClassName, KeyValue);
{$ENDIF}
end;

function TCache.Get(const Key: String; var Value: TObject): Boolean;
begin
{$IFDEF DCC}
  FReadWriteControl.BeginRead;
{$ENDIF}

  try
    Result := FValues.TryGetValue(Key, Value);
  finally
{$IFDEF DCC}
    FReadWriteControl.EndRead;
{$ENDIF}
  end;
end;

end.

