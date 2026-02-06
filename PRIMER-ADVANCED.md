# Annotation Context Ontology - Advanced Topics and Integration Guide

**Version:** 1.0.0  
**Date:** 2026-02-05

---

## Table of Contents

1. [Advanced Context Patterns](#1-advanced-context-patterns)
2. [Integration with W3C Standards](#2-integration-with-w3c-standards)
3. [Custom SHACL Rules](#3-custom-shacl-rules)
4. [Performance Optimization](#4-performance-optimization)
5. [Real-World Case Studies](#5-real-world-case-studies)
6. [Building Context-Aware Applications](#6-building-context-aware-applications)
7. [Advanced Query Techniques](#7-advanced-query-techniques)
8. [Extending ACO](#8-extending-aco)

---

## 1. Advanced Context Patterns

### 1.1 Fuzzy Contexts with Membership Degrees

For contexts with gradual boundaries rather than sharp cutoffs:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix fuzzy: <http://example.org/fuzzy/> .
@prefix temp: <http://example.org/temperature/> .

# Define fuzzy temperature contexts
ctx:ColdTemperature a ctx:Context ;
    rdfs:label "Cold Temperature" ;
    fuzzy:centerPoint 10 ;  # Celsius
    fuzzy:spread 15 .

ctx:WarmTemperature a ctx:Context ;
    rdfs:label "Warm Temperature" ;
    fuzzy:centerPoint 25 ;
    fuzzy:spread 10 .

ctx:HotTemperature a ctx:Context ;
    rdfs:label "Hot Temperature" ;
    fuzzy:centerPoint 35 ;
    fuzzy:spread 10 .

# Temperature reading with fuzzy membership
temp:Reading_2024_06_15 temp:hasValue 20 
    ~ _:cold {| 
        ctx:holdsIn ctx:ColdTemperature ;
        fuzzy:membershipDegree 0.33 ;
        rdfs:comment "Partially cold"
    |},
    ~ _:warm {| 
        ctx:holdsIn ctx:WarmTemperature ;
        fuzzy:membershipDegree 0.67 ;
        rdfs:comment "Mostly warm"
    |} .
```

**Query for fuzzy context matching:**

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX fuzzy: <http://example.org/fuzzy/>

SELECT ?reading ?context ?membership
WHERE {
    ?reading temp:hasValue ?value .
    ?stmt rdf:reifies << ?reading temp:hasValue ?value >> ;
          ctx:holdsIn ?context ;
          fuzzy:membershipDegree ?membership .
    
    FILTER(?membership > 0.5)  # Only contexts where reading is "mostly" a member
}
ORDER BY DESC(?membership)
```

### 1.2 Probabilistic Context Transitions

Model transitions between contexts with probability distributions:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix trans: <http://example.org/transition/> .
@prefix prob: <http://example.org/probability/> .

# Define state contexts
ctx:HealthyState a ctx:Context ;
    rdfs:label "Healthy State" .

ctx:InfectedState a ctx:Context ;
    rdfs:label "Infected State" .

ctx:RecoveredState a ctx:Context ;
    rdfs:label "Recovered State" .

# Define transition probabilities
trans:HealthyToInfected a trans:Transition ;
    trans:fromContext ctx:HealthyState ;
    trans:toContext ctx:InfectedState ;
    prob:probability 0.15 ;
    trans:triggerCondition [
        :exposureToVirus true
    ] .

trans:InfectedToRecovered a trans:Transition ;
    trans:fromContext ctx:InfectedState ;
    trans:toContext ctx:RecoveredState ;
    prob:probability 0.95 ;
    trans:meanDuration "P14D"^^xsd:duration .

# Entity with state tracking
:Patient123 :healthStatus :healthy 
    ~ _:currentState {| 
        ctx:holdsIn ctx:HealthyState ;
        prov:generatedAtTime "2024-01-01"^^xsd:date
    |} .
```

**SHACL Rule for automatic state transition:**

```turtle
ctx:StateTransitionRule a sh:SPARQLRule ;
    sh:construct """
        PREFIX ctx: <http://ontologist.substack.com/ns/context#>
        PREFIX trans: <http://example.org/transition/>
        PREFIX prov: <http://www.w3.org/ns/prov#>
        
        CONSTRUCT {
            ?entity ?property ?newValue ~ _:newState {|
                ctx:holdsIn ?toContext ;
                prov:generatedAtTime ?now ;
                trans:transitionedFrom ?fromContext ;
                trans:probability ?prob
            |} .
        }
        WHERE {
            # Current state
            ?entity ?property ?currentValue .
            ?currentStmt rdf:reifies << ?entity ?property ?currentValue >> ;
                         ctx:holdsIn ?fromContext .
            
            # Find applicable transition
            ?transition trans:fromContext ?fromContext ;
                       trans:toContext ?toContext ;
                       prob:probability ?prob ;
                       trans:triggerCondition ?condition .
            
            # Check if conditions are met
            ?entity ?condProp ?condValue .
            ?condition ?condProp ?condValue .
            
            BIND(NOW() AS ?now)
            BIND(?newValue AS ?currentValue)  # Placeholder for actual new value
        }
    """ .
```

### 1.3 Nested Contexts with Scope Inheritance

Complex scenarios with nested context scopes:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix org: <http://example.org/organization/> .

# Organizational hierarchy contexts
ctx:GlobalPolicy a ctx:Context ;
    rdfs:label "Global Company Policy" .

ctx:NorthAmericaRegion a ctx:Context ;
    rdfs:label "North America Region" ;
    ctx:subsumes ctx:USACountry, ctx:CanadaCountry .

ctx:USACountry a ctx:Context ;
    rdfs:label "USA Country" ;
    ctx:subsumes ctx:CaliforniaState .

ctx:CaliforniaState a ctx:Context ;
    rdfs:label "California State" ;
    ctx:subsumes ctx:SanFranciscoOffice .

ctx:SanFranciscoOffice a ctx:Context ;
    rdfs:label "San Francisco Office" .

# Set up inheritance chain
ctx:GlobalPolicy ctx:subsumes ctx:NorthAmericaRegion .
ctx:NorthAmericaRegion ctx:subsumes ctx:USACountry .

# Policy at global level
org:Policy_DataRetention org:hasValue "7 years" 
    ~ _:global {| 
        ctx:holdsIn ctx:GlobalPolicy ;
        ctx:confidence 1.0 ;
        rdfs:comment "Default global policy"
    |} .

# Override at California level (stricter)
org:Policy_DataRetention org:hasValue "3 years" 
    ~ _:california {| 
        ctx:holdsIn ctx:CaliforniaState ;
        ctx:confidence 1.0 ;
        ctx:overrides _:global ;
        rdfs:comment "California CCPA requires shorter retention"
    |} .
```

**Query for effective policy at a specific location:**

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX org: <http://example.org/organization/>

SELECT ?policy ?value ?applicableContext ?specificity
WHERE {
    VALUES ?location { ctx:SanFranciscoOffice }
    
    # Find policy values
    org:Policy_DataRetention org:hasValue ?value .
    ?stmt rdf:reifies << org:Policy_DataRetention org:hasValue ?value >> ;
          ctx:holdsIn ?applicableContext .
    
    # Check if context applies to location
    {
        # Direct match
        FILTER(?applicableContext = ?location)
        BIND(0 AS ?specificity)
    } UNION {
        # Through subsumption hierarchy
        ?applicableContext ctx:subsumes+ ?location .
        # Calculate specificity (distance in hierarchy)
        SELECT (COUNT(?intermediate) AS ?specificity)
        WHERE {
            ?applicableContext ctx:subsumes+ ?intermediate .
            ?intermediate ctx:subsumes* ?location .
        }
    }
}
ORDER BY ?specificity  # Most specific context wins
LIMIT 1
```

### 1.4 Temporal Context Versioning

Track how contexts themselves evolve over time:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix temp: <http://example.org/temporal/> .
@prefix prov: <http://www.w3.org/ns/prov#> .

# Version 1 of context definition
ctx:AdultStage_v1 a ctx:TemporalContext ;
    rdfs:label "Adult Stage (Version 1)" ;
    ctx:requires [ :ageInYears [ sh:minInclusive 18 ] ] ;
    temp:validFrom "1900-01-01"^^xsd:date ;
    temp:validUntil "2020-12-31"^^xsd:date ;
    prov:wasRevisionOf ctx:AdultStage .

# Version 2 of context definition (updated criteria)
ctx:AdultStage_v2 a ctx:TemporalContext ;
    rdfs:label "Adult Stage (Version 2)" ;
    ctx:requires [ :ageInYears [ sh:minInclusive 21 ] ] ;
    temp:validFrom "2021-01-01"^^xsd:date ;
    prov:wasRevisionOf ctx:AdultStage_v1 ;
    rdfs:comment "Updated definition to reflect new legal adult age" .

# Statement using versioned context
:Person123 :canVote true 
    ~ {| 
        ctx:holdsIn ctx:AdultStage_v2 ;
        prov:generatedAtTime "2024-06-15"^^xsd:date
    |} .
```

---

## 2. Integration with W3C Standards

### 2.1 PROV-O Integration

Full provenance tracking with ACO:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix prov: <http://www.w3.org/ns/prov#> .

# Define provenance-based contexts
ctx:ExperimentalData a ctx:EpistemicContext ;
    rdfs:label "Experimental Data" ;
    prov:wasGeneratedBy :Experiment_2024_001 .

# Measurement with full provenance
:Measurement_001 :temperature 22.5 
    ~ _:measurement {| 
        ctx:holdsIn ctx:ExperimentalData ;
        prov:wasGeneratedBy :Experiment_2024_001 ;
        prov:wasAttributedTo :Dr_Jane_Smith ;
        prov:generatedAtTime "2024-01-15T14:30:00Z"^^xsd:dateTime ;
        prov:used :Thermometer_SN12345 ;
        prov:wasAssociatedWith :LabProtocol_v2 ;
        prov:atLocation :Lab_RoomB_Bench3 ;
        ctx:confidence 0.95
    |} .

# Activity that generated the measurement
:Experiment_2024_001 a prov:Activity ;
    prov:startedAtTime "2024-01-15T14:00:00Z"^^xsd:dateTime ;
    prov:endedAtTime "2024-01-15T16:00:00Z"^^xsd:dateTime ;
    prov:wasAssociatedWith :Dr_Jane_Smith ;
    prov:used :Thermometer_SN12345 ;
    prov:qualifiedUsage [
        a prov:Usage ;
        prov:entity :Thermometer_SN12345 ;
        prov:hadRole :Instrument
    ] .

# Agent (scientist)
:Dr_Jane_Smith a prov:Agent, prov:Person ;
    prov:actedOnBehalfOf :University_XYZ ;
    :hasCredential :PhD_Chemistry .

# Instrument
:Thermometer_SN12345 a prov:Entity ;
    :calibratedOn "2023-12-01"^^xsd:date ;
    :accuracy "±0.1°C" ;
    :manufacturer :TechCorp .
```

**Query for measurements with complete provenance:**

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX prov: <http://www.w3.org/ns/prov#>

SELECT ?measurement ?value ?scientist ?instrument ?time ?confidence
WHERE {
    ?measurement :temperature ?value .
    ?stmt rdf:reifies << ?measurement :temperature ?value >> ;
          ctx:holdsIn ?context ;
          ctx:confidence ?confidence ;
          prov:wasAttributedTo ?scientist ;
          prov:used ?instrument ;
          prov:generatedAtTime ?time .
    
    ?context a ctx:EpistemicContext .
}
ORDER BY DESC(?time)
```

### 2.2 OWL-Time Integration

Sophisticated temporal contexts using OWL-Time:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix time: <http://www.w3.org/2006/time#> .
@prefix temp: <http://example.org/temporal/> .

# Define temporal intervals
:BusinessHours a time:ProperInterval ;
    time:hasBeginning [
        a time:Instant ;
        time:inXSDDateTimeStamp "2024-01-15T09:00:00-08:00"^^xsd:dateTimeStamp
    ] ;
    time:hasEnd [
        a time:Instant ;
        time:inXSDDateTimeStamp "2024-01-15T17:00:00-08:00"^^xsd:dateTimeStamp
    ] ;
    time:hasDuration [
        a time:Duration ;
        time:numericDuration "8"^^xsd:decimal ;
        time:unitType time:unitHour
    ] .

# Context tied to OWL-Time interval
ctx:DuringBusinessHours a ctx:TemporalContext ;
    rdfs:label "During Business Hours" ;
    temp:validDuring :BusinessHours .

# Recurrent temporal context
:WeekdayPattern a time:DayOfWeek ;
    time:dayOfWeek time:Monday, time:Tuesday, time:Wednesday, 
                   time:Thursday, time:Friday .

ctx:Weekdays a ctx:TemporalContext ;
    rdfs:label "Weekdays" ;
    temp:hasRecurrence :WeekdayPattern .

# Policy that only applies during business hours on weekdays
:AccessPolicy :allowsAccess :Building_A 
    ~ {| 
        ctx:holdsIn ctx:DuringBusinessHours ;
        ctx:holdsIn ctx:Weekdays ;
        rdfs:comment "Building access restricted to business hours on weekdays"
    |} .
```

**SHACL constraint using OWL-Time:**

```turtle
ctx:TemporalOverlapConstraint a sh:NodeShape ;
    sh:targetSubjectsOf ctx:holdsIn ;
    sh:sparql [
        sh:message "Temporal contexts {?ctx1} and {?ctx2} overlap but are marked as exclusive" ;
        sh:select """
            PREFIX ctx: <http://ontologist.substack.com/ns/context#>
            PREFIX time: <http://www.w3.org/2006/time#>
            PREFIX temp: <http://example.org/temporal/>
            
            SELECT $this ?ctx1 ?ctx2
            WHERE {
                $this ctx:holdsIn ?ctx1, ?ctx2 .
                ?ctx1 ctx:excludes ?ctx2 .
                
                # Both are temporal contexts
                ?ctx1 a ctx:TemporalContext ;
                      temp:validDuring ?interval1 .
                ?ctx2 a ctx:TemporalContext ;
                      temp:validDuring ?interval2 .
                
                # Check for temporal overlap
                ?interval1 time:intervalOverlaps|time:intervalEquals ?interval2 .
            }
        """ ;
    ] .
```

### 2.3 SKOS Integration

Organize contexts using SKOS concept schemes:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .

# SKOS concept scheme for contexts
:ContextScheme a skos:ConceptScheme ;
    skos:prefLabel "ACO Context Taxonomy"@en ;
    skos:hasTopConcept ctx:TemporalContext, ctx:SpatialContext, 
                        ctx:EpistemicContext, ctx:ModalContext .

# Map contexts to SKOS concepts
ctx:TemporalContext a ctx:Context, skos:Concept ;
    skos:inScheme :ContextScheme ;
    skos:prefLabel "Temporal Context"@en ;
    skos:definition "Context defined by temporal boundaries"@en ;
    skos:narrower ctx:ChildhoodStage, ctx:AdultStage .

ctx:ChildhoodStage a ctx:TemporalContext, skos:Concept ;
    skos:inScheme :ContextScheme ;
    skos:prefLabel "Childhood Stage"@en ;
    skos:broader ctx:TemporalContext ;
    skos:related ctx:DevelopmentalPeriod .

# Use SKOS mapping for context alignment
ctx:AdultStage_ACO a ctx:TemporalContext ;
    skos:exactMatch <http://other-ontology.org/Adult> ;
    skos:closeMatch <http://another-ontology.org/Maturity> .
```

---

## 3. Custom SHACL Rules

### 3.1 Context-Aware Validation Rules

Create custom validation rules that respect context:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix sh: <http://www.w3.org/ns/shacl#> .

# Rule: Age must be appropriate for context
ctx:AgeContextValidationRule a sh:NodeShape ;
    sh:targetClass :Person ;
    sh:sparql [
        sh:message "Person's age {?age} is incompatible with context {?context}" ;
        sh:select """
            PREFIX ctx: <http://ontologist.substack.com/ns/context#>
            
            SELECT $this ?age ?context
            WHERE {
                # Get person's age
                $this :hasAge ?age .
                
                # Get statement about person in a context
                ?stmt rdf:reifies << $this ?prop ?value >> ;
                      ctx:holdsIn ?context .
                
                # Get context requirements
                ?context ctx:requires ?req .
                ?req :ageInYears ?ageConstraint .
                
                # Check if age violates constraint
                ?ageConstraint sh:minInclusive ?min .
                FILTER(?age < ?min)
            }
            UNION
            {
                $this :hasAge ?age .
                ?stmt rdf:reifies << $this ?prop ?value >> ;
                      ctx:holdsIn ?context .
                ?context ctx:requires ?req .
                ?req :ageInYears ?ageConstraint .
                ?ageConstraint sh:maxExclusive ?max .
                FILTER(?age >= ?max)
            }
        """ ;
    ] .
```

### 3.2 Dynamic Context Selection Rule

Automatically assign appropriate context based on entity properties:

```turtle
ctx:AutoContextAssignmentRule a sh:SPARQLRule ;
    sh:order 1 ;
    sh:construct """
        PREFIX ctx: <http://ontologist.substack.com/ns/context#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        
        CONSTRUCT {
            ?stmt ctx:holdsIn ?applicableContext ;
                  rdfs:comment ?reason .
        }
        WHERE {
            # Find statements without explicit context
            ?stmt rdf:reifies << ?subject ?predicate ?object >> .
            FILTER NOT EXISTS { ?stmt ctx:holdsIn ?anyContext }
            
            # Find applicable contexts based on subject properties
            ?subject ?prop ?value .
            
            ?applicableContext a ctx:Context ;
                              ctx:requires ?requirement .
            ?requirement ?prop ?constraint .
            
            # Check if value satisfies constraint
            {
                ?constraint sh:minInclusive ?min .
                ?constraint sh:maxExclusive ?max .
                FILTER(?value >= ?min && ?value < ?max)
            } UNION {
                ?constraint sh:hasValue ?expectedValue .
                FILTER(?value = ?expectedValue)
            }
            
            BIND(CONCAT("Auto-assigned based on ", STR(?prop), " = ", STR(?value)) AS ?reason)
        }
    """ .
```

### 3.3 Confidence Propagation Rule

Propagate and adjust confidence through inference chains:

```turtle
ctx:ConfidencePropagationRule a sh:SPARQLRule ;
    sh:order 10 ;
    sh:construct """
        PREFIX ctx: <http://ontologist.substack.com/ns/context#>
        PREFIX prov: <http://www.w3.org/ns/prov#>
        
        CONSTRUCT {
            ?derivedStmt ctx:confidence ?adjustedConfidence ;
                        prov:wasDerivedFrom ?sourceStmt .
        }
        WHERE {
            # Find derived statements
            ?derivedStmt prov:wasDerivedFrom+ ?sourceStmt .
            
            # Get source confidence
            ?sourceStmt ctx:confidence ?sourceConfidence .
            
            # Calculate path length (more steps = less confidence)
            {
                SELECT ?derivedStmt ?sourceStmt (COUNT(?intermediate) AS ?pathLength)
                WHERE {
                    ?derivedStmt prov:wasDerivedFrom+ ?intermediate .
                    ?intermediate prov:wasDerivedFrom+ ?sourceStmt .
                }
                GROUP BY ?derivedStmt ?sourceStmt
            }
            
            # Apply confidence decay: confidence * (0.95 ^ pathLength)
            BIND(?sourceConfidence * (0.95 ** ?pathLength) AS ?adjustedConfidence)
            
            FILTER NOT EXISTS { ?derivedStmt ctx:confidence ?existingConf }
        }
    """ .
```

---

## 4. Performance Optimization

### 4.1 Materialized Context Views

Pre-compute context-specific views for frequently accessed data:

```sparql
# Materialize adult stage view
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

INSERT {
    GRAPH :AdultStageView {
        ?subject ?predicate ?object .
        ?stmt ctx:confidence ?confidence .
    }
}
WHERE {
    ?subject ?predicate ?object .
    ?stmt rdf:reifies << ?subject ?predicate ?object >> ;
          ctx:holdsIn ctx:AdultStage ;
          ctx:confidence ?confidence .
}
```

**Query materialized view (much faster):**

```sparql
SELECT *
FROM :AdultStageView
WHERE {
    ?subject ?predicate ?object .
}
```

### 4.2 Context Indexing Strategy

Create indexes for common access patterns:

```sql
-- Triple store specific (example for Jena TDB)
CREATE INDEX idx_context_holds ON statements(context_id) 
WHERE annotation_property = 'http://ontologist.substack.com/ns/context#holdsIn';

CREATE INDEX idx_context_subsumes ON statements(subject_id, object_id)
WHERE predicate = 'http://ontologist.substack.com/ns/context#subsumes';

CREATE INDEX idx_confidence ON statements(object_value)
WHERE predicate = 'http://ontologist.substack.com/ns/context#confidence';
```

### 4.3 Query Optimization Techniques

**Before optimization (slow):**

```sparql
# This queries every statement and filters
SELECT ?subject ?value
WHERE {
    ?subject :property ?value .
    ?stmt rdf:reifies << ?subject :property ?value >> ;
          ctx:holdsIn ?context .
    ?context ctx:subsumes* ctx:TargetContext .
}
```

**After optimization (fast):**

```sparql
# Pre-compute transitive closure, use VALUES
SELECT ?subject ?value
WHERE {
    VALUES ?applicableContext { 
        ctx:TargetContext 
        ctx:ParentContext1 
        ctx:ParentContext2 
        # ... pre-computed list
    }
    
    ?subject :property ?value .
    ?stmt rdf:reifies << ?subject :property ?value >> ;
          ctx:holdsIn ?applicableContext .
}
```

### 4.4 Caching Strategy

Implement application-level caching:

```python
from functools import lru_cache
from rdflib import Graph

class ContextCache:
    def __init__(self, graph):
        self.graph = graph
        self.cache = {}
    
    @lru_cache(maxsize=1000)
    def get_subsumption_closure(self, context_uri):
        """Cache transitive closure of subsumption"""
        query = """
            PREFIX ctx: <http://ontologist.substack.com/ns/context#>
            SELECT ?ancestor
            WHERE {
                ?ancestor ctx:subsumes* <%s> .
            }
        """ % context_uri
        
        results = self.graph.query(query)
        return set(str(row.ancestor) for row in results)
    
    def get_statements_in_context(self, context_uri, use_inheritance=True):
        """Get all statements valid in context"""
        cache_key = (context_uri, use_inheritance)
        
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        if use_inheritance:
            applicable_contexts = self.get_subsumption_closure(context_uri)
        else:
            applicable_contexts = {context_uri}
        
        # Query for statements
        results = self._query_statements(applicable_contexts)
        self.cache[cache_key] = results
        
        return results
```

---

## 5. Real-World Case Studies

### 5.1 Case Study: Medical Records System

**Challenge:** Hospital needs to track patient data that varies by context (location, time, treating physician).

**Solution:**

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix med: <http://example.org/medical/> .
@prefix prov: <http://www.w3.org/ns/prov#> .

# Define medical contexts
ctx:ERContext a ctx:SpatialContext ;
    rdfs:label "Emergency Room" ;
    ctx:requires [ med:location med:EmergencyDept ] .

ctx:ICUContext a ctx:SpatialContext ;
    rdfs:label "ICU" ;
    ctx:requires [ med:location med:IntensiveCareUnit ] .

ctx:Dr_Smith_Assessment a ctx:EpistemicContext ;
    rdfs:label "Dr. Smith's Assessment" ;
    prov:wasAttributedTo :Dr_Smith .

# Patient vitals change by location and time
med:Patient_12345 med:bloodPressure "140/90" 
    ~ _:er_reading {| 
        ctx:holdsIn ctx:ERContext ;
        prov:generatedAtTime "2024-01-15T10:30:00Z"^^xsd:dateTime ;
        med:measuredBy :Nurse_Jones ;
        ctx:confidence 0.95
    |} .

med:Patient_12345 med:bloodPressure "120/80" 
    ~ _:icu_reading {| 
        ctx:holdsIn ctx:ICUContext ;
        prov:generatedAtTime "2024-01-15T14:00:00Z"^^xsd:dateTime ;
        med:measuredBy :Nurse_Brown ;
        ctx:confidence 0.98 ;
        rdfs:comment "Stabilized after treatment"
    |} .

# Diagnosis varies by physician
med:Patient_12345 med:diagnosis med:Hypertension 
    ~ {| 
        ctx:holdsIn ctx:Dr_Smith_Assessment ;
        ctx:confidence 0.9 ;
        prov:wasAttributedTo :Dr_Smith ;
        prov:generatedAtTime "2024-01-15T15:00:00Z"^^xsd:dateTime
    |} .
```

**Benefits:**
- Track data provenance (who, when, where)
- Handle conflicting measurements from different locations
- Maintain audit trail with confidence levels
- Query by specific context (location, physician, time period)

### 5.2 Case Study: Financial Trading System

**Challenge:** Trading decisions depend on market conditions, time of day, and regulatory context.

**Solution:**

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix trade: <http://example.org/trading/> .
@prefix market: <http://example.org/market/> .

# Market condition contexts
ctx:BullMarket a ctx:Context ;
    rdfs:label "Bull Market" ;
    ctx:requires [ market:trendIndicator "positive" ] .

ctx:BearMarket a ctx:Context ;
    rdfs:label "Bear Market" ;
    ctx:requires [ market:trendIndicator "negative" ] .

ctx:HighVolatility a ctx:Context ;
    rdfs:label "High Volatility" ;
    ctx:requires [ market:VIX [ sh:minInclusive 30 ] ] .

# Regulatory contexts
ctx:PreMarketHours a ctx:TemporalContext ;
    rdfs:label "Pre-Market Hours" ;
    temp:startTime "04:00:00"^^xsd:time ;
    temp:endTime "09:30:00"^^xsd:time .

ctx:RegularHours a ctx:TemporalContext ;
    rdfs:label "Regular Trading Hours" ;
    temp:startTime "09:30:00"^^xsd:time ;
    temp:endTime "16:00:00"^^xsd:time .

# Trading strategy varies by context
trade:Strategy_Aggressive trade:recommendedAction trade:Buy 
    ~ {| 
        ctx:holdsIn ctx:BullMarket ;
        ctx:holdsIn ctx:RegularHours ;
        ctx:failsIn ctx:HighVolatility ;
        ctx:confidence 0.85 ;
        rdfs:comment "Buy aggressively in bull market during regular hours with low volatility"
    |} .

trade:Strategy_Aggressive trade:recommendedAction trade:Hold 
    ~ {| 
        ctx:holdsIn ctx:BullMarket ;
        ctx:holdsIn ctx:HighVolatility ;
        ctx:confidence 0.90 ;
        rdfs:comment "Hold during high volatility even in bull market"
    |} .
```

**Benefits:**
- Context-aware trading strategies
- Compliance with regulatory time windows
- Risk management based on market conditions
- Audit trail for regulatory reporting

### 5.3 Case Study: IoT Sensor Network

**Challenge:** Sensor readings vary by environmental conditions and sensor health.

**Solution:**

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix iot: <http://example.org/iot/> .
@prefix env: <http://example.org/environment/> .

# Environmental contexts
ctx:NormalOperating a ctx:Context ;
    rdfs:label "Normal Operating Conditions" ;
    ctx:requires [
        env:temperature [ sh:minInclusive -20 ; sh:maxInclusive 50 ] ;
        env:humidity [ sh:minInclusive 10 ; sh:maxInclusive 90 ]
    ] .

ctx:ExtremeHeat a ctx:Context ;
    rdfs:label "Extreme Heat" ;
    ctx:requires [ env:temperature [ sh:minInclusive 50 ] ] .

ctx:HighHumidity a ctx:Context ;
    rdfs:label "High Humidity" ;
    ctx:requires [ env:humidity [ sh:minInclusive 90 ] ] .

# Sensor health contexts
ctx:SensorHealthy a ctx:Context ;
    rdfs:label "Sensor Healthy" ;
    ctx:requires [ iot:lastCalibration [ temp:within "P30D"^^xsd:duration ] ] .

ctx:SensorDegraded a ctx:Context ;
    rdfs:label "Sensor Degraded" ;
    ctx:requires [ iot:lastCalibration [ temp:beyond "P180D"^^xsd:duration ] ] .

# Reading with multiple context dimensions
iot:Sensor_001 iot:reading 45.2 
    ~ _:reading1 {| 
        ctx:holdsIn ctx:NormalOperating ;
        ctx:holdsIn ctx:SensorHealthy ;
        ctx:confidence 0.98 ;
        prov:generatedAtTime "2024-01-15T10:00:00Z"^^xsd:dateTime
    |} .

iot:Sensor_001 iot:reading 52.1 
    ~ _:reading2 {| 
        ctx:holdsIn ctx:ExtremeHeat ;
        ctx:holdsIn ctx:SensorDegraded ;
        ctx:confidence 0.65 ;
        prov:generatedAtTime "2024-01-15T14:00:00Z"^^xsd:dateTime ;
        rdfs:comment "Reading may be unreliable due to extreme heat and sensor degradation"
    |} .
```

**Benefits:**
- Track sensor reliability over time
- Flag readings from degraded sensors
- Context-aware anomaly detection
- Maintenance scheduling based on context

---

## 6. Building Context-Aware Applications

### 6.1 Python Application Architecture

```python
from rdflib import Graph, Namespace, Literal, URIRef
from rdflib.namespace import RDF, RDFS
import pyshacl

# Define namespaces
CTX = Namespace("http://ontologist.substack.com/ns/context#")
EX = Namespace("http://example.org/")

class ContextAwareKG:
    def __init__(self, data_graph_path, shapes_graph_path):
        self.data_graph = Graph()
        self.shapes_graph = Graph()
        
        self.data_graph.parse(data_graph_path, format='turtle')
        self.shapes_graph.parse(shapes_graph_path, format='turtle')
        
        # Cache for performance
        self.context_cache = {}
        self.subsumption_cache = {}
    
    def validate(self):
        """Validate data against SHACL shapes"""
        conforms, results_graph, results_text = pyshacl.validate(
            self.data_graph,
            shacl_graph=self.shapes_graph,
            inference='rdfs',
            abort_on_first=False
        )
        return conforms, results_text
    
    def get_statements_in_context(self, context_uri, include_inherited=True):
        """Get all statements valid in a specific context"""
        query = """
            PREFIX ctx: <http://ontologist.substack.com/ns/context#>
            PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
            
            SELECT ?subject ?predicate ?object ?confidence
            WHERE {
                ?subject ?predicate ?object .
                ?stmt rdf:reifies << ?subject ?predicate ?object >> ;
                      ctx:holdsIn ?context .
                
                OPTIONAL { ?stmt ctx:confidence ?confidence }
                
                %s
            }
        """ % (
            "?context ctx:subsumes* <%s> ." % context_uri 
            if include_inherited 
            else "FILTER(?context = <%s>)" % context_uri
        )
        
        return list(self.data_graph.query(query))
    
    def add_contextual_statement(self, subject, predicate, obj, 
                                 context, confidence=None):
        """Add a new contextual statement"""
        # Add base triple
        self.data_graph.add((subject, predicate, obj))
        
        # Create reification
        stmt = URIRef(f"urn:statement:{hash((subject, predicate, obj))}")
        self.data_graph.add((stmt, RDF.reifies, 
                           Literal(f"<< {subject} {predicate} {obj} >>")))
        self.data_graph.add((stmt, CTX.holdsIn, context))
        
        if confidence is not None:
            self.data_graph.add((stmt, CTX.confidence, Literal(confidence)))
    
    def query_with_context_filter(self, sparql_query, active_contexts):
        """Execute SPARQL query filtered by active contexts"""
        context_filter = " ".join(
            f"VALUES ?activeCtx {{ <{ctx}> }}" 
            for ctx in active_contexts
        )
        
        modified_query = sparql_query.replace(
            "WHERE {",
            f"WHERE {{ {context_filter} "
        )
        
        return self.data_graph.query(modified_query)
    
    def export_context_view(self, context_uri, output_path):
        """Export all data valid in a context to a new file"""
        statements = self.get_statements_in_context(context_uri)
        
        output_graph = Graph()
        for s, p, o, conf in statements:
            output_graph.add((s, p, o))
        
        output_graph.serialize(destination=output_path, format='turtle')

# Usage example
kg = ContextAwareKG('data.ttl', 'shapes.ttl')

# Validate
conforms, report = kg.validate()
if not conforms:
    print("Validation errors:", report)

# Query by context
adult_statements = kg.get_statements_in_context(
    "http://ontologist.substack.com/ns/context#AdultStage"
)

# Add new contextual statement
kg.add_contextual_statement(
    EX.Dragon123,
    EX.hasLength,
    Literal(23),
    CTX.AdultStage,
    confidence=0.95
)

# Export context-specific view
kg.export_context_view(CTX.AdultStage, 'adult_view.ttl')
```

### 6.2 REST API Design

```python
from flask import Flask, jsonify, request
from context_kg import ContextAwareKG

app = Flask(__name__)
kg = ContextAwareKG('data.ttl', 'shapes.ttl')

@app.route('/contexts', methods=['GET'])
def list_contexts():
    """List all available contexts"""
    query = """
        PREFIX ctx: <http://ontologist.substack.com/ns/context#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        
        SELECT ?context ?label ?type
        WHERE {
            ?context a ctx:Context .
            ?context rdfs:label ?label .
            ?context a ?type .
            FILTER(?type != ctx:Context)
        }
    """
    results = kg.data_graph.query(query)
    return jsonify([{
        'uri': str(row.context),
        'label': str(row.label),
        'type': str(row.type)
    } for row in results])

@app.route('/query', methods=['POST'])
def context_query():
    """Query data with context filtering"""
    data = request.json
    contexts = data.get('contexts', [])
    query = data.get('query')
    
    results = kg.query_with_context_filter(query, contexts)
    return jsonify([{
        'bindings': {var: str(row[var]) for var in results.vars}
    } for row in results])

@app.route('/statement', methods=['POST'])
def add_statement():
    """Add a new contextual statement"""
    data = request.json
    
    kg.add_contextual_statement(
        URIRef(data['subject']),
        URIRef(data['predicate']),
        Literal(data['object']),
        URIRef(data['context']),
        confidence=data.get('confidence')
    )
    
    return jsonify({'status': 'success'}), 201

@app.route('/validate', methods=['POST'])
def validate_data():
    """Validate data against shapes"""
    conforms, report = kg.validate()
    return jsonify({
        'conforms': conforms,
        'report': report
    })

if __name__ == '__main__':
    app.run(debug=True)
```

---

## 7. Advanced Query Techniques

### 7.1 Recursive Context Queries

Find all statements valid within a context hierarchy:

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?statement ?subject ?predicate ?object ?depth ?confidence
WHERE {
    {
        SELECT ?statement ?context (COUNT(?intermediate) AS ?depth)
        WHERE {
            VALUES ?targetContext { ctx:SpecificContext }
            
            ?statement ctx:holdsIn ?context .
            
            {
                # Direct match
                FILTER(?context = ?targetContext)
                BIND(0 AS ?intermediateCount)
            } UNION {
                # Through subsumption
                ?context ctx:subsumes+ ?intermediate .
                ?targetContext ctx:subsumes* ?intermediate .
            }
        }
        GROUP BY ?statement ?context
    }
    
    ?statement rdf:reifies << ?subject ?predicate ?object >> .
    OPTIONAL { ?statement ctx:confidence ?confidence }
}
ORDER BY ?depth DESC(?confidence)
```

### 7.2 Confidence-Weighted Aggregation

Calculate weighted averages based on confidence:

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?subject 
       (SUM(?value * ?confidence) / SUM(?confidence) AS ?weightedAvg)
       (AVG(?confidence) AS ?avgConfidence)
       (COUNT(*) AS ?measurementCount)
WHERE {
    ?subject :measurement ?value .
    ?stmt rdf:reifies << ?subject :measurement ?value >> ;
          ctx:holdsIn ?targetContext ;
          ctx:confidence ?confidence .
}
GROUP BY ?subject
HAVING(?avgConfidence > 0.7)
ORDER BY DESC(?weightedAvg)
```

### 7.3 Temporal Slicing

Query historical state at specific time points:

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX temp: <http://example.org/temporal/>
PREFIX prov: <http://www.w3.org/ns/prov#>

SELECT ?subject ?predicate ?object ?context
WHERE {
    ?subject ?predicate ?object .
    ?stmt rdf:reifies << ?subject ?predicate ?object >> ;
          ctx:holdsIn ?context ;
          prov:generatedAtTime ?timestamp .
    
    ?context a ctx:TemporalContext .
    
    # Query time point
    BIND("2024-01-15T12:00:00Z"^^xsd:dateTime AS ?queryTime)
    
    # Most recent statement before query time
    {
        SELECT ?subject ?predicate (MAX(?timestamp) AS ?latestTime)
        WHERE {
            ?subject ?predicate ?object .
            ?stmt rdf:reifies << ?subject ?predicate ?object >> ;
                  prov:generatedAtTime ?timestamp .
            FILTER(?timestamp <= ?queryTime)
        }
        GROUP BY ?subject ?predicate
    }
    
    FILTER(?timestamp = ?latestTime)
}
```

---

## 8. Extending ACO

### 8.1 Creating Custom Context Types

Define domain-specific context types:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix finance: <http://example.org/finance/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

# Define new context type
finance:RegulatoryContext a rdfs:Class, owl:Class ;
    rdfs:label "Regulatory Context"@en ;
    rdfs:subClassOf ctx:Context ;
    rdfs:comment "Context defined by regulatory jurisdiction"@en .

# Define properties specific to this context type
finance:jurisdiction a rdf:Property ;
    rdfs:label "jurisdiction"@en ;
    rdfs:domain finance:RegulatoryContext ;
    rdfs:range rdfs:Literal .

finance:regulatoryBody a rdf:Property ;
    rdfs:label "regulatory body"@en ;
    rdfs:domain finance:RegulatoryContext ;
    rdfs:range rdfs:Resource .

# Use custom context type
finance:SECRegulation a finance:RegulatoryContext ;
    rdfs:label "SEC Regulation" ;
    finance:jurisdiction "United States"@en ;
    finance:regulatoryBody :SEC ;
    ctx:requires [
        finance:registeredWithSEC true
    ] .

# SHACL shape for custom context type
finance:RegulatoryContextShape a sh:NodeShape ;
    sh:targetClass finance:RegulatoryContext ;
    sh:property [
        sh:path finance:jurisdiction ;
        sh:minCount 1 ;
        sh:datatype xsd:string ;
        sh:message "Regulatory context must specify jurisdiction"
    ] ;
    sh:property [
        sh:path finance:regulatoryBody ;
        sh:minCount 1 ;
        sh:message "Regulatory context must specify regulatory body"
    ] .
```

### 8.2 Custom Inference Rules

Add domain-specific inference:

```turtle
finance:RegulatoryComplianceRule a sh:SPARQLRule ;
    sh:order 5 ;
    sh:construct """
        PREFIX ctx: <http://ontologist.substack.com/ns/context#>
        PREFIX finance: <http://example.org/finance/>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        
        CONSTRUCT {
            ?stmt ctx:holdsIn ?federalContext ;
                  rdfs:comment "Also valid at federal level due to regulatory hierarchy" .
        }
        WHERE {
            # Statement valid in state regulatory context
            ?stmt ctx:holdsIn ?stateContext .
            ?stateContext a finance:RegulatoryContext ;
                         finance:jurisdiction ?state .
            
            # Find corresponding federal context
            ?federalContext a finance:RegulatoryContext ;
                           finance:jurisdiction "United States" .
            
            # Federal context subsumes state contexts
            ?federalContext ctx:subsumes ?stateContext .
            
            FILTER NOT EXISTS { ?stmt ctx:holdsIn ?federalContext }
        }
    """ .
```

### 8.3 Plugin Architecture

Design extensible plugin system:

```python
from abc import ABC, abstractmethod
from typing import List, Dict, Any

class ContextPlugin(ABC):
    """Base class for ACO plugins"""
    
    @abstractmethod
    def get_name(self) -> str:
        """Return plugin name"""
        pass
    
    @abstractmethod
    def get_context_types(self) -> List[str]:
        """Return list of context type URIs this plugin handles"""
        pass
    
    @abstractmethod
    def validate_context(self, context_uri: str, graph: Graph) -> Dict[str, Any]:
        """Validate a context of this type"""
        pass
    
    @abstractmethod
    def get_inference_rules(self) -> List[str]:
        """Return SPARQL CONSTRUCT queries for inference"""
        pass

class FinancialContextPlugin(ContextPlugin):
    def get_name(self):
        return "Financial Context Plugin"
    
    def get_context_types(self):
        return ["http://example.org/finance/RegulatoryContext"]
    
    def validate_context(self, context_uri, graph):
        # Custom validation logic
        query = """
            PREFIX finance: <http://example.org/finance/>
            ASK {
                <%s> finance:jurisdiction ?j ;
                     finance:regulatoryBody ?b .
            }
        """ % context_uri
        
        is_valid = graph.query(query).askAnswer
        return {
            'valid': is_valid,
            'message': 'OK' if is_valid else 'Missing required properties'
        }
    
    def get_inference_rules(self):
        return [
            # Regulatory hierarchy inference
            """
            PREFIX ctx: <http://ontologist.substack.com/ns/context#>
            PREFIX finance: <http://example.org/finance/>
            CONSTRUCT {
                ?federal ctx:subsumes ?state .
            }
            WHERE {
                ?federal a finance:RegulatoryContext ;
                        finance:jurisdiction "United States" .
                ?state a finance:RegulatoryContext ;
                      finance:jurisdiction ?stateJurisdiction .
                FILTER(?stateJurisdiction != "United States")
                FILTER NOT EXISTS { ?federal ctx:subsumes ?state }
            }
            """
        ]

# Plugin manager
class PluginManager:
    def __init__(self):
        self.plugins: Dict[str, ContextPlugin] = {}
    
    def register_plugin(self, plugin: ContextPlugin):
        self.plugins[plugin.get_name()] = plugin
    
    def validate_all(self, graph: Graph) -> Dict[str, List[Dict]]:
        results = {}
        for plugin_name, plugin in self.plugins.items():
            plugin_results = []
            for context_type in plugin.get_context_types():
                # Find all contexts of this type
                query = f"SELECT ?ctx WHERE {{ ?ctx a <{context_type}> }}"
                for row in graph.query(query):
                    validation = plugin.validate_context(str(row.ctx), graph)
                    plugin_results.append({
                        'context': str(row.ctx),
                        'result': validation
                    })
            results[plugin_name] = plugin_results
        return results

# Usage
manager = PluginManager()
manager.register_plugin(FinancialContextPlugin())

validation_results = manager.validate_all(kg.data_graph)
```

---

## Conclusion

This advanced guide has covered:

- Complex context patterns (fuzzy, probabilistic, nested)
- Deep integration with W3C standards (PROV, OWL-Time, SKOS)
- Custom SHACL rules for domain-specific validation
- Performance optimization strategies
- Real-world case studies from healthcare, finance, and IoT
- Building production applications with Python
- Advanced query techniques
- Extending ACO with custom types and plugins

For additional support:
- Consult the SPECIFICATION.md for formal definitions
- Review PRIMER.md for basic concepts and examples
- Explore the examples/ directory for working code
- Join the community discussions on GitHub

---

**End of Advanced Topics Guide**
