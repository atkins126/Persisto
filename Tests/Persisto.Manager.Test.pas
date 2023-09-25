﻿unit Persisto.Manager.Test;

interface

uses DUnitX.TestFramework, Persisto, Persisto.Mapping;

type
  [TestFixture]
  TManagerTest = class
  private
    FManager: TManager;

    procedure PrepareDatabase;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenInsertAValueInManagerMustInsertTheValueInDatabaseAsExpected;
    [Test]
    procedure WhenInsertAnObjectWithAutoGeneratedValuesMustLoadTheValueInTheInsertedObject;
    [Test]
    procedure BeforeSaveTheMainObjectMustSaveTheForeignKeysOfTheObject;
    [Test]
    procedure WhenInsertAnObjectTheObjectsMustBeProcessedOnlyOneTime;
    [Test]
    procedure WhenAClassIsInheritedFromAnotherClassMustInsertTheParentClassInTheInsert;
    [Test]
    procedure WhenInsertAnObjectWithForeignKeyMustInsertTheForeignKeyPrimaryKeyValueInTheCurrentObject;
    [Test]
    procedure WhenUpdateAnObjectMustUpdateTheChangedFieldsOfTheObject;
    [Test]
    procedure WhenUpdateAnObjectMustUpdateOnlyTheObjectCallInTheProcedure;
    [Test]
    procedure WhenUpdateAnObjectMustUpdateOnlyTheChangedFieldsOfTheObject;
    [Test]
    procedure WhenUpdateAnInheritedObjectMustUpdateAllClassLevelsToo;
    [Test]
    procedure WhenChangeTheForeignKeyOfTheObjectMustUpdateTheForeignKeyValueFromTheCurrentTable;
    [Test]
    procedure WhenTryToUpdateAForeignObjectMustRaiseErrorExplainingThisNotAllowed;
    [Test]
    procedure WhenUpdateAnObjectWithoutChangesCanRaiseAnyUpdateError;
    [Test]
    procedure WhenUpdateAnObjectMustUpdateTheForeignKeyOfTheObjectToo;
    [Test]
    procedure WhenInsertAClassThatIsRecursiveInItSelfCantRaiseErrorOfStackOverflow;
    [Test]
    procedure WhenUpdateAClassThatIsRecursiveInItSelfCantRaiseErrorOfStackOverflow;
    [Test]
    procedure WhenInsertAnObjectWithRecursionAndTheForeignKeyIsntRequiredMustDelayTheInsertionOfForeignKeyToGetTheKeyInsertedAndUpdateTheColumnValue;
    [Test]
    procedure WhenInsertAnObjectWithEmptyForeignKeysCantRaiseAnyError;
    [Test]
    procedure WhenInsertARecursiveRequiredObjectMustInsertTheForeignKeyFirstToInsertTheMainObject;
    [Test]
    procedure WhenInsertARecursiveObjectAndCantReciveThePrimaryKeyFromAForeignKeyTableMustRaiseAnErroOfRecursivityProblem;
    [Test]
    procedure WhenSaveAnObjectThatWasntInsertedMustInsertTheObject;
    [Test]
    procedure WhenSaveAnObjectThatAlreadyInTheDatabaseMustUpdateTheFieldsOfTheObject;
    [Test]
    procedure WhenInsertAnObjectMustUpdateTheForeignKeyValues;
    [Test]
    procedure WhenUpdateAnObjectMustInsertTheNewObjectInTheForeignKey;
    [Test]
    procedure WhenInsertAnObjectWithManyValueAssociationCanRaiseAnyError;
    [Test]
    procedure WhenInsertAnObjectWithManyValueAssociationMustInsertTheChildValues;
    [Test]
    procedure WhenInsertAnObjectWithManyValueAssociationMustUpdateTheParentForeignKeyValueInTheChildTable;
    [Test]
    procedure WhenUpdateAnObjectWithManyValueAssociationCantRaiseAnyError;
    [Test]
    procedure WhenUpdateAnObjectWithManyValueAssociationMustUpdateTheChildValues;
    [Test]
    procedure WhenUpdateAnObjectWithManyValueAssociationMustInsertTheNewChildValues;
    [Test]
    procedure WhenLoadAnObjectWithOrderByMustLoadTheObjectsInTheOrderAsExpected;
    [Test]
    procedure WhenTheOrderByHasMoreThenOneFieldMustExecuteAsExpected;
  end;

  [TestFixture]
  TManagerDatabaseManipulationTest = class
  private
    FManager: TManager;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenUpdateTheDatabaseCantRaiseAnyError;
    [Test]
    procedure WhenUpdateTheDatabaseMustCreateTheTablesAfterTheProcessEnd;
  end;

  [TestFixture]
  TStateObjectTest = class
  public
    [Test]
    procedure WhenFillAValueMustReturnTheValueWhenRequestIt;
    [Test]
    procedure WhenCheckTheObjectPropertyMustReturnTheObjectPassedInTheConstructor;
    [Test]
    procedure WhenTheClassIsInheritedFromAnotherClassMustAllocTheChangeBufferForAllFieldsInTheTable;
  end;

implementation

uses System.SysUtils, System.Variants, Persisto.Test.Entity, Persisto.Test.Connection;

{ TManagerTest }

procedure TManagerTest.BeforeSaveTheMainObjectMustSaveTheForeignKeysOfTheObject;
begin
  var MainObject := TInsertTestWithForeignKey.Create;
  MainObject.FK1 := TInsertAutoGenerated.Create;

  FManager.Insert(MainObject);

  var Cursor := FManager.OpenCursor('select * from InsertAutoGenerated');

  Assert.IsTrue(Cursor.Next);
end;

procedure TManagerTest.PrepareDatabase;

  procedure InsertData;
  begin
    var AObject: TAAAA;

    AObject := TAAAA.Create;
    AObject.Id := 1;
    AObject.Value := 'AAA';

    FManager.Insert(AObject);

    AObject := TAAAA.Create;
    AObject.Id := 5;
    AObject.Value := 'AAA';

    FManager.Insert(AObject);

    AObject := TAAAA.Create;
    AObject.Id := 10;
    AObject.Value := 'AAA';

    FManager.Insert(AObject);

    AObject := TAAAA.Create;
    AObject.Id := 3;
    AObject.Value := 'BBB';

    FManager.Insert(AObject);

    AObject := TAAAA.Create;
    AObject.Id := 8;
    AObject.Value := 'BBB';

    FManager.Insert(AObject);
  end;

begin
  FManager.Mapper.GetTable(TInsertTestWithForeignKey);

  FManager.Mapper.GetTable(TInsertTest);

  FManager.Mapper.GetTable(TMyEntityInheritedFromSimpleClass);

  FManager.Mapper.GetTable(TStackOverflowClass);

  FManager.Mapper.GetTable(TClassWithForeignKey);

  FManager.Mapper.GetTable(TClassRecursiveThird);

  FManager.Mapper.GetTable(TMyEntityWithManyValueAssociation);

  FManager.Mapper.GetTable(TAAAA);

  FManager.UpdateDatabaseSchema;

  InsertData;
end;

procedure TManagerTest.Setup;
begin
  FManager := TManager.Create(CreateConnection, CreateDialect);

  PrepareDatabase;
end;

procedure TManagerTest.TearDown;
begin
  NullStrictConvert := True;

  FManager.Free;
end;

procedure TManagerTest.WhenAClassIsInheritedFromAnotherClassMustInsertTheParentClassInTheInsert;
begin
  var InheritedObject := TMyEntityInheritedFromSimpleClass.Create;

  FManager.Insert(InheritedObject);

  var Cursor := FManager.OpenCursor('select count(*) from MyEntityInheritedFromSingle');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual<Integer>(1, Cursor.GetFieldValue(0));

  Cursor := FManager.OpenCursor('select count(*) from MyEntityInheritedFromSimpleClass');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual<Integer>(1, Cursor.GetFieldValue(0));
end;

procedure TManagerTest.WhenChangeTheForeignKeyOfTheObjectMustUpdateTheForeignKeyValueFromTheCurrentTable;
begin
  var &Object1 := TClassWithForeignKey.Create;
  var &Object2 := TClassWithPrimaryKey.Create;

  FManager.Insert(&Object1);

  FManager.Insert(&Object2);

  &Object1.AnotherClass := &Object2;

  FManager.Update(&Object1);

  var Cursor := FManager.OpenCursor('select IdAnotherClass from ClassWithForeignKey');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual<NativeInt>(35, Cursor.GetFieldValue(0));
end;

procedure TManagerTest.WhenInsertAClassThatIsRecursiveInItSelfCantRaiseErrorOfStackOverflow;
begin
  var &Object := TStackOverflowClass.Create;
  &Object.Callback := TStackOverflowClass.Create;
  &Object.Callback.CallBack := &Object;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Insert(&Object);
    end);
end;

procedure TManagerTest.WhenInsertAnObjectMustUpdateTheForeignKeyValues;
begin
  var ForeignKeyObject := TInsertAutoGenerated.Create;
  ForeignKeyObject.Value := 1111;
  var MainObject := TInsertTestWithForeignKey.Create;

  FManager.Insert(ForeignKeyObject);

  ForeignKeyObject.Value := 1234;
  MainObject.FK1 := ForeignKeyObject;

  FManager.Insert(MainObject);

  var Cursor := FManager.OpenCursor('select Value from InsertAutoGenerated');

  Cursor.Next;

  Assert.AreEqual(1234, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenInsertAnObjectTheObjectsMustBeProcessedOnlyOneTime;
begin
  var MainObject := TInsertTestWithForeignKey.Create;
  MainObject.FK1 := TInsertAutoGenerated.Create;
  MainObject.FK2 := MainObject.FK1;

  FManager.Insert(MainObject);

  var Cursor := FManager.OpenCursor('select count(*) from InsertAutoGenerated');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual<Integer>(1, Cursor.GetFieldValue(0));
end;

procedure TManagerTest.WhenInsertAnObjectWithAutoGeneratedValuesMustLoadTheValueInTheInsertedObject;
begin
  var &Object := TInsertAutoGenerated.Create;

  FManager.Insert(&Object);

  Assert.IsNotEmpty(&Object.Id);
  Assert.AreEqual(FormatDateTime('dd-mm-yyyy hh:nn', Now), FormatDateTime('dd-mm-yyyy hh:nn', &Object.DateTime));
end;

procedure TManagerTest.WhenInsertAnObjectWithEmptyForeignKeysCantRaiseAnyError;
begin
  var &Object := TClassWithForeignKey.Create;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Insert(&Object);
    end);
end;

procedure TManagerTest.WhenInsertAnObjectWithForeignKeyMustInsertTheForeignKeyPrimaryKeyValueInTheCurrentObject;
begin
  var &Object := TClassWithForeignKey.Create;
  &Object.AnotherClass := TClassWithPrimaryKey.Create;

  FManager.Insert(&Object);

  var Cursor := FManager.OpenCursor('select IdAnotherClass from ClassWithForeignKey');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual<NativeInt>(35, Cursor.GetFieldValue(0));
end;

procedure TManagerTest.WhenInsertAnObjectWithManyValueAssociationCanRaiseAnyError;
begin
  var &Object := TMyEntityWithManyValueAssociation.Create;
  &Object.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create, TMyEntityWithManyValueAssociationChild.Create];

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Insert(&Object);
    end);
end;

procedure TManagerTest.WhenInsertAnObjectWithManyValueAssociationMustInsertTheChildValues;
begin
  var &Object := TMyEntityWithManyValueAssociation.Create;
  &Object.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create, TMyEntityWithManyValueAssociationChild.Create];

  FManager.Insert(&Object);

  var Cursor := FManager.OpenCursor('select count(*) from MyEntityWithManyValueAssociationChild');

  Cursor.Next;

  Assert.AreEqual(2, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenInsertAnObjectWithManyValueAssociationMustUpdateTheParentForeignKeyValueInTheChildTable;
begin
  var &Object := TMyEntityWithManyValueAssociation.Create;
  &Object.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create];

  FManager.Insert(&Object);

  var Cursor := FManager.OpenCursor('select IdManyValueAssociation from MyEntityWithManyValueAssociationChild');

  Cursor.Next;

  Assert.IsNotEmpty(String(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenInsertAnObjectWithRecursionAndTheForeignKeyIsntRequiredMustDelayTheInsertionOfForeignKeyToGetTheKeyInsertedAndUpdateTheColumnValue;
begin
  var &Object := TStackOverflowClass.Create;
  &Object.Callback := &Object;

  FManager.Insert(&Object);

  var Cursor := FManager.OpenCursor('select Id, IdCallBack from StackOverflowClass');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual(String(Cursor.GetFieldValue(0)), String(Cursor.GetFieldValue(1)));
end;

procedure TManagerTest.WhenInsertARecursiveObjectAndCantReciveThePrimaryKeyFromAForeignKeyTableMustRaiseAnErroOfRecursivityProblem;
begin
  var &Object := TClassRecursiveThird.Create;
  &Object.Recursive := TClassRecursiveSecond.Create;
  &Object.Recursive.Recursive := TClassRecursiveFirst.Create;
  &Object.Recursive.Recursive.Recursive := &Object;

  Assert.WillRaise(
    procedure
    begin
      FManager.Insert(&Object);
    end, ERecursionInsertionError);
end;

procedure TManagerTest.WhenInsertARecursiveRequiredObjectMustInsertTheForeignKeyFirstToInsertTheMainObject;
begin
  var &Object := TClassRecursiveFirst.Create;
  &Object.Recursive := TClassRecursiveThird.Create;
  &Object.Recursive.Recursive := TClassRecursiveSecond.Create;
  &Object.Recursive.Recursive.Recursive := &Object;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Insert(&Object);
    end);

  var Cursor := FManager.OpenCursor('select IdRecursive from ClassRecursiveThird');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual(2, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenInsertAValueInManagerMustInsertTheValueInDatabaseAsExpected;
begin
  var &Object := TInsertTest.Create;
  &Object.Id := 'abc';
  &Object.IntegerValue := 123;
  &Object.Value := 123.456;

  FManager.Insert(&Object);

  var Cursor := FManager.OpenCursor('select * from InsertTest');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual('abc', String(Cursor.GetFieldValue(0)));
  Assert.AreEqual('123', String(Cursor.GetFieldValue(1)));
  Assert.AreEqual('123.456', FormatFloat('0.000', Cursor.GetFieldValue(2), TFormatSettings.Invariant));
end;

procedure TManagerTest.WhenLoadAnObjectWithOrderByMustLoadTheObjectsInTheOrderAsExpected;
begin
  var Objects := FManager.Select.All.From<TAAAA>.OrderBy.Field('Id', False).Open.All;

  Assert.AreEqual(10, Objects[0].Id);
  Assert.AreEqual(8, Objects[1].Id);
  Assert.AreEqual(5, Objects[2].Id);
  Assert.AreEqual(3, Objects[3].Id);
  Assert.AreEqual(1, Objects[4].Id);
end;

procedure TManagerTest.WhenSaveAnObjectThatAlreadyInTheDatabaseMustUpdateTheFieldsOfTheObject;
begin
  var &Object := TInsertAutoGenerated.Create;

  FManager.Insert(&Object);

  &Object.Value := 1234;

  FManager.Save(&Object);

  var Cursor := FManager.OpenCursor('select Value from InsertAutoGenerated');

  Cursor.Next;

  Assert.AreEqual(1234, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenSaveAnObjectThatWasntInsertedMustInsertTheObject;
begin
  var &Object := TInsertAutoGenerated.Create;

  FManager.Save(&Object);

  var Cursor := FManager.OpenCursor('select count(*) from InsertAutoGenerated');

  Cursor.Next;

  Assert.AreEqual(1, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenTheOrderByHasMoreThenOneFieldMustExecuteAsExpected;
begin
  var Objects := FManager.Select.All.From<TAAAA>.OrderBy.Field('Value').Field('Id', False).Open.All;

  Assert.AreEqual(10, Objects[0].Id);
  Assert.AreEqual('AAA', Objects[0].Value);
  Assert.AreEqual(5, Objects[1].Id);
  Assert.AreEqual('AAA', Objects[1].Value);
  Assert.AreEqual(1, Objects[2].Id);
  Assert.AreEqual('AAA', Objects[2].Value);
  Assert.AreEqual(8, Objects[3].Id);
  Assert.AreEqual('BBB', Objects[3].Value);
  Assert.AreEqual(3, Objects[4].Id);
  Assert.AreEqual('BBB', Objects[4].Value);
end;

procedure TManagerTest.WhenTryToUpdateAForeignObjectMustRaiseErrorExplainingThisNotAllowed;
begin
  var &Object := TInsertTest.Create;
  &Object.Id := 'abc';

  Assert.WillRaise(
    procedure
    begin
      FManager.Update(&Object);
    end, EForeignObjectNotAllowed);

  &Object.Free;
end;

procedure TManagerTest.WhenUpdateAClassThatIsRecursiveInItSelfCantRaiseErrorOfStackOverflow;
begin
  var &Object := TStackOverflowClass.Create;
  &Object.Callback := TStackOverflowClass.Create;
  &Object.Callback.CallBack := &Object;

  FManager.Insert(&Object);

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Update(&Object);
    end);
end;

procedure TManagerTest.WhenUpdateAnInheritedObjectMustUpdateAllClassLevelsToo;
begin
  var InheritedObject := TMyEntityInheritedFromSimpleClass.Create;
  InheritedObject.AnotherProperty := 'aaa';
  InheritedObject.BaseProperty := 'aaa';
  InheritedObject.SimpleProperty := 111;

  FManager.Insert(InheritedObject);

  InheritedObject.AnotherProperty := 'bbb';
  InheritedObject.BaseProperty := 'bbb';
  InheritedObject.SimpleProperty := 222;

  FManager.Update(InheritedObject);

  var Cursor := FManager.OpenCursor('select AnotherProperty, BaseProperty from MyEntityInheritedFromSingle');

  Cursor.Next;

  Assert.AreEqual<String>('bbb', Cursor.GetFieldValue(0));
  Assert.AreEqual<String>('bbb', Cursor.GetFieldValue(1));

  Cursor := FManager.OpenCursor('select SimpleProperty from MyEntityInheritedFromSimpleClass');

  Cursor.Next;

  Assert.AreEqual<Integer>(222, Cursor.GetFieldValue(0));
end;

procedure TManagerTest.WhenUpdateAnObjectMustInsertTheNewObjectInTheForeignKey;
begin
  var ForeignKeyObject := TInsertAutoGenerated.Create;
  var MainObject := TInsertTestWithForeignKey.Create;

  FManager.Insert(MainObject);

  MainObject.FK1 := ForeignKeyObject;

  FManager.Update(MainObject);

  var Cursor := FManager.OpenCursor('select count(*) from InsertAutoGenerated');

  Cursor.Next;

  Assert.AreEqual(1, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenUpdateAnObjectMustUpdateOnlyTheChangedFieldsOfTheObject;
begin
  var &Object := TInsertTest.Create;
  &Object.Id := 'abc';
  &Object.IntegerValue := 111;
  &Object.Value := 111;

  FManager.Insert(&Object);

  &Object.IntegerValue := 3;

  FManager.ExectDirect('update InsertTest set Value = 555');

  FManager.Update(&Object);

  var Cursor := FManager.OpenCursor('select IntegerValue, Value from InsertTest');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual('3', String(Cursor.GetFieldValue(0)));
  Assert.AreEqual('555.000', FormatFloat('0.000', Cursor.GetFieldValue(1), TFormatSettings.Invariant));
end;

procedure TManagerTest.WhenUpdateAnObjectMustUpdateOnlyTheObjectCallInTheProcedure;
begin
  var Object1 := TInsertTest.Create;
  Object1.Id := 'aaa';
  Object1.IntegerValue := 111;
  Object1.Value := 111;
  var Object2 := TInsertTest.Create;
  Object2.Id := 'bbb';
  Object2.IntegerValue := 111;
  Object2.Value := 111;

  FManager.Insert(Object1);

  FManager.Insert(Object2);

  Object2.IntegerValue := 222;
  Object2.Value := 222.333;

  FManager.Update(Object2);

  var Cursor := FManager.OpenCursor('select IntegerValue, Value from InsertTest where Id = ''aaa''');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual('111', String(Cursor.GetFieldValue(0)));
  Assert.AreEqual('111.000', FormatFloat('0.000', Cursor.GetFieldValue(1), TFormatSettings.Invariant));
end;

procedure TManagerTest.WhenUpdateAnObjectMustUpdateTheChangedFieldsOfTheObject;
begin
  var &Object := TInsertTest.Create;
  &Object.Id := 'abc';
  &Object.IntegerValue := 111;
  &Object.Value := 111;

  FManager.Insert(&Object);

  &Object.IntegerValue := 222;
  &Object.Value := 222.333;

  FManager.Update(&Object);

  var Cursor := FManager.OpenCursor('select IntegerValue, Value from InsertTest');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual('222', String(Cursor.GetFieldValue(0)));
  Assert.AreEqual('222.333', FormatFloat('0.000', Cursor.GetFieldValue(1), TFormatSettings.Invariant));
end;

procedure TManagerTest.WhenUpdateAnObjectMustUpdateTheForeignKeyOfTheObjectToo;
begin
  var MainObject := TInsertTestWithForeignKey.Create;
  MainObject.FK1 := TInsertAutoGenerated.Create;

  FManager.Insert(MainObject);

  MainObject.FK1.Value := 123;

  FManager.Update(MainObject);

  var Cursor := FManager.OpenCursor('select Value from InsertAutoGenerated');

  Cursor.Next;

  Assert.AreEqual(123, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenUpdateAnObjectWithManyValueAssociationCantRaiseAnyError;
begin
  var &Object := TMyEntityWithManyValueAssociation.Create;
  &Object.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create, TMyEntityWithManyValueAssociationChild.Create];

  FManager.Insert(&Object);

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Update(&Object);
    end);
end;

procedure TManagerTest.WhenUpdateAnObjectWithManyValueAssociationMustInsertTheNewChildValues;
begin
  var &Object := TMyEntityWithManyValueAssociation.Create;

  FManager.Insert(&Object);

  &Object.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create];

  FManager.Update(&Object);

  var Cursor := FManager.OpenCursor('select count(*) from MyEntityWithManyValueAssociationChild');

  Cursor.Next;

  Assert.AreEqual(1, Integer(Cursor.GetFieldValue(0)));
end;

procedure TManagerTest.WhenUpdateAnObjectWithManyValueAssociationMustUpdateTheChildValues;
begin
  var ChildObject := TMyEntityWithManyValueAssociationChild.Create;
  var &Object := TMyEntityWithManyValueAssociation.Create;
  &Object.ManyValueAssociationList := [ChildObject];

  FManager.Insert(&Object);

  ChildObject.Value := 1234;

  FManager.Update(&Object);

  var Cursor := FManager.OpenCursor('select Value from MyEntityWithManyValueAssociationChild');

  Cursor.Next;

  Assert.AreEqual<Integer>(1234, Cursor.GetFieldValue(0));
end;

procedure TManagerTest.WhenUpdateAnObjectWithoutChangesCanRaiseAnyUpdateError;
begin
  var InheritedObject := TMyEntityInheritedFromSimpleClass.Create;

  FManager.Insert(InheritedObject);

  Assert.WillNotRaise(
    procedure
    begin
      FManager.Update(InheritedObject);
    end);
end;

{ TManagerDatabaseManipulationTest }

procedure TManagerDatabaseManipulationTest.Setup;
begin
  FManager := TManager.Create(CreateConnection, CreateDialect);

  FManager.Mapper.GetTable(TMySQLiteTable);
end;

procedure TManagerDatabaseManipulationTest.TearDown;
begin
  FManager.Free;
end;

procedure TManagerDatabaseManipulationTest.WhenUpdateTheDatabaseCantRaiseAnyError;
begin
  Assert.WillNotRaise(FManager.UpdateDatabaseSchema);
end;

procedure TManagerDatabaseManipulationTest.WhenUpdateTheDatabaseMustCreateTheTablesAfterTheProcessEnd;
begin
  FManager.UpdateDatabaseSchema;

  Assert.WillNotRaise(
    procedure
    begin
      FManager.OpenCursor('select * from MySQLiteTable').Next;
    end);
end;

{ TStateObjectTest }

procedure TStateObjectTest.WhenCheckTheObjectPropertyMustReturnTheObjectPassedInTheConstructor;
begin
  var Mapper := TMapper.Create;
  var &Object := TObject.Create;
  var Table := Mapper.GetTable(TInsertTest);

  var OriginalValue := TStateObject.Create(Table, &Object);

  Assert.AreEqual<TObject>(&Object, OriginalValue.&Object);

  Mapper.Free;

  OriginalValue.Free;
end;

procedure TStateObjectTest.WhenFillAValueMustReturnTheValueWhenRequestIt;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.GetTable(TInsertTest);

  var Field := Table.Field['Id'];
  var OriginalValue := TStateObject.Create(Table, nil);

  OriginalValue.OldValue[Field] := 123;

  Assert.AreEqual(123, OriginalValue.OldValue[Field].AsInteger);

  Mapper.Free;

  OriginalValue.Free;
end;

procedure TStateObjectTest.WhenTheClassIsInheritedFromAnotherClassMustAllocTheChangeBufferForAllFieldsInTheTable;
begin
  var Mapper := TMapper.Create;
  var Table := Mapper.GetTable(TClassLevel4);

  var Field := Table.Field['Id'];
  var OriginalValue := TStateObject.Create(Table, nil);

  Assert.WillNotRaise(
    procedure
    begin
      OriginalValue.OldValue[Field] := 123;
    end);

  Mapper.Free;

  OriginalValue.Free;
end;

end.

