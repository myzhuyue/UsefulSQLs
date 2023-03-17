/* Author: Derek Zhu
Date: 2023-03-17
Purpose: Calendar table generation
Description:
    Start date: 2023-01-01
    Set days length in 2nd argument of 'Genarate_series' function */

-- FUNCTION: dmt_vx_sales.fn_get_calendar(date, integer)

-- DROP FUNCTION IF EXISTS dmt_vx_sales.fn_get_calendar(date, integer);

CREATE OR REPLACE FUNCTION dmt_vx_sales.fn_get_calendar(start_dt date, days integer)
 RETURNS TABLE(datum date, year double precision, month double precision, day_of_month double precision, week_of_year double precision, iso_day_of_week double precision, year_calendar_week text, day_of_year double precision, quarter_of_year double precision, quartal text, year_quartal text, day_name text, month_name text, year_month text, year_half integer, leap_year boolean, weekend text, cw_start date, cw_end date, month_start date, month_end date)
 LANGUAGE sql
AS $function$

SELECT
  datum,
  EXTRACT(YEAR FROM datum) AS "year",
  EXTRACT(MONTH FROM datum) AS "month",
  EXTRACT(DAY FROM datum) AS day_of_month,
  EXTRACT(WEEK FROM datum) AS week_of_year,
  -- ISO 8601 day of the week numbering, The day of the week as Monday (1) to Sunday (7)
  EXTRACT(ISODOW FROM datum) AS iso_day_of_week,
  -- Standard Gregorian day of the week numbering, The day of the week as Sunday (0) to Saturday (6)
  -- EXTRACT(DOW FROM datum) AS day_of_week,
  -- ISO calendar year and week
  TO_CHAR(datum, 'iyyy/IW') AS year_calendar_week,
  EXTRACT(DOY FROM datum) AS day_of_year,
  EXTRACT(QUARTER FROM datum) AS quarter_of_year,
  'Q' || TO_CHAR(datum, 'Q') AS quartal,
  TO_CHAR(datum, 'yyyy/"Q"Q') AS year_quartal,
  TO_CHAR(datum, 'TMDay') AS day_name,
  TO_CHAR(datum, 'TMMonth') AS month_name,
  TO_CHAR(datum, 'yyyy/mm') AS year_month,
  -- Half year
  CASE WHEN EXTRACT(MONTH FROM datum) < 7 THEN 1 ELSE 2 END AS year_half,
  -- Leap year
  CASE WHEN EXTRACT(YEAR FROM datum)::integer % 4 = 0 THEN TRUE ELSE FALSE END AS leap_year,
  -- Weekend
  CASE WHEN EXTRACT(ISODOW FROM datum) in (6, 7) THEN 'Weekend' ELSE 'Weekday' END AS weekend,
  -- ISO start and end of the week of this date
  datum + (1 - EXTRACT(ISODOW FROM datum))::integer AS cw_start,
  datum + (7 - EXTRACT(ISODOW FROM datum))::integer AS cw_end,
  -- Start and end of the month of this date
  datum + (1 - EXTRACT(DAY FROM datum))::integer AS month_start,
  ((datum + (1 - EXTRACT(DAY FROM datum))::integer + '1 month'::interval)::date - '1 day'::interval)::DATE AS month_end
FROM (
	SELECT start_dt + s.a AS datum
FROM GENERATE_SERIES(0, days) AS s(a)
GROUP BY s.a
) AS calendar
ORDER BY 1;

$function$
;
