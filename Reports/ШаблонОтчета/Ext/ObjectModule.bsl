﻿

Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;	
	
	СхемаКомпоновкиДанных = ОтчетСсылка.СхемаКомпоновкиДанных.Получить();
	
	ИнформацияОВыполнении = Неопределено;
	
	КликХаусСервер.ВыполнитьЗапросНаСервере(ОтчетСсылка.ТекстЗапроса, ИнформацияОВыполнении);
	
	Если ИнформацияОВыполнении = Неопределено Тогда
		Сообщить("Не удалось получить данные от ClickHouse");
		Возврат;
	КонецЕсли;
	
	ВнешДанные = КликХаусСервер.ПреобразоватьИнформациюОВыполненииВТаблицуЗначений(ИнформацияОВыполнении, СхемаКомпоновкиДанных);	
	
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	МакетКомпоновкиДанных = КомпоновщикМакета.Выполнить(СхемаКомпоновкиДанных, КомпоновщикНастроек.ПолучитьНастройки(), ДанныеРасшифровки);
	
	СтруктураДанных = Новый Структура("ВнешДанные", ВнешДанные);
	
	ПроцессорКомпоновкиДанных = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновкиДанных.Инициализировать(МакетКомпоновкиДанных, СтруктураДанных, ДанныеРасшифровки, Истина);
	
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	ПроцессорВывода.Вывести(ПроцессорКомпоновкиДанных, Истина);
		
КонецПроцедуры

