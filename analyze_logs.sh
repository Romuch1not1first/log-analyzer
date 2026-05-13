#!/bin/bash

LOG_FILE="access.log"
REPORT_FILE="report.txt"

# Проверка, существует ли файл логов
if [ ! -f "$LOG_FILE" ]; then
    echo "Ошибка: Файл $LOG_FILE не найден в текущей директории!"
    exit 1
fi

echo "Начинаю анализ логов..."

# 1. Подсчет общего количества запросов
# Используем wc -l для простого подсчета строк
TOTAL_REQUESTS=$(wc -l < "$LOG_FILE")

# 2. Подсчет количества уникальных IP-адресов (Строго awk)
# Создаем ассоциативный массив, где ключи - это IP (1 столбец). length() считает количество ключей.
UNIQUE_IPS=$(awk '{ips[$1]} END {print length(ips)}' "$LOG_FILE")

# Начинаем запись в файл отчета (перезаписываем, если он уже существует)
> "$REPORT_FILE"
echo "=== Отчет по анализу логов ===" >> "$REPORT_FILE"
echo "Общее количество запросов: $TOTAL_REQUESTS" >> "$REPORT_FILE"
echo "Количество уникальных IP-адресов: $UNIQUE_IPS" >> "$REPORT_FILE"
echo "--------------------------------" >> "$REPORT_FILE"

# 3. Подсчет количества запросов по методам (Строго awk)
# Удаляем кавычку из 6-го столбца (например, "GET -> GET) и считаем совпадения
echo "Запросы по методам:" >> "$REPORT_FILE"
awk '{ 
    gsub(/"/, "", $6); 
    methods[$6]++ 
} END { 
    for (m in methods) 
        print m ": " methods[m] 
}' "$LOG_FILE" >> "$REPORT_FILE"
echo "--------------------------------" >> "$REPORT_FILE"

# 4. Поиск самого популярного URL (Строго awk)
# Считаем частоту каждого URL (7 столбец), находим максимальное значение и выводим
echo "Самый популярный URL:" >> "$REPORT_FILE"
awk '{
    urls[$7]++
} END {
    max=0; 
    pop_url=""; 
    for (u in urls) {
        if (urls[u] > max) {
            max = urls[u]; 
            pop_url = u;
        }
    }
    print pop_url " (" max " запросов)"
}' "$LOG_FILE" >> "$REPORT_FILE"

echo "Анализ завершен. Результаты сохранены в $REPORT_FILE"

# Вывод результатов в консоль для наглядности (опционально)
echo ""
cat "$REPORT_FILE"
