﻿unit Persisto.Manager.Test;

interface

uses DUnitX.TestFramework, Persisto, Persisto.Mapping;

type
  [TestFixture]
  TManagerTest = class
  private
    FConnection: IDatabaseConnection;
    FManager: TManager;

    procedure InsertData;
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
    [Test]
    procedure WhenFilterAFieldMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithLessThanOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithLessThanOrEqualOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithGreaterThanOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithGreaterThanOrEqualOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithNotEqualOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithBetweenOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterWithBitwiseAndOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterWithBitwiseOrOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenMixBitwiseOrAndTheBitwiseAndOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithLikeOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithIsNullOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithLogicalNotOperatorMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithComplexFieldNameMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAFieldWithComplexFieldNameInManyValueAssociationLinkMustReturnTheObjectsInTheFilterAsExpected;
    [Test]
    procedure WhenFilterAComplexFieldFromAnInheritedTableMustReturnTheObjectAsExpected;
    [Test]
    procedure WhenFilterAInheritedFieldMustFilterByThisField;
    [Test]
    procedure WhenTheOrderByClauseHasAComplexFieldNameMustFindTheFieldAndApplyInTheOrderByList;
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

procedure TManagerTest.InsertData;
begin
  var AAAAObject: TAAAA;
  var ClassLevel4: TClassLevel4;
  var NullObject: TClassWithNullableProperty;
  var Manager := TManager.Create(FConnection, CreateDialect);

  AAAAObject := TAAAA.Create;
  AAAAObject.Id := 1;
  AAAAObject.Value := 'AAA';

  Manager.Insert(AAAAObject);

  AAAAObject := TAAAA.Create;
  AAAAObject.Id := 5;
  AAAAObject.Value := 'AAA';

  Manager.Insert(AAAAObject);

  AAAAObject := TAAAA.Create;
  AAAAObject.Id := 10;
  AAAAObject.Value := 'AAA';

  Manager.Insert(AAAAObject);

  AAAAObject := TAAAA.Create;
  AAAAObject.Id := 3;
  AAAAObject.Value := 'BBB';

  Manager.Insert(AAAAObject);

  AAAAObject := TAAAA.Create;
  AAAAObject.Id := 8;
  AAAAObject.Value := 'BBB';

  Manager.Insert(AAAAObject);

  NullObject := TClassWithNullableProperty.Create;
  NullObject.Id := 1;

  Manager.Insert(NullObject);

  NullObject := TClassWithNullableProperty.Create;
  NullObject.Id := 2;
  NullObject.Nullable := 20;

  Manager.Insert(NullObject);

  var ManyObject := TMyManyValue.Create;
  ManyObject.Childs := [TMyChildLink.Create, TMyChildLink.Create, TMyChildLink.Create];
  ManyObject.Childs[0].ManyValueAssociation := TMyEntityWithManyValueAssociation.Create;
  ManyObject.Childs[0].ManyValueAssociation.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create, TMyEntityWithManyValueAssociationChild.Create];
  ManyObject.Childs[0].ManyValueAssociation.ManyValueAssociationList[0].Value := 30;
  ManyObject.Childs[0].ManyValueAssociation.ManyValueAssociationList[1].Value := 20;
  ManyObject.Childs[1].ManyValueAssociation := TMyEntityWithManyValueAssociation.Create;
  ManyObject.Childs[1].ManyValueAssociation.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create];
  ManyObject.Childs[1].ManyValueAssociation.ManyValueAssociationList[0].Value := 40;
  ManyObject.Childs[2].ManyValueAssociation := TMyEntityWithManyValueAssociation.Create;
  ManyObject.Childs[2].ManyValueAssociation.ManyValueAssociationList := [TMyEntityWithManyValueAssociationChild.Create, TMyEntityWithManyValueAssociationChild.Create, TMyEntityWithManyValueAssociationChild.Create];
  ManyObject.Childs[2].ManyValueAssociation.ManyValueAssociationList[0].Value := 50;
  ManyObject.Childs[2].ManyValueAssociation.ManyValueAssociationList[1].Value := 10;
  ManyObject.Childs[2].ManyValueAssociation.ManyValueAssociationList[2].Value := 60;

  Manager.Insert(ManyObject);

  var ManyValueInherited := [TManyValueParentInherited.Create, TManyValueParentInherited.Create];
  ManyValueInherited[0].Childs := [TManyValueChildInherited.Create];
  ManyValueInherited[0].Childs[0].Id := 45;
  ManyValueInherited[0].Childs[0].Value := TClassWithPrimaryKey.Create;
  ManyValueInherited[0].Childs[0].Value.Id := 11;
  ManyValueInherited[0].Childs[0].Value.Value := 25;
  ManyValueInherited[0].Id := 10;
  ManyValueInherited[1].Childs := [TManyValueChildInherited.Create];
  ManyValueInherited[1].Childs[0].Id := 15;
  ManyValueInherited[1].Childs[0].Value := TClassWithPrimaryKey.Create;
  ManyValueInherited[1].Childs[0].Value.Id := 22;
  ManyValueInherited[0].Childs[0].Value.Value := 35;
  ManyValueInherited[1].Id := 20;

  Manager.Insert(ManyValueInherited[0]);

  Manager.Insert(ManyValueInherited[1]);

  ClassLevel4 := TClassLevel4.Create;
  ClassLevel4.Field1 := 'abc';
  ClassLevel4.Field2 := 'efg';
  ClassLevel4.Field3 := 'hij';
  ClassLevel4.Field4 := 'klm';
  ClassLevel4.Id := 1;

  Manager.Insert(ClassLevel4);

  ClassLevel4 := TClassLevel4.Create;
  ClassLevel4.Field1 := 'aaa';
  ClassLevel4.Field2 := 'bbb';
  ClassLevel4.Field3 := 'ccc';
  ClassLevel4.Field4 := 'ddd';
  ClassLevel4.Id := 2;

  Manager.Insert(ClassLevel4);

  var Objects: TArray<TInsertTestWithForeignKey> := [TInsertTestWithForeignKey.Create, TInsertTestWithForeignKey.Create, TInsertTestWithForeignKey.Create];
  Objects[0].FK1 := TInsertAutoGenerated.Create;
  Objects[0].FK1.Value := 20;
  Objects[1].FK1 := TInsertAutoGenerated.Create;
  Objects[1].FK1.Value := 30;
  Objects[2].FK1 := TInsertAutoGenerated.Create;
  Objects[2].FK1.Value := 10;

  FManager.Insert(Objects[0]);

  FManager.Insert(Objects[1]);

  FManager.Insert(Objects[2]);

  Manager.Free;
end;

procedure TManagerTest.PrepareDatabase;
begin
  FManager.Mapper.GetTable(TInsertTestWithForeignKey);

  FManager.Mapper.GetTable(TInsertTest);

  FManager.Mapper.GetTable(TMyEntityInheritedFromSimpleClass);

  FManager.Mapper.GetTable(TStackOverflowClass);

  FManager.Mapper.GetTable(TClassWithForeignKey);

  FManager.Mapper.GetTable(TClassRecursiveThird);

  FManager.Mapper.GetTable(TMyEntityWithManyValueAssociation);

  FManager.Mapper.GetTable(TAAAA);

  FManager.Mapper.GetTable(TClassWithNullableProperty);

  FManager.Mapper.GetTable(TMyManyValue);

  FManager.Mapper.GetTable(TManyValueParentInherited);

  FManager.Mapper.GetTable(TClassLevel4);

  FManager.UpdateDatabaseSchema;
end;

procedure TManagerTest.Setup;
begin
  FConnection := CreateConnection;
  FManager := TManager.Create(FConnection, CreateDialect);

  PrepareDatabase;
end;

procedure TManagerTest.TearDown;
begin
  FConnection := nil;
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
  &Object2.Id := 35;

  FManager.Insert(&Object1);

  FManager.Insert(&Object2);

  &Object1.AnotherClass := &Object2;

  FManager.Update(&Object1);

  var Cursor := FManager.OpenCursor('select IdAnotherClass from ClassWithForeignKey');

  Assert.IsTrue(Cursor.Next);
  Assert.AreEqual<NativeInt>(35, Cursor.GetFieldValue(0));
end;

procedure TManagerTest.WhenFilterAComplexFieldFromAnInheritedTableMustReturnTheObjectAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TManyValueParentInherited>.Where(Field('Childs.Value.Value') = 35).Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(35, Objects[0].Childs[0].Value.Value);
end;

procedure TManagerTest.WhenFilterAFieldMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Id') = 5).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(5, Objects[0].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithBetweenOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Id').Between(3, 8)).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(3, Length(Objects));
  Assert.AreEqual(3, Objects[0].Id);
  Assert.AreEqual(5, Objects[1].Id);
  Assert.AreEqual(8, Objects[2].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithComplexFieldNameInManyValueAssociationLinkMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TMyManyValue>.Where(Field('Childs.ManyValueAssociation.ManyValueAssociationList.Value') = 60).Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(60, Objects[0].Childs[0].ManyValueAssociation.ManyValueAssociationList[0].Value);
end;

procedure TManagerTest.WhenFilterAFieldWithComplexFieldNameMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TInsertTestWithForeignKey>.Where(Field('FK1.Value') = 30).Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(30, Objects[0].FK1.Value);
end;

procedure TManagerTest.WhenFilterAFieldWithGreaterThanOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Id') > 5).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(2, Length(Objects));
  Assert.AreEqual(8, Objects[0].Id);
  Assert.AreEqual(10, Objects[1].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithGreaterThanOrEqualOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Id') >= 5).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(3, Length(Objects));
  Assert.AreEqual(5, Objects[0].Id);
  Assert.AreEqual(8, Objects[1].Id);
  Assert.AreEqual(10, Objects[2].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithIsNullOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TClassWithNullableProperty>.Where(Field('Nullable').IsNull).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(1, Objects[0].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithLessThanOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Id') < 5).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(2, Length(Objects));
  Assert.AreEqual(1, Objects[0].Id);
  Assert.AreEqual(3, Objects[1].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithLessThanOrEqualOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Id') <= 5).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(3, Length(Objects));
  Assert.AreEqual(1, Objects[0].Id);
  Assert.AreEqual(3, Objects[1].Id);
  Assert.AreEqual(5, Objects[2].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithLikeOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Value').Like('B__')).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(2, Length(Objects));
  Assert.AreEqual(3, Objects[0].Id);
  Assert.AreEqual(8, Objects[1].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithLogicalNotOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TClassWithNullableProperty>.Where(not Field('Nullable').IsNull).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(2, Objects[0].Id);
end;

procedure TManagerTest.WhenFilterAFieldWithNotEqualOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(Field('Id') <> 5).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(4, Length(Objects));
  Assert.AreEqual(1, Objects[0].Id);
  Assert.AreEqual(3, Objects[1].Id);
  Assert.AreEqual(8, Objects[2].Id);
  Assert.AreEqual(10, Objects[3].Id);
end;

procedure TManagerTest.WhenFilterAInheritedFieldMustFilterByThisField;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TClassLevel4>.Where(Field('Field1') = 'abc').Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual('abc', Objects[0].Field1);
end;

procedure TManagerTest.WhenFilterWithBitwiseAndOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where((Field('Id') < 10) and (Field('Id') > 5)).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(8, Objects[0].Id);
end;

procedure TManagerTest.WhenFilterWithBitwiseOrOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where((Field('Id') = 10) or (Field('Id') = 5)).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(2, Length(Objects));
  Assert.AreEqual(5, Objects[0].Id);
  Assert.AreEqual(10, Objects[1].Id);
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
  &Object.AnotherClass.Id := 35;

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
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.OrderBy.Field('Id', False).Open.All;

  Assert.AreEqual(10, Objects[0].Id);
  Assert.AreEqual(8, Objects[1].Id);
  Assert.AreEqual(5, Objects[2].Id);
  Assert.AreEqual(3, Objects[3].Id);
  Assert.AreEqual(1, Objects[4].Id);
end;

procedure TManagerTest.WhenMixBitwiseOrAndTheBitwiseAndOperatorMustReturnTheObjectsInTheFilterAsExpected;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TAAAA>.Where(((Field('Id') = 10) or (Field('Id') = 3)) and (Field('Id') < 5)).OrderBy.Field('Id').Open.All;

  Assert.AreEqual<NativeInt>(1, Length(Objects));
  Assert.AreEqual(3, Objects[0].Id);
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

procedure TManagerTest.WhenTheOrderByClauseHasAComplexFieldNameMustFindTheFieldAndApplyInTheOrderByList;
begin
  InsertData;

  var Objects := FManager.Select.All.From<TInsertTestWithForeignKey>.OrderBy.Field('FK1.Value').Open.All;

  Assert.AreEqual(10, Objects[0].FK1.Value);
  Assert.AreEqual(20, Objects[1].FK1.Value);
  Assert.AreEqual(30, Objects[2].FK1.Value);
end;

procedure TManagerTest.WhenTheOrderByHasMoreThenOneFieldMustExecuteAsExpected;
begin
  InsertData;

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

