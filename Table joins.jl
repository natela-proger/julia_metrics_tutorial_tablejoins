### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 96265874-5d54-11eb-1eb0-1f1f4f0b55d2
begin
	using Pkg
	Pkg.add("DataFrames")
	Pkg.add("CSV")
	Pkg.add("Plots")
end

# ╔═╡ d105ceb6-5d54-11eb-13b4-63cbff4d3770
begin
	using Dates
	using CSV
	using DataFrames
	using Plots
end

# ╔═╡ c76a5d2e-639c-11eb-0184-edbef6db4ef2
md"*Выполнили:* Скворцов Иван, Никулина Евгения, Кордзахия Натела, Татаринов Артем (БЭК-181)" 

# ╔═╡ 4fe84764-5d5e-11eb-3024-31e0b9505741
md"# Используемые пакеты"

# ╔═╡ aabae65e-5d60-11eb-1bf6-1b1db9ee1463
md"# Вводные слова

В данном обзоре функционала Julia мы будем использовать две таблицы, содержащие обезличенные данные одной известной сети магазинов одежды.

Таблица `transactions_footfall` содержит данные по количеству посетителей и транзакций в магазинах сети.

Таблица `events` содержит количество кликов (событий) в приложении, которое продавцы-консультанты используют для работы с клиентами.

Целью нашей работы станет исследование зависимости между **частотой использования приложения** и **конверсией** (отношением кол-ва транзакций к общему числу клиентов).
"

# ╔═╡ 61daeccc-5d5e-11eb-15ff-dd2ea6cace20
md"# Подгрузка датасетов

Данные хранятся в формате `csv`. Для их корректной подгрузки мы задаем формат дат (переменная `dftm`), а также тип первого столбца -- `String`, поскольку ID магазина является категориальной переменной.
"

# ╔═╡ 2a6b4728-5d60-11eb-2b52-fd202a979ad0
dfmt = dateformat"yyyy-mm-dd"

# ╔═╡ d0ed690c-5d54-11eb-317f-292766404960
transactions_footfall = CSV.read("transactions_footfall.csv", DataFrame, types=Dict(1=>String), dateformat=dfmt) # объект Dict в аргументе types задает желательные форматы столбцов

# ╔═╡ d0d19420-5d54-11eb-3a88-b72c160f299e
usage = CSV.read("usage.csv", DataFrame, types=Dict(1=>String), dateformat=dfmt)

# ╔═╡ 7b9ab988-5d62-11eb-240e-d5e0188871ff
md"
# Первичное исследование данных

При помощи функции `describe` выясняем, что имеющиеся данные захватывают период с 1 по 30 ноября 2020 года."

# ╔═╡ 73789694-5d62-11eb-39f3-1b71b1387a03
describe(transactions_footfall)

# ╔═╡ a85b4b34-5d5f-11eb-3875-aba54752e12b
describe(usage)

# ╔═╡ 783d8f8a-5d63-11eb-30a3-fba836f760c5
md"При этом данные по пользованию приложением есть не для всех магазинов: скорее всего, в некоторых из них оно не использовалось вовсе. Это дает нам возможность посмотреть на работу различных типов объединения данных: *left join*, *right join* и *inner join*."

# ╔═╡ fb527712-5d62-11eb-0b18-c57c96010935
length(unique(transactions_footfall.store_id))

# ╔═╡ 2249e9ac-5d63-11eb-1e15-adbc290ab7df
length(unique(usage.store_id))

# ╔═╡ b3e610ec-5d64-11eb-0aaa-fbb9619a4936
md"При помощи операций над множествами мы можем выяснить, насколько полными будут данные после их объединения. Для этого зададим множества значений столбца `store_id` в для обоих датасетов:"

# ╔═╡ 42dc4646-5d64-11eb-2baf-015f759a2996
begin
	stores_in_tf = Set(transactions_footfall.store_id)
	stores_in_ug = Set(usage.store_id)
end

# ╔═╡ 1af80bf0-5d65-11eb-0d17-63353d720eb1
md"В частности, для 76 из 77 магазинов, использовавших приложение в ноябре, имеются данные по трафику и транзакциям:"

# ╔═╡ 3e4dd1ee-5d64-11eb-021e-8f34c40da0a3
intersect(stores_in_tf, stores_in_ug)

# ╔═╡ 653867be-5d65-11eb-2091-89e3ce947048
md"17 магазинов не использовали приложение, но обслуживали посетителей:"

# ╔═╡ 66165a06-5d65-11eb-14b1-d996eb60e56c
setdiff(stores_in_tf, stores_in_ug)

# ╔═╡ b5c9dc8a-5d65-11eb-1e5f-71e4771e5409
md"Опять же, у 1 магазина из использовавших приложение нет данных по числу посетителей (возможно, он не работал, а приложение использовалось для внутренних процессов)."

# ╔═╡ 9b592126-5d65-11eb-27bd-adbaf0581c61
setdiff(stores_in_ug, stores_in_tf)

# ╔═╡ 52080d92-5d66-11eb-245f-91638f919f6d
md"Можем вывести данные по пользованию для этого магазина. Видим, что приложение использовалось всего четыре дня."

# ╔═╡ f2e872b6-5d65-11eb-1913-4503dcea7a9e
usage[usage[!, "store_id"] .== "4659", :]

# ╔═╡ f7076286-5d69-11eb-3005-e9cdc1e55211
md"Наконец, в целом две имеющиеся таблицы покрывают 94 магазина сети:"

# ╔═╡ 078d3798-5d6a-11eb-09d9-87da93fda83f
union(stores_in_ug, stores_in_tf)

# ╔═╡ bd483046-5d66-11eb-22b5-b9b0386b9692
md"# Объединение таблиц (join)

Объединение таблиц обычно понимается в смысле join'ов в том виде, в каком они представлены в языке SQL. Ниже представлено схематическое представление четырех основных типов объединений. В этом разделе мы разберем каждый из них на базе функционала Julia DataFrames.

![joins](https://orkhanalyshov.com/media/uploads/files/joins.png)
"

# ╔═╡ 9b10661a-5d6b-11eb-2695-b32e5d8e70e4
md"## Синтаксис

Объединение таблиц в Julia производится при помощи набора функций, полный перечень которых представлен в [документации](https://dataframes.juliadata.org/stable/man/joins/). Разберем общую логику их синтаксиса.

Функции вида `*join(df1, df2, on = ...)` принимают три обязательных аргумента: *левая (первая) таблица*, *правая (вторая) таблица* и *столбцы-индексы (key columns)*.

Основная сложность может возникнуть при задании столбцов-индексов. Разберем основные случаи, которые встречаются при работе с реальными данными:
- Названия столбцов-индексов **совпадают** в обеих таблицах.
  - Один индекс: `on = :idx_col_name`
  - Несколько индексов: `on = [:idx_col_name1, :idx_col_name2, ...]`
- Названия столбцов-индексов **не совпадают** в обеих таблицах. В таком случае нужно задать соответствие между названиями столбцов в датасетах:
  - Первый способ, кортежи: `on = [(:idx_1_df1, :idx_1_df2), (:idx_2_df1, :idx_2_df2), ...]`
  - Второй способ, словари: `on = [:idx_1_df1 => :idx_1_df2, :idx_2_df1 => :idx_2_df2, ...]`

Иногда бывает необходимо проверить, являются ли сочетания индексов уникальными в каждом из датасетов (например, убедиться, что в таблице встречается лишь одно значение  переменной для пары store_id-date). В таком случае используется дополнительный аргумент функции `*join` -- `validate`, принимающий кортеж из двух логических значений true/false. Первое значение отвечает за проверку уникальности в левом датасете, второе значение -- за проверку уникальности в правом датасете. Если будут обнаружены повторяющиеся индексы, функция выдаст ошибку типа 

`ERROR: ArgumentError: Merge key(s) are not unique in both df1 and df2. First duplicate in df1 at 3. First duplicate in df2 at 3`
"

# ╔═╡ ed38d744-5d67-11eb-2c2b-17b39daad6bd
md"## Inner join

Этот тип объединения подразумевает, что в итоговый датасет включаются только те наблюдения, индексы которых содержатся в обеих таблицах. В нашем случае мы имеем дело с двойным индексом: нам необходимо объединять данные по столбцам *store_id* и *date* одновременно."

# ╔═╡ ecdc3856-5d67-11eb-199e-f97adc1bfcee
inner = innerjoin(usage, transactions_footfall, on = [:store_id, :date])

# ╔═╡ d08869f8-5d68-11eb-2be4-a374d299b641
md"Исходя из нашего знания данных, полученного в предыдущем разделе, мы ожидаем, что inner join позволит получить объединенный датасет для **76 магазинов**, у которых имеются данные и по пользованию, и по посетителям. Проверим, что это действительно так:"

# ╔═╡ ec93af50-5d67-11eb-05a0-1db28fbc0c8d
Set(inner.store_id)

# ╔═╡ ec0af2fa-5d67-11eb-32bc-214e41ec47a8
md"## Full join

Этот тип объединения сохранит все индексы, которые имеются в двух таблицах. При этом недостающие данные будут заполнены пустыми значениями. В Julia соответствующая функция называется `outerjoin` (не путать с настоящим outer join, сохраняющим только наблюдения, индексы которых встречаются лишь в одном из датасетов!)"

# ╔═╡ 44fa01de-5d69-11eb-2c65-9d8caeb1112a
full = outerjoin(usage, transactions_footfall, on = [:store_id, :date])

# ╔═╡ 44e45802-5d69-11eb-3744-b7da7627a568
md"Как и следовало ожидать, полученный датасет включает данные по 94 магазинам:"

# ╔═╡ 44cff20e-5d69-11eb-200e-c1e5ce7c7f84
Set(full.store_id)

# ╔═╡ 44bbc52c-5d69-11eb-31bd-d37a4ea8499d
md"## Left join

Этот тип объединения сохранит все индексы, которые содержатся в левой (первой) таблице. Недостающие данные из правой таблицы будут заполнены пустыми значениями."

# ╔═╡ 44693b72-5d69-11eb-3e95-43a9f012adcb
left = leftjoin(usage, transactions_footfall, on = [:store_id, :date])

# ╔═╡ 8455b2d2-5d6a-11eb-3749-7f09bc737d87
md"Разумеется, полученная таблица содержит данные по 77 магазинам:"

# ╔═╡ 84434554-5d6a-11eb-3f58-71f79d52237e
Set(left.store_id)

# ╔═╡ 842d68d6-5d6a-11eb-10a4-0d2321571d6e
md"## Right join

Этот тип объединения сохранит все индексы, которые содержатся в правой (второй) таблице. Недостающие данные из левой таблицы будут заполнены пустыми значениями."

# ╔═╡ 83e1019c-5d6a-11eb-38b0-e19f9f271e03
right = rightjoin(usage, transactions_footfall, on = [:store_id, :date])

# ╔═╡ bf10e93c-5d6a-11eb-277e-1de238f1c555
md"Полученная таблица содержит данные по 93 магазинам:"

# ╔═╡ a89c8efe-5d6a-11eb-2860-6767e9b76031
Set(right.store_id)

# ╔═╡ a86f1c5a-5d6a-11eb-13b5-47f7b59ea614
md"Поскольку left и right объединения относительны, right join также можно сделать, поменяв порядок таблиц внутри функции `leftjoin`. "

# ╔═╡ a857f938-5d6a-11eb-2130-73d6529537d9
right_alternative = leftjoin(transactions_footfall, usage, on = [:store_id, :date])

# ╔═╡ a8412eb0-5d6a-11eb-1842-ed9a2583408c
Set(right_alternative.store_id)

# ╔═╡ 79301162-5d6b-11eb-16b2-a19850841803
md"Более подробную информацию об объединениях таблиц в Julia DataFrames можно найти [здесь](https://dataframes.juliadata.org/stable/man/joins/)."

# ╔═╡ 2583d2b0-5d6b-11eb-35e1-35b483085f3e
md"# Конкатенация таблиц

Конкатенация таблицы - это простое склеивание вдоль одной из осей. Ниже мы рассмотрим конкатенацию по горизонтали - `hcat()` и по вертикали - `vcat()`. Обе функции происходят от базовой функции `cat(..., dims = (m,n))`, которую удобно использовать, если надо объединить таблицы с тремя и более измерениями. Для тех, кто знаком с питоном - эта фунция полностью аналогична `pd.concat()`

![joins](https://i.ibb.co/NFSP4qf/image.png)"



# ╔═╡ 350a83b2-5d70-11eb-3d4a-cd801bc268ec
md"## По вертикали

Конкатенация по вертикали позволяет объединить два датасета, если у них совпадает количество столбцов (в нашем примере три), при этом количество строк для объединения может быть любым:"

# ╔═╡ 47768ae0-5d73-11eb-1bff-a168c868ef07
a = usage[1:4, :]

# ╔═╡ 46bbd506-5d73-11eb-03c9-73316a55f932
b = usage[5:8, :]

# ╔═╡ 34f88772-5d70-11eb-0948-e19ff61d0231
v_conc = vcat(a,b)

# ╔═╡ 34dfb7b0-5d70-11eb-2807-31dde3f1f3d2
md"## По горизонтали

Конкатенация по горизонтали позволяет объединить два датасета, если у них совпадает количество строк. При этом количество столбцов для объединения может быть любым:"

# ╔═╡ 4622f334-5d73-11eb-2277-cd5a6049d0db
c = usage[:, 1:1]

# ╔═╡ 4611174c-5d73-11eb-1db8-65f15c3841a3
d = usage[:, 2:3]

# ╔═╡ 45fa7816-5d73-11eb-2f77-3b0e0e10fa5f
h_conc = hcat(c,d)

# ╔═╡ f5ab80be-5fbc-11eb-3631-05292cb739c5
md"В [документации](https://docs.julialang.org/en/v1/base/arrays/#Concatenation-and-permutation) можно подробнее прочитать о конкатенации в Julia."

# ╔═╡ 348a414a-5d70-11eb-3ae9-fffe5497977e
md"# Корреляционный анализ

Применяя полученные знания об объединении таблиц, выясним характер взаимосвязи между **частотой использования приложения** и **конверсией**.

Поскольку для этого нам нужны наиболее полные данные, будем использовать inner join для создания рабочего датасета:
"

# ╔═╡ cfe2cc5a-5d54-11eb-0d91-b568ed9aae7e
data = innerjoin(usage, transactions_footfall, on = [:store_id, :date])

# ╔═╡ 916d88e2-5d70-11eb-2b1f-d529130b1155
md"Исключим наблюдения с пропущенными значениями (они встречаются только в столбце `footfall`):"

# ╔═╡ a3dae6e4-5d57-11eb-34b9-b723c2639ce5
dropmissing!(data)

# ╔═╡ 364ac9cc-5d71-11eb-0047-8595df7520f3
md"Исключим наблюдения с нулевым количеством посетителей или транзакций: скорее всего, в такие дни магазин не работал."

# ╔═╡ 35f773bc-5d71-11eb-169f-6fc9ff508c55
begin
	filter!(row -> row.footfall != 0, data)
	filter!(row -> row.transactions != 0, data)
end

# ╔═╡ aa14d1e6-5d70-11eb-2d86-ed9f13e33513
md"Зададим новые переменные: `conversion` (конверсия) и `CPP` (clicks per person, число кликов в приложении на посетителя)."

# ╔═╡ 86ddd0a0-5d58-11eb-38ff-bb9980ad61f6
begin
	data[!, "conversion"] = data.transactions ./ data.footfall
	data[!, "CPP"] = data.events ./ data.footfall
end

# ╔═╡ a3efaaca-5d57-11eb-3d23-c535e3b971d6
data

# ╔═╡ d6d2d6ce-5d70-11eb-3e56-1d24a0f7d104
md"Отфильтруем наблюдения, руководствуясь тем, что конверсия не может превышать 1, а число кликов на посетителя вряд ли превысит 25."

# ╔═╡ 6faf1d30-5d5d-11eb-2bee-75b8bdf318c1
data_clean = data[(data[!, "conversion"] .< 1) .& (data[!, "CPP"] .< 10), :]

# ╔═╡ 0982d144-5d73-11eb-14a5-cf57c0fb38d1
plot(data_clean.CPP, data_clean.conversion, seriestype = :scatter, title = "Clicks-per-person vs. Conversion", dpi = 400, yformatter = y -> string(Int64(floor(y * 100)), "%"), smooth = true, label = "", xlabel = "Clicks-per-person", ylabel = "Conversion")

# ╔═╡ 25bbd8fe-639c-11eb-2507-9dac2bb2e31a
md"Можно заметить, что наблюдается положительная зависимость между интенсивностью пользования приложением и конверсией! Круто!"

# ╔═╡ 67b97322-5d72-11eb-0911-fbfc91084b23
md"**Гетероскедастичность -- это отдельный разговор :)**"

# ╔═╡ Cell order:
# ╟─c76a5d2e-639c-11eb-0184-edbef6db4ef2
# ╟─4fe84764-5d5e-11eb-3024-31e0b9505741
# ╠═96265874-5d54-11eb-1eb0-1f1f4f0b55d2
# ╠═d105ceb6-5d54-11eb-13b4-63cbff4d3770
# ╟─aabae65e-5d60-11eb-1bf6-1b1db9ee1463
# ╟─61daeccc-5d5e-11eb-15ff-dd2ea6cace20
# ╟─2a6b4728-5d60-11eb-2b52-fd202a979ad0
# ╠═d0ed690c-5d54-11eb-317f-292766404960
# ╠═d0d19420-5d54-11eb-3a88-b72c160f299e
# ╟─7b9ab988-5d62-11eb-240e-d5e0188871ff
# ╠═73789694-5d62-11eb-39f3-1b71b1387a03
# ╠═a85b4b34-5d5f-11eb-3875-aba54752e12b
# ╟─783d8f8a-5d63-11eb-30a3-fba836f760c5
# ╠═fb527712-5d62-11eb-0b18-c57c96010935
# ╠═2249e9ac-5d63-11eb-1e15-adbc290ab7df
# ╟─b3e610ec-5d64-11eb-0aaa-fbb9619a4936
# ╠═42dc4646-5d64-11eb-2baf-015f759a2996
# ╟─1af80bf0-5d65-11eb-0d17-63353d720eb1
# ╠═3e4dd1ee-5d64-11eb-021e-8f34c40da0a3
# ╟─653867be-5d65-11eb-2091-89e3ce947048
# ╠═66165a06-5d65-11eb-14b1-d996eb60e56c
# ╟─b5c9dc8a-5d65-11eb-1e5f-71e4771e5409
# ╠═9b592126-5d65-11eb-27bd-adbaf0581c61
# ╟─52080d92-5d66-11eb-245f-91638f919f6d
# ╠═f2e872b6-5d65-11eb-1913-4503dcea7a9e
# ╟─f7076286-5d69-11eb-3005-e9cdc1e55211
# ╠═078d3798-5d6a-11eb-09d9-87da93fda83f
# ╟─bd483046-5d66-11eb-22b5-b9b0386b9692
# ╟─9b10661a-5d6b-11eb-2695-b32e5d8e70e4
# ╟─ed38d744-5d67-11eb-2c2b-17b39daad6bd
# ╠═ecdc3856-5d67-11eb-199e-f97adc1bfcee
# ╟─d08869f8-5d68-11eb-2be4-a374d299b641
# ╠═ec93af50-5d67-11eb-05a0-1db28fbc0c8d
# ╟─ec0af2fa-5d67-11eb-32bc-214e41ec47a8
# ╠═44fa01de-5d69-11eb-2c65-9d8caeb1112a
# ╟─44e45802-5d69-11eb-3744-b7da7627a568
# ╠═44cff20e-5d69-11eb-200e-c1e5ce7c7f84
# ╟─44bbc52c-5d69-11eb-31bd-d37a4ea8499d
# ╠═44693b72-5d69-11eb-3e95-43a9f012adcb
# ╟─8455b2d2-5d6a-11eb-3749-7f09bc737d87
# ╠═84434554-5d6a-11eb-3f58-71f79d52237e
# ╟─842d68d6-5d6a-11eb-10a4-0d2321571d6e
# ╠═83e1019c-5d6a-11eb-38b0-e19f9f271e03
# ╟─bf10e93c-5d6a-11eb-277e-1de238f1c555
# ╠═a89c8efe-5d6a-11eb-2860-6767e9b76031
# ╟─a86f1c5a-5d6a-11eb-13b5-47f7b59ea614
# ╠═a857f938-5d6a-11eb-2130-73d6529537d9
# ╠═a8412eb0-5d6a-11eb-1842-ed9a2583408c
# ╟─79301162-5d6b-11eb-16b2-a19850841803
# ╟─2583d2b0-5d6b-11eb-35e1-35b483085f3e
# ╟─350a83b2-5d70-11eb-3d4a-cd801bc268ec
# ╠═47768ae0-5d73-11eb-1bff-a168c868ef07
# ╠═46bbd506-5d73-11eb-03c9-73316a55f932
# ╠═34f88772-5d70-11eb-0948-e19ff61d0231
# ╟─34dfb7b0-5d70-11eb-2807-31dde3f1f3d2
# ╠═4622f334-5d73-11eb-2277-cd5a6049d0db
# ╠═4611174c-5d73-11eb-1db8-65f15c3841a3
# ╠═45fa7816-5d73-11eb-2f77-3b0e0e10fa5f
# ╟─f5ab80be-5fbc-11eb-3631-05292cb739c5
# ╟─348a414a-5d70-11eb-3ae9-fffe5497977e
# ╠═cfe2cc5a-5d54-11eb-0d91-b568ed9aae7e
# ╟─916d88e2-5d70-11eb-2b1f-d529130b1155
# ╠═a3dae6e4-5d57-11eb-34b9-b723c2639ce5
# ╟─364ac9cc-5d71-11eb-0047-8595df7520f3
# ╠═35f773bc-5d71-11eb-169f-6fc9ff508c55
# ╟─aa14d1e6-5d70-11eb-2d86-ed9f13e33513
# ╠═86ddd0a0-5d58-11eb-38ff-bb9980ad61f6
# ╠═a3efaaca-5d57-11eb-3d23-c535e3b971d6
# ╟─d6d2d6ce-5d70-11eb-3e56-1d24a0f7d104
# ╠═6faf1d30-5d5d-11eb-2bee-75b8bdf318c1
# ╠═0982d144-5d73-11eb-14a5-cf57c0fb38d1
# ╟─25bbd8fe-639c-11eb-2507-9dac2bb2e31a
# ╟─67b97322-5d72-11eb-0911-fbfc91084b23
