
/*********
CONCEPT LEVEL check:
PLAUSIBLE_VALUE_HIGH - find any MEASUREMENT records that have VALUE_AS_NUMBER with non-null value > plausible high value

Parameters used in this template:
cdmDatabaseSchema = @cdmDatabaseSchema
conceptId = @conceptId
unitConceptId = @unitConceptId
plausibleValueHigh = @plausibleValueHigh
cdmVersion = @cdmVersion

**********/


SELECT num_violated_rows, CASE WHEN denominator.num_rows = 0 THEN 0 ELSE 1.0*num_violated_rows/denominator.num_rows END  AS pct_violated_rows,
  denominator.num_rows as num_denominator_rows
FROM
(
	SELECT COUNT_BIG(*) AS num_violated_rows
	FROM
	(
		SELECT m.*
    {@cdmVersion == "4"}?{
      FROM @cdmDatabaseSchema.observation m
      WHERE m.observation_concept_id = @conceptId
    }:{
      FROM @cdmDatabaseSchema.measurement m
      WHERE m.measurement_concept_id = @conceptId
    }
		AND m.unit_concept_id = @unitConceptId
		AND m.value_as_number IS NOT NULL
		AND m.value_as_number > @plausibleValueHigh
	) violated_rows
) violated_row_count,
(
  SELECT COUNT_BIG(*) AS num_rows
  {@cdmVersion == "4"}?{
    FROM @cdmDatabaseSchema.observation
    WHERE observation_concept_id = @conceptId
  }:{
    FROM @cdmDatabaseSchema.measurement
    WHERE measurement_concept_id = @conceptId
  }
  AND unit_concept_id = @unitConceptId
  AND value_as_number IS NOT NULL
) denominator
;
