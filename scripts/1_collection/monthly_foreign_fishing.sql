WITH
  eez_info AS(
  SELECT
    CAST(eez_id AS STRING) AS eez_id,
    sovereign1 AS country,
    sovereign1_iso3 AS eez_iso3
  FROM
    `world-fishing-827.gfw_research.eez_info`),
  #
  #
  #
  #
  ########
  vessel_info AS (
  SELECT
    year,
    ssvid,
    best.best_flag AS flag
  FROM
    `world-fishing-827.gfw_research.vi_ssvid_byyear`),
  #
  #
  #
  #
  ########
  eez_vessel_hours AS(
  SELECT
    ssvid,
    EXTRACT(YEAR
    FROM
      timestamp) AS year,
    EXTRACT(MONTH
    FROM
      timestamp) AS month,
    ROUND(SUM(hours), 2) AS total_hours,
    eez AS eez_id
  FROM
    `world-fishing-827.gfw_research.pipe_production_b_fishing`
  CROSS JOIN
    UNNEST(regions.eez) AS eez
  WHERE
    _PARTITIONTIME < TIMESTAMP("2019-01-01")
    AND nnet_score > 0.5
  GROUP BY
    ssvid,
    year,
    month,
    eez_id),
  #
  #
  #
  #
  ########
  eez_hours_by_foreign AS (
  SELECT
    year,
    month,
    eez_iso3,
    ROUND(SUM(total_hours), 2) AS hours_by_foreign
  FROM
    eez_vessel_hours
  JOIN
    eez_info
  USING
    (eez_id)
  LEFT JOIN
    vessel_info
  USING
    (year,
      ssvid)
  WHERE
    NOT eez_iso3 = flag
    OR flag IS NULL
  GROUP BY
    year,
    month,
    eez_iso3
  ORDER BY
    eez_iso3,
    year),
  #
  #
  #
  #
  ########
  eez_hours_by_self AS (
  SELECT
    year,
    month,
    eez_iso3,
    ROUND(SUM(total_hours),2) AS hours_by_self
  FROM
    eez_vessel_hours
  JOIN
    eez_info
  USING
    (eez_id)
  JOIN
    vessel_info
  USING
    (year,
      ssvid)
  WHERE
    eez_iso3 = flag
  GROUP BY
    year,
    month,
    eez_iso3
  ORDER BY
    eez_iso3,
    year),
  #
  #
  #
  #
  ########
  yearly_eez_hours AS (
  SELECT
    year,
    month,
    eez_iso3,
    country,
    ROUND(SUM(total_hours),2) AS total_hours
  FROM
    eez_vessel_hours
  JOIN
    eez_info
  USING
    (eez_id)
  GROUP BY
    year,
    month,
    eez_iso3,
    country
  ORDER BY
    eez_iso3,
    year)
  #
  #
  #
  #
  #
  #
  #
  #####################################
SELECT
  year,
  month,
  eez_iso3,
  country,
  hours_by_self,
  hours_by_foreign,
  total_hours
FROM
  eez_hours_by_foreign
LEFT JOIN
  eez_hours_by_self
USING
  (year,
    month,
    eez_iso3)
JOIN
  yearly_eez_hours
USING
  (year,
    month,
    eez_iso3)
ORDER BY
  year,
  month,
  country