-- 1. Підрахунок кількості акаунтів за кожною унікальною комбінацією атрибутів
WITH account AS (
  SELECT
    ss.date AS created_date,                     -- дата створення сесії
    sp.country AS country,                       -- країна користувача
    acc.send_interval,                           -- інтервал розсилки (daily/weekly/etc.)
    acc.is_verified,                             -- чи підтверджено акаунт
    acc.is_unsubscribed,                         -- чи відписаний від розсилки
    COUNT(DISTINCT acc.id) AS account_cnt        -- кількість унікальних акаунтів
  FROM data-analytics-mate.DA.account acc
  JOIN data-analytics-mate.DA.account_session acs
    ON acc.id = acs.account_id
  JOIN data-analytics-mate.DA.session ss
    ON ss.ga_session_id = acs.ga_session_id
  JOIN data-analytics-mate.DA.session_params sp
    ON ss.ga_session_id = sp.ga_session_id
  GROUP BY ss.date, sp.country, acc.send_interval, acc.is_verified, acc.is_unsubscribed
),


-- 2. Метрики взаємодії з email: відправка, відкриття, переходи
email_metrics AS (
  SELECT
    DATE_ADD(ss.date, INTERVAL ems.sent_date DAY) AS sent_date, -- реальна дата відправки (на основі дати сесії + offset)
    sp.country AS country,
    acc.send_interval,
    acc.is_verified,
    acc.is_unsubscribed,
    COUNT(DISTINCT ems.id_message) AS sent_msg,    -- скільки листів було відправлено
    COUNT(DISTINCT emo.id_message) AS open_msg,    -- скільки було відкрито
    COUNT(DISTINCT emv.id_message) AS visit_msg    -- скільки листів призвели до переходів
  FROM data-analytics-mate.DA.email_sent ems
  LEFT JOIN data-analytics-mate.DA.email_open emo
    ON ems.id_message = emo.id_message
  LEFT JOIN data-analytics-mate.DA.email_visit emv
    ON ems.id_message = emv.id_message
  JOIN data-analytics-mate.DA.account_session acs
    ON ems.id_account = acs.account_id
  JOIN data-analytics-mate.DA.account acc
    ON acc.id = acs.account_id
  JOIN data-analytics-mate.DA.session ss
    ON acs.ga_session_id = ss.ga_session_id
  JOIN data-analytics-mate.DA.session_params sp
    ON ss.ga_session_id = sp.ga_session_id
  GROUP BY DATE_ADD(ss.date, INTERVAL ems.sent_date DAY), sp.country, acc.send_interval, acc.is_verified, acc.is_unsubscribed
),


-- 3. Об'єднання метрик акаунтів та email-метрик в один датасет (у вигляді UNION ALL)
unions AS (
  SELECT
    created_date AS date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    NULL AS sent_msg,
    NULL AS open_msg,
    NULL AS visit_msg
  FROM account

  UNION ALL

  SELECT
    sent_date AS date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    NULL AS account_cnt,
    sent_msg,
    open_msg,
    visit_msg
  FROM email_metrics
),


-- 4. Агрегація всіх метрик на рівень однієї дати + групувальних атрибутів
final_groups AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,     -- сумуємо по акаунтах
    SUM(sent_msg) AS sent_msg,           -- по відправлених
    SUM(open_msg) AS open_msg,           -- по відкритих
    SUM(visit_msg) AS visit_msg          -- по переходах
  FROM unions
  GROUP BY date, country, send_interval, is_verified, is_unsubscribed
),


-- 5.1 Додаємо сумарні значення по країнах (віконні функції)
country_sums AS (
  SELECT
    *,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,  -- загальна кількість акаунтів у країні
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt         -- загальна кількість email-ів у країні
  FROM final_groups
),


-- 5.2 Ранжуємо країни за загальними метриками (на рівні всієї країни)
country_totals AS (
  SELECT
    *,
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,  -- місце в рейтингу по акаунтах
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt          -- місце по email-кампаніях
  FROM country_sums
)


-- 6. Фінальний запит: обираємо ТОР-10 країн за кількістю акаунтів або email-ів
SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  account_cnt,
  sent_msg,
  open_msg,
  visit_msg,
  total_country_account_cnt,
  total_country_sent_cnt,
  rank_total_country_account_cnt,
  rank_total_country_sent_cnt
FROM country_totals
WHERE rank_total_country_account_cnt <= 10     -- Топ-10 по акаунтах
   OR rank_total_country_sent_cnt <= 10        -- або по email-ів
ORDER BY date, country                          -- впорядкування по даті і країні
