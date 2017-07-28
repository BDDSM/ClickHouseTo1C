﻿

Функция НастройкиСоединенияКорректны(АдресСервера = "", ПортСервера = "", Пользователь = "", Пароль = "", ЗащищенноеСоединение = Ложь, Таймаут = 0) Экспорт 
	
	НастройкиКорректны = Истина;
	
	АдресСервера = Константы.CH_АдресСервера.Получить();
	
	Если ПустаяСтрока(АдресСервера) Тогда
		Сообщить("Не заполнен адрес сервера ClickHouse");
		НастройкиКорректны = Ложь;		
	КонецЕсли;
	
	ПортСервера = Константы.CH_ПортСервера.Получить();
	
	Если Не ЗначениеЗаполнено(ПортСервера) Тогда
		Сообщить("Не заполнен порт сервера ClickHouse");
		НастройкиКорректны = Ложь;	
	КонецЕсли;
	
	Пользователь  = Константы.CH_Пользователь.Получить();
	Пароль = Константы.CH_ПарольПользователя.Получить();
	ЗащищенноеСоединение = Константы.CH_ЗащищенноеСоединение.Получить();
	Таймаут = Константы.CH_Таймаут.Получить();
	
	
	Возврат НастройкиКорректны;
	
КонецФункции

Функция ВыполнитьЗапросНаСервере(ТекстЗапроса, ИнформацияОВыполнении = Неопределено) Экспорт 
	
	АдресСервера = "";
	ПортСервера = 0;
	Пользователь = "";
	Пароль = "";
	ЗащищенноеСоединение = Ложь;
	Таймаут = 0;
	
	Если Не НастройкиСоединенияКорректны(АдресСервера, ПортСервера, Пользователь, Пароль, ЗащищенноеСоединение, Таймаут) Тогда
		Возврат "";
	КонецЕсли;
	
	Если ЗащищенноеСоединение Тогда
		ДанныеЗащищенноеСоединение = Новый ЗащищенноеСоединениеOpenSSL;
	Иначе
		ДанныеЗащищенноеСоединение = Неопределено;
	КонецЕсли;
	
	Соединение = Новый HTTPСоединение(АдресСервера, ПортСервера, Пользователь, Пароль,, Таймаут, ДанныеЗащищенноеСоединение);
	
	ЗапросТекст = КодироватьСтроку(ТекстЗапроса + " FORMAT JSON", СпособКодированияСтроки.КодировкаURL);  
	
	ТекущаяДатаЗапросНачало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Запрос = Новый HTTPЗапрос("?query=" + ЗапросТекст); 
	
	Попытка
		Ответ = Соединение.Получить(Запрос);
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат "";
	КонецПопытки;
	
	ТекущаяДатаЗапросКонец = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	ТекстОтвета = Ответ.ПолучитьТелоКакСтроку();
	
	Если Ответ.КодСостояния = 200 Тогда
		
		Чтение = Новый ЧтениеJSON;
		Чтение.УстановитьСтроку(ТекстОтвета);
		
		ИнформацияОВыполнении = ПрочитатьJSON(Чтение);
		
		Чтение.Закрыть();
		
	КонецЕсли;
	
	ТекущаяДатаЧтениеJSONКонец = ТекущаяУниверсальнаяДатаВМиллисекундах();
	
	Если Не ИнформацияОВыполнении = Неопределено Тогда
		ИнформацияОВыполнении.Вставить("ВремяВыполненияHTTPЗапроса", (ТекущаяДатаЗапросКонец - ТекущаяДатаЗапросНачало) / 1000);
		ИнформацияОВыполнении.Вставить("ВремяЧтенияJSON", (ТекущаяДатаЧтениеJSONКонец - ТекущаяДатаЗапросКонец) / 1000);
	КонецЕсли;
	
	Возврат "Код ответа: " + Ответ.КодСостояния + Символы.ПС + ТекстОтвета;
		
КонецФункции

Функция ПреобразоватьИнформациюОВыполненииВТабличныйДокумент(ИнформацияОВыполнении, РезультатВыполнения) Экспорт 
	
	ТабДок = Новый ТабличныйДокумент;
	Макет = Справочники.CH_Отчеты.ПолучитьМакет("МакетРезультат");
	
	ОбластьШапка = Макет.ПолучитьОбласть("ШапкаГор|Верт");
	ОбластьЗначение = Макет.ПолучитьОбласть("СтрокаГор|Верт");
	ОбластьОтступ = Макет.ПолучитьОбласть("СтрокаГор|СтрВерт");
	ОбластьОшибка = Макет.ПолучитьОбласть("ШапкаГор|ОшибкаВерт");
	
	ТабДок.Вывести(ОбластьОтступ);
	
	Если ИнформацияОВыполнении = Неопределено Тогда
		ОбластьОшибка.Параметры.РезультатВыполнения = РезультатВыполнения;
		ТабДок.Присоединить(ОбластьОшибка);
		
		Возврат ТабДок;
		
	КонецЕсли;
	
	
	Для Каждого СтрокаСтруктуры Из ИнформацияОВыполнении.meta Цикл
		
		ОбластьШапка.Параметры.Заполнить(СтрокаСтруктуры);
		ТабДок.Присоединить(ОбластьШапка);
 
	КонецЦикла;
	
	
	Для Каждого СтрокаДанных Из ИнформацияОВыполнении.data Цикл
		ТабДок.Вывести(ОбластьОтступ);
		
		Для Каждого СтрокаСтруктуры Из ИнформацияОВыполнении.meta Цикл
			ОбластьЗначение.Параметры.ЗначениеДанных =  СтрокаДанных[СтрокаСтруктуры.name];
			ТабДок.Присоединить(ОбластьЗначение);
		КонецЦикла;
		
		
	КонецЦикла;
	
	Возврат ТабДок;
	
КонецФункции




