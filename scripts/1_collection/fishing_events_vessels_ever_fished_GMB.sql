WITH
  eez_info AS (
  SELECT
    CAST(eez_id AS STRING) eez_id,
    sovereign1_iso3 AS eez_iso3,
    sovereign1 AS eez
  FROM
    `world-fishing-827.gfw_research.eez_info` ),
  #
  #
  #
  #
  ########
  vessels_fished_in_gambia AS(
  SELECT
    DISTINCT(ssvid) AS ssvid
  FROM
    `world-fishing-827.gfw_research.vi_ssvid_byyear`
  CROSS JOIN
    UNNEST(activity.eez) AS eez
  WHERE
    eez.value = "8370" # Code for the GMB eez
    AND eez.fishing_hours > 1),
  #
  #
  #
  #
  ########
  vessel_tracks AS (
  SELECT
    ssvid,
    EXTRACT(YEAR
    FROM
      _Partitiontime) AS year,
    timestamp,
    lon,
    lat,
    nnet_score,
    hours,
    IF(ARRAY_LENGTH(regions.eez) = 0,
      "0000",
      regions.eez[ORDINAL(1)]) AS eez_id
  FROM
    `world-fishing-827.gfw_research.pipe_production_b_fishing`
  WHERE
    nnet_score > 0.5 #Keep only fishing events
    AND ssvid IN (
    SELECT
      ssvid
    FROM
      vessels_fished_in_gambia) #Keep only vessels that fished in Gambia
    ),
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
    `world-fishing-827.gfw_research.vi_ssvid_byyear`
  WHERE
    ssvid IN (
    SELECT
      ssvid
    FROM
      vessels_fished_in_gambia) #Keep only vessels that fished in Gambia
    )
  #
  #
  #
  #
  ########
SELECT
  ssvid,
  timestamp,
  lon,
  lat,
  nnet_score,
  hours,
  flag,
  IF(eez IS NULL,
    "High Seas",
    eez) AS eez,
  IF(eez_iso3 IS NULL,
    "HS",
    eez_iso3) AS eez_iso3
FROM
  vessel_tracks
LEFT JOIN
  eez_info
USING
  (eez_id)
LEFT JOIN
  vessel_info
USING
  (year,
    ssvid)
