# Annotation Context Ontology - Primer

**Version:** 1.0.0  
**Date:** 2026-02-05

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Getting Started](#2-getting-started)
3. [Basic Concepts](#3-basic-concepts)
4. [Practical Examples](#4-practical-examples)
5. [Query Patterns](#5-query-patterns)
6. [Best Practices](#6-best-practices)
7. [Common Patterns](#7-common-patterns)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Introduction

### 1.1 What is ACO?

The Annotation Context Ontology (ACO) helps you answer questions like:

- "This measurement was accurate in 1950, but is it still accurate today?"
- "Tolkien says Smaug was 23 meters long, but the Mabinogion says 21 meters. How do I represent both?"
- "This property is true when the dragon is flying, but false when resting."
- "Three eyewitnesses gave different accounts. How do I capture all perspectives?"

ACO solves these problems by letting you annotate RDF statements with **contexts**—scopes or situations where statements hold true, fail, or remain undefined.

### 1.2 Who Should Use ACO?

ACO is ideal for:

- **Data Integration**: Merging datasets from different sources with conflicting information
- **Historical Data**: Tracking how facts change over time
- **Multi-Perspective Systems**: Representing different viewpoints or beliefs
- **Scientific Data**: Recording measurements under varying conditions
- **Provenance Tracking**: Documenting source and reliability of information
- **Knowledge Graphs**: Building rich, context-aware semantic networks

### 1.3 Prerequisites

To use this primer, you should be familiar with:

- RDF and Turtle syntax (basic level)
- SPARQL queries (basic SELECT queries)
- Semantic web concepts (triples, URIs, literals)

You'll learn:

- How to use RDF-star annotation syntax
- How to define and use contexts
- How to validate contextual data with SHACL
- How to query contextual statements effectively

---

## 2. Getting Started

### 2.1 Required Tools

You'll need:

1. **RDF-star compatible parser**
   - Apache Jena 4.7.0+: `wget https://dlcdn.apache.org/jena/binaries/...`
   - Python RDFLib 7.0.0+: `pip install rdflib`

2. **SHACL validator**
   - pySHACL: `pip install pyshacl`
   - Apache Jena SHACL: Included in Jena distribution

3. **Text editor** with Turtle syntax highlighting
   - VS Code with "RDF Syntax" extension
   - IntelliJ with Semantic Web plugin

### 2.2 Setting Up a Project

Create a new directory structure:

```bash
mkdir my-contextual-data
cd my-contextual-data
mkdir data validation queries
```

Download ACO ontology and shapes:

```bash
# Clone the repository
git clone https://github.com/yourusername/annotation-context-ontology.git

# Copy essentials to your project
cp annotation-context-ontology/ontology/context-full.ttl data/
cp annotation-context-ontology/validation/context-shapes.ttl validation/
```

### 2.3 Your First Contextual Statement

Create `data/first-example.ttl`:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix ex: <http://example.org/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

# Define a simple context
ctx:Summer a ctx:TemporalContext ;
    rdfs:label "Summer Season" ;
    rdfs:comment "June through August" .

# Make a contextual statement
ex:LakeTemperature ex:hasValue 22 
    ~ {| 
        ctx:holdsIn ctx:Summer ;
        ctx:confidence 0.9 ;
        rdfs:comment "Average lake temperature in summer is 22°C"
    |} .
```

Validate it:

```bash
pyshacl -s validation/context-shapes.ttl \
        -e validation/context-shapes.ttl \
        -df turtle \
        data/first-example.ttl
```

If validation passes, congratulations! You've created your first contextual RDF statement.

---

## 3. Basic Concepts

### 3.1 Contexts

A **context** is a scope or situation. Think of it like:

- A time period ("during adolescence", "in the 21st century")
- A location ("inside the building", "in North America")
- A knowledge source ("according to Tolkien", "from NASA data")
- A condition ("when temperature exceeds 100°C", "while in flight")

### 3.2 Context Types

ACO provides four specialized context types:

#### Temporal Context

For time-based scoping:

```turtle
ctx:ChildhoodStage a ctx:TemporalContext ;
    rdfs:label "Childhood" ;
    ctx:requires [ 
        :age [ sh:maxExclusive 13 ] 
    ] .
```

#### Spatial Context

For location-based scoping:

```turtle
ctx:IndoorEnvironment a ctx:SpatialContext ;
    rdfs:label "Indoor" ;
    ctx:requires [ 
        geo:within :BuildingBoundary 
    ] .
```

#### Epistemic Context

For knowledge source scoping:

```turtle
ctx:ScientificConsensus a ctx:EpistemicContext ;
    rdfs:label "Scientific Consensus" ;
    rdfs:comment "Peer-reviewed published findings" .
```

#### Modal Context

For possible worlds:

```turtle
ctx:AlternateHistory a ctx:ModalContext ;
    rdfs:label "Alternate History" ;
    rdfs:comment "Hypothetical scenario where event X didn't occur" .
```

### 3.3 RDF-star Annotation Syntax

ACO uses Turtle 1.2's annotation syntax:

```turtle
# Basic pattern
subject predicate object ~ {| property value |} .

# Named reification
subject predicate object ~ _:id {| property value |} .

# Multiple annotations
subject predicate object 
    ~ {| property1 value1 |},
    ~ {| property2 value2 |} .
```

The `~` operator creates a reification (statement about a statement).

### 3.4 Core Properties

Three properties define contextual validity:

| Property | Meaning | Example |
|----------|---------|---------|
| `ctx:holdsIn` | Statement is true in this context | "Water is liquid at 20°C" |
| `ctx:failsIn` | Statement is false in this context | "Water is liquid at -20°C" |
| `ctx:undefinedIn` | Truth value unknown in this context | "Water state at unmeasured temp" |

Plus confidence:

```turtle
ex:measurement ex:hasValue 42 
    ~ {| 
        ctx:holdsIn ctx:LabConditions ;
        ctx:confidence 0.95  # 95% confidence
    |} .
```

### 3.5 Context Relationships

Contexts can relate to each other:

#### Subsumption (is-a hierarchy)

```turtle
ctx:Animals ctx:subsumes ctx:Mammals .
ctx:Mammals ctx:subsumes ctx:Primates .
# Inferred: ctx:Animals ctx:subsumes ctx:Primates
```

If a statement holds in `ctx:Primates`, it automatically holds in `ctx:Mammals` and `ctx:Animals`.

#### Exclusion (mutual incompatibility)

```turtle
ctx:Daytime ctx:excludes ctx:Nighttime .
ctx:Nighttime ctx:excludes ctx:Daytime .  # Must be symmetric
```

A statement cannot hold in both excluded contexts simultaneously.

---

## 4. Practical Examples

### 4.1 Example 1: Changing Properties Over Time

**Scenario**: A dragon's length changes as it ages.

```turtle
@prefix dragon: <http://example.org/dragons/> .
@prefix animal: <http://example.org/animal/> .
@prefix ctx: <http://ontologist.substack.com/ns/context#> .

# Define life stages
ctx:HatchlingStage a ctx:TemporalContext ;
    rdfs:label "Hatchling Stage" ;
    ctx:requires [ animal:ageInYears [ sh:maxExclusive 10 ] ] .

ctx:JuvenileStage a ctx:TemporalContext ;
    rdfs:label "Juvenile Stage" ;
    ctx:requires [ animal:ageInYears [ 
        sh:minInclusive 10 ;
        sh:maxExclusive 100 
    ] ] .

ctx:AdultStage a ctx:TemporalContext ;
    rdfs:label "Adult Stage" ;
    ctx:requires [ animal:ageInYears [ sh:minInclusive 100 ] ] .

# Set up relationships
ctx:AdultStage ctx:excludes ctx:HatchlingStage, ctx:JuvenileStage .
ctx:JuvenileStage ctx:excludes ctx:HatchlingStage .

# Dragon at different ages
dragon:Smaug a animal:Dragon .

dragon:Smaug animal:hasLength 2 
    ~ _:hatchling {| 
        ctx:holdsIn ctx:HatchlingStage ;
        ctx:failsIn ctx:JuvenileStage, ctx:AdultStage ;
        ctx:confidence 0.95 ;
        rdfs:comment "Newly hatched dragons are approximately 2 meters"
    |} .

dragon:Smaug animal:hasLength 8 
    ~ _:juvenile {| 
        ctx:holdsIn ctx:JuvenileStage ;
        ctx:failsIn ctx:HatchlingStage, ctx:AdultStage ;
        ctx:confidence 0.92 ;
        rdfs:comment "Juvenile growth phase"
    |} .

dragon:Smaug animal:hasLength 23 
    ~ _:adult {| 
        ctx:holdsIn ctx:AdultStage ;
        ctx:failsIn ctx:HatchlingStage, ctx:JuvenileStage ;
        ctx:confidence 0.98 ;
        rdfs:comment "Full adult size"
    |} .
```

**Query**: Get Smaug's length in adult stage:

```sparql
PREFIX dragon: <http://example.org/dragons/>
PREFIX animal: <http://example.org/animal/>
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?length ?confidence
WHERE {
    dragon:Smaug animal:hasLength ?length .
    ?stmt rdf:reifies << dragon:Smaug animal:hasLength ?length >> ;
          ctx:holdsIn ctx:AdultStage ;
          ctx:confidence ?confidence .
}
```

**Result**: `?length = 23, ?confidence = 0.98`

---

### 4.2 Example 2: Conflicting Sources

**Scenario**: Different historical sources give different measurements.

```turtle
@prefix dragon: <http://example.org/dragons/> .
@prefix book: <http://example.org/book/> .
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix prov: <http://www.w3.org/ns/prov#> .

# Define epistemic contexts (sources)
ctx:TolkienCanon a ctx:EpistemicContext ;
    rdfs:label "Tolkien Canon" ;
    rdfs:comment "Information from J.R.R. Tolkien's works" .

ctx:WelshMythology a ctx:EpistemicContext ;
    rdfs:label "Welsh Mythology" ;
    rdfs:comment "Traditional Welsh mythological accounts" .

ctx:ModernAnalysis a ctx:EpistemicContext ;
    rdfs:label "Modern Analysis" ;
    rdfs:comment "Contemporary scholarly synthesis" .

# Tolkien's claim
dragon:Welsh animal:hasMaxLength 23 
    ~ _:tolkienClaim {| 
        ctx:holdsIn ctx:TolkienCanon ;
        ctx:confidence 0.9 ;
        prov:wasAttributedTo :JRRTolkien ;
        prov:generatedAtTime "1954"^^xsd:gYear ;
        rdfs:comment "From The Hobbit descriptions"
    |} .

# Welsh mythology claim
dragon:Welsh animal:hasMaxLength 21 
    ~ _:welshClaim {| 
        ctx:holdsIn ctx:WelshMythology ;
        ctx:confidence 0.6 ;
        prov:wasAttributedTo :MabinogionScribe ;
        prov:generatedAtTime "1430"^^xsd:gYear ;
        rdfs:comment "From Mabinogion manuscript"
    |} .

# Modern scholarly estimate
dragon:Welsh animal:hasMaxLength 19 
    ~ _:modernClaim {| 
        ctx:holdsIn ctx:ModernAnalysis ;
        ctx:confidence 0.85 ;
        prov:wasAttributedTo :DrJaneSmith ;
        prov:generatedAtTime "2020"^^xsd:gYear ;
        rdfs:comment "Statistical analysis of all sources suggests 19m average"
    |} .
```

**Query**: Compare all claims:

```sparql
PREFIX dragon: <http://example.org/dragons/>
PREFIX animal: <http://example.org/animal/>
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX prov: <http://www.w3.org/ns/prov#>

SELECT ?length ?context ?confidence ?author ?date
WHERE {
    dragon:Welsh animal:hasMaxLength ?length .
    ?stmt rdf:reifies << dragon:Welsh animal:hasMaxLength ?length >> ;
          ctx:holdsIn ?context ;
          ctx:confidence ?confidence ;
          prov:wasAttributedTo ?author ;
          prov:generatedAtTime ?date .
}
ORDER BY DESC(?date)
```

**Result**: Shows all three claims with their contexts, letting users choose which to trust.

---

### 4.3 Example 3: Conditional Properties

**Scenario**: A dragon's wingspan depends on whether it's flying.

```turtle
@prefix dragon: <http://example.org/dragons/> .
@prefix animal: <http://example.org/animal/> .
@prefix ctx: <http://ontologist.substack.com/ns/context#> .

# Define behavioral contexts
ctx:InFlight a ctx:Context ;
    rdfs:label "In Flight" ;
    ctx:requires [ animal:isFlying true ] .

ctx:AtRest a ctx:Context ;
    rdfs:label "At Rest" ;
    ctx:requires [ animal:isFlying false ] .

# These contexts are mutually exclusive
ctx:InFlight ctx:excludes ctx:AtRest .
ctx:AtRest ctx:excludes ctx:InFlight .

# Wingspan when flying (wings extended)
dragon:Smaug animal:hasWingspan 40 
    ~ {| 
        ctx:holdsIn ctx:InFlight ;
        ctx:failsIn ctx:AtRest ;
        animal:unit animal:Meters ;
        rdfs:comment "Wings fully extended during flight"
    |} .

# Wingspan when resting (wings folded)
dragon:Smaug animal:hasWingspan 12 
    ~ {| 
        ctx:holdsIn ctx:AtRest ;
        ctx:failsIn ctx:InFlight ;
        animal:unit animal:Meters ;
        rdfs:comment "Wings folded when resting"
    |} .
```

**Query**: Get wingspan based on current state:

```sparql
PREFIX dragon: <http://example.org/dragons/>
PREFIX animal: <http://example.org/animal/>
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?wingspan
WHERE {
    # Assume we know current state
    dragon:Smaug animal:isFlying ?flying .
    
    # Get appropriate wingspan
    dragon:Smaug animal:hasWingspan ?wingspan .
    ?stmt rdf:reifies << dragon:Smaug animal:hasWingspan ?wingspan >> .
    
    # Match context to current state
    ?stmt ctx:holdsIn ?context .
    ?context ctx:requires [ animal:isFlying ?flying ] .
}
```

---

### 4.4 Example 4: Multiple Perspectives

**Scenario**: Different observers have different beliefs about a dragon.

```turtle
@prefix dragon: <http://example.org/dragons/> .
@prefix person: <http://example.org/person/> .
@prefix perspective: <http://example.org/perspective/> .
@prefix ctx: <http://ontologist.substack.com/ns/context#> .

# Define observer perspectives
perspective:BilboPerspective a ctx:Context ;
    rdfs:label "Bilbo's Perspective" ;
    rdfs:comment "Hobbit's viewpoint from inside mountain" .

perspective:BardPerspective a ctx:Context ;
    rdfs:label "Bard's Perspective" ;
    rdfs:comment "Warrior's viewpoint from laketown" .

perspective:ThorinPerspective a ctx:Context ;
    rdfs:label "Thorin's Perspective" ;
    rdfs:comment "Dwarf king's vengeful viewpoint" .

# Bilbo's estimate (limited visibility)
dragon:Smaug animal:isDangerous true 
    ~ {| 
        ctx:holdsIn perspective:BilboPerspective ;
        ctx:confidence 0.7 ;
        perspective:beliefStrength 0.7 ;
        rdfs:comment "Bilbo saw Smaug sleeping, unsure of true danger"
    |} .

# Bard's assessment (direct combat experience)
dragon:Smaug animal:isDangerous true 
    ~ {| 
        ctx:holdsIn perspective:BardPerspective ;
        ctx:confidence 1.0 ;
        perspective:beliefStrength 1.0 ;
        rdfs:comment "Bard fought Smaug, knows danger firsthand"
    |} .

# Thorin's exaggerated view (hatred-influenced)
dragon:Smaug animal:isDangerous true 
    ~ {| 
        ctx:holdsIn perspective:ThorinPerspective ;
        ctx:confidence 1.0 ;
        perspective:beliefStrength 1.0 ;
        perspective:bias "Extreme hatred of dragons" ;
        rdfs:comment "Thorin's judgment clouded by vengeance"
    |} .
```

**Query**: Compare perspectives with reliability weighting:

```sparql
PREFIX dragon: <http://example.org/dragons/>
PREFIX animal: <http://example.org/animal/>
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX perspective: <http://example.org/perspective/>

SELECT ?perspective ?confidence ?bias
WHERE {
    dragon:Smaug animal:isDangerous true .
    ?stmt rdf:reifies << dragon:Smaug animal:isDangerous true >> ;
          ctx:holdsIn ?perspective ;
          ctx:confidence ?confidence .
    
    OPTIONAL {
        ?stmt perspective:bias ?bias .
    }
}
ORDER BY DESC(?confidence)
```

---

### 4.5 Example 5: Hierarchical Contexts

**Scenario**: Nested contexts with inherited validity.

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix animal: <http://example.org/animal/> .

# Define hierarchy
ctx:AllAnimals a ctx:Context ;
    rdfs:label "All Animals" .

ctx:Vertebrates a ctx:Context ;
    rdfs:label "Vertebrates" .

ctx:Mammals a ctx:Context ;
    rdfs:label "Mammals" .

ctx:Primates a ctx:Context ;
    rdfs:label "Primates" .

# Set up subsumption relationships
ctx:AllAnimals ctx:subsumes ctx:Vertebrates .
ctx:Vertebrates ctx:subsumes ctx:Mammals .
ctx:Mammals ctx:subsumes ctx:Primates .

# Statement at specific level
:Human animal:hasBackbone true 
    ~ {| 
        ctx:holdsIn ctx:Primates 
    |} .

# Through inference, this statement also holds in:
# - ctx:Mammals (inferred)
# - ctx:Vertebrates (inferred)
# - ctx:AllAnimals (inferred)
```

**Query with transitive reasoning**:

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX animal: <http://example.org/animal/>

SELECT ?subject ?object ?applicableContext
WHERE {
    # Direct assertion
    ?subject animal:hasBackbone ?object .
    ?stmt rdf:reifies << ?subject animal:hasBackbone ?object >> ;
          ctx:holdsIn ?directContext .
    
    # Find all contexts where statement holds (including inferred)
    ?applicableContext ctx:subsumes* ?directContext .
}
```

---

## 5. Query Patterns

### 5.1 Basic Patterns

#### Pattern 1: Get all statements valid in a context

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?subject ?predicate ?object ?confidence
WHERE {
    ?subject ?predicate ?object .
    ?stmt rdf:reifies << ?subject ?predicate ?object >> ;
          ctx:holdsIn ctx:TargetContext ;
          OPTIONAL { ?stmt ctx:confidence ?confidence }
}
```

#### Pattern 2: Find contexts where statement holds

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?context ?label
WHERE {
    :MySubject :myProperty :myObject .
    ?stmt rdf:reifies << :MySubject :myProperty :myObject >> ;
          ctx:holdsIn ?context .
    ?context rdfs:label ?label .
}
```

#### Pattern 3: Get most confident statement

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?value (MAX(?conf) AS ?maxConf)
WHERE {
    :MySubject :myProperty ?value .
    ?stmt rdf:reifies << :MySubject :myProperty ?value >> ;
          ctx:confidence ?conf .
}
GROUP BY ?value
ORDER BY DESC(?maxConf)
LIMIT 1
```

### 5.2 Advanced Patterns

#### Pattern 4: Context applicability check

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?context ?applicable
WHERE {
    VALUES ?entity { :MyEntity }
    
    ?context a ctx:Context ;
             ctx:requires ?requirement .
    
    # Check if entity satisfies requirements
    BIND(
        EXISTS {
            ?entity ?prop ?value .
            ?requirement ?prop ?constraint .
            # Add constraint checking logic
        } AS ?applicable
    )
}
```

#### Pattern 5: Conflict detection

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?stmt ?ctx1 ?ctx2
WHERE {
    ?stmt ctx:holdsIn ?ctx1, ?ctx2 .
    ?ctx1 ctx:excludes ?ctx2 .
    FILTER(?ctx1 != ?ctx2)
}
```

#### Pattern 6: Temporal query (statements valid at specific time)

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>
PREFIX temp: <http://example.org/temporal/>

SELECT ?subject ?predicate ?object
WHERE {
    ?subject ?predicate ?object .
    ?stmt rdf:reifies << ?subject ?predicate ?object >> ;
          ctx:holdsIn ?context .
    
    ?context temp:validFrom ?from ;
             temp:validUntil ?until .
    
    BIND("2024-01-15"^^xsd:date AS ?queryTime)
    FILTER(?queryTime >= ?from && ?queryTime < ?until)
}
```

### 5.3 Aggregation Patterns

#### Pattern 7: Consensus analysis

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?value (COUNT(*) AS ?sources) (AVG(?conf) AS ?avgConfidence)
WHERE {
    :Dragon :hasLength ?value .
    ?stmt rdf:reifies << :Dragon :hasLength ?value >> ;
          ctx:holdsIn ?context ;
          ctx:confidence ?conf .
}
GROUP BY ?value
ORDER BY DESC(?sources) DESC(?avgConfidence)
```

#### Pattern 8: Weighted average by confidence

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT (SUM(?value * ?conf) / SUM(?conf) AS ?weightedAvg)
WHERE {
    :Dragon :hasLength ?value .
    ?stmt rdf:reifies << :Dragon :hasLength ?value >> ;
          ctx:confidence ?conf .
}
```

---

## 6. Best Practices

### 6.1 Designing Contexts

#### Do:
✅ Use descriptive, human-readable labels
✅ Document context requirements clearly
✅ Create hierarchies for related contexts
✅ Make exclusions explicit and symmetric
✅ Include confidence levels when appropriate

#### Don't:
❌ Create circular subsumption chains
❌ Mix unrelated dimensions in single context
❌ Forget to define context types properly
❌ Leave exclusions asymmetric
❌ Overuse deeply nested hierarchies (>5 levels)

### 6.2 Naming Conventions

**Contexts:**
- PascalCase for context IDs: `ctx:AdultStage`
- Human-readable labels: `"Adult Stage"`
- Clear, specific descriptions

**Properties:**
- camelCase: `ctx:holdsIn`, `ctx:confidence`
- Verbs for actions: `subsumes`, `excludes`

**Examples:**
```turtle
# Good
ctx:HighTemperatureEnvironment a ctx:Context ;
    rdfs:label "High Temperature Environment" ;
    rdfs:comment "Ambient temperature above 30°C" ;
    ctx:requires [ :temperature [ sh:minInclusive 30 ] ] .

# Avoid
ctx:HTE a ctx:Context ;
    rdfs:label "HTE" .  # Unclear abbreviation, no documentation
```

### 6.3 Confidence Scores

Guidelines for confidence levels:

| Range | Meaning | Example |
|-------|---------|---------|
| 0.9-1.0 | Very high confidence | Direct measurement with calibrated instruments |
| 0.7-0.9 | High confidence | Peer-reviewed research, multiple corroborating sources |
| 0.5-0.7 | Moderate confidence | Single reliable source, some uncertainty |
| 0.3-0.5 | Low confidence | Anecdotal evidence, limited data |
| 0.0-0.3 | Very low confidence | Speculation, unreliable sources |

### 6.4 Documentation

Always include:

1. **Context Purpose**: What does this context represent?
2. **Applicability**: When/where does it apply?
3. **Requirements**: What conditions must be met?
4. **Relationships**: How does it relate to other contexts?
5. **Examples**: Show typical usage

```turtle
ctx:MedievalPeriod a ctx:TemporalContext ;
    rdfs:label "Medieval Period"@en ;
    rdfs:comment """
        Historical period in European history, approximately 500-1500 CE.
        Used for statements about medieval society, technology, and culture.
        Excludes modern and ancient periods.
    """@en ;
    ctx:requires [
        time:hasBeginning [ time:inXSDgYear 500 ] ;
        time:hasEnd [ time:inXSDgYear 1500 ]
    ] ;
    ctx:excludes ctx:ModernPeriod, ctx:AncientPeriod ;
    rdfs:seeAlso <https://en.wikipedia.org/wiki/Middle_Ages> .
```

### 6.5 Validation Workflow

Recommended workflow:

1. **Create data** with contextual annotations
2. **Validate structure** with SHACL shapes
3. **Apply inference rules** to enrich data
4. **Re-validate** after inference
5. **Query** to verify expected results
6. **Iterate** based on validation feedback

```bash
# Validation script
#!/bin/bash

echo "1. Validating structure..."
pyshacl -s shapes.ttl -df turtle data.ttl > validation-report.txt

if [ $? -eq 0 ]; then
    echo "✓ Structure valid"
    
    echo "2. Applying inference..."
    # Use your preferred reasoner
    jena infer --rules shapes.ttl data.ttl > inferred-data.ttl
    
    echo "3. Re-validating..."
    pyshacl -s shapes.ttl -df turtle inferred-data.ttl
    
    if [ $? -eq 0 ]; then
        echo "✓ All validation passed"
    fi
fi
```

---

## 7. Common Patterns

### 7.1 Pattern: Versioned Data

Track how data changes over time:

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#>
@prefix temp: <http://example.org/temporal/>
@prefix prov: <http://www.w3.org/ns/prov#>

# Version 1.0
:Dataset :hasValue "initial" 
    ~ _:v1 {| 
        ctx:holdsIn ctx:Version1 ;
        prov:generatedAtTime "2020-01-01"^^xsd:date ;
        temp:versionNumber 1
    |} .

# Version 2.0 (replaces v1)
:Dataset :hasValue "updated" 
    ~ _:v2 {| 
        ctx:holdsIn ctx:Version2 ;
        prov:generatedAtTime "2021-06-15"^^xsd:date ;
        temp:versionNumber 2 ;
        temp:replacedBy _:v1
    |} .
```

### 7.2 Pattern: Default with Exceptions

General rule with specific exceptions:

```turtle
@prefix default: <http://example.org/default/>

# Default rule
:Bird :canFly true 
    ~ {| 
        ctx:holdsIn ctx:DefaultBirdContext ;
        default:priority 10 ;
        rdfs:comment "Most birds can fly"
    |} .

# Exception
:Penguin :canFly false 
    ~ {| 
        ctx:holdsIn ctx:PenguinContext ;
        default:overrides ctx:DefaultBirdContext ;
        default:priority 20 ;
        rdfs:comment "Penguins are flightless"
    |} .
```

### 7.3 Pattern: Multi-Source Integration

Integrate data from multiple sources:

```turtle
# Source 1
:DrugX :hasSideEffect :Nausea 
    ~ {| 
        ctx:holdsIn ctx:ClinicalTrialData ;
        ctx:confidence 0.95 ;
        prov:wasAttributedTo :PharmaCo
    |} .

# Source 2
:DrugX :hasSideEffect :Nausea 
    ~ {| 
        ctx:holdsIn ctx:PatientReports ;
        ctx:confidence 0.7 ;
        prov:wasAttributedTo :PatientDatabase
    |} .

# Synthesized view
:DrugX :hasSideEffect :Nausea 
    ~ {| 
        ctx:holdsIn ctx:MedicalConsensus ;
        ctx:confidence 0.9 ;
        rdfs:comment "Confirmed by multiple sources" ;
        prov:wasDerivedFrom _:trial, _:reports
    |} .
```

---

## 8. Troubleshooting

### 8.1 Common Validation Errors

#### Error: "Circular subsumption detected"

**Cause**: Context subsumes itself through transitive chain

**Solution**:
```turtle
# Wrong
ctx:A ctx:subsumes ctx:B .
ctx:B ctx:subsumes ctx:C .
ctx:C ctx:subsumes ctx:A .  # Creates circle

# Fixed
ctx:A ctx:subsumes ctx:B .
ctx:B ctx:subsumes ctx:C .
# Remove circular reference
```

#### Error: "Exclusion not symmetric"

**Cause**: A excludes B, but B doesn't exclude A

**Solution**:
```turtle
# Wrong
ctx:Day ctx:excludes ctx:Night .
# Missing: ctx:Night ctx:excludes ctx:Day

# Fixed
ctx:Day ctx:excludes ctx:Night .
ctx:Night ctx:excludes ctx:Day .
```

#### Error: "Statement holds in mutually exclusive contexts"

**Cause**: Statement marked as valid in contexts that exclude each other

**Solution**:
```turtle
# Wrong
:X :prop :Y 
    ~ {| ctx:holdsIn ctx:Flying |},
    ~ {| ctx:holdsIn ctx:Grounded |} .
ctx:Flying ctx:excludes ctx:Grounded .

# Fixed - choose one or explain the conflict
:X :prop :Y 
    ~ {| 
        ctx:holdsIn ctx:Flying ;
        rdfs:comment "Value when flying"
    |} .

:X :prop :Z 
    ~ {| 
        ctx:holdsIn ctx:Grounded ;
        rdfs:comment "Different value when grounded"
    |} .
```

### 8.2 Query Debugging

#### Issue: Query returns no results

**Checklist**:
1. Verify RDF-star syntax support in your triple store
2. Check that contexts are properly defined
3. Ensure statements use correct reification syntax
4. Verify SPARQL engine supports `rdf:reifies` or quoted triples

**Debug query**:
```sparql
# Check what annotations exist
SELECT ?stmt ?prop ?value
WHERE {
    ?stmt rdf:reifies << ?s ?p ?o >> ;
          ?prop ?value .
}
LIMIT 10
```

#### Issue: Inference not working

**Checklist**:
1. Verify SHACL rules are loaded
2. Check that reasoner supports SHACL rules
3. Ensure rules have correct syntax
4. Verify entailment regime is enabled

**Test inference manually**:
```sparql
# Manually construct inferred triple
INSERT {
    ?ctx1 ctx:subsumes ?ctx3 .
}
WHERE {
    ?ctx1 ctx:subsumes ?ctx2 .
    ?ctx2 ctx:subsumes ?ctx3 .
    FILTER NOT EXISTS { ?ctx1 ctx:subsumes ?ctx3 }
}
```

### 8.3 Performance Issues

#### Issue: Slow queries on large datasets

**Solutions**:

1. **Add indexes** on context properties:
```sql
-- Triple store specific
CREATE INDEX idx_context_holds ON statements(context_id);
```

2. **Limit transitive queries**:
```sparql
# Instead of
?ctx ctx:subsumes+ ?child .

# Use bounded path
?ctx ctx:subsumes{1,5} ?child .
```

3. **Cache frequently used contexts**:
```sparql
# Materialize context hierarchy
INSERT {
    ?ancestor ctx:transitivelySubsumes ?descendant .
}
WHERE {
    ?ancestor ctx:subsumes+ ?descendant .
}
```

4. **Use named graphs** for context isolation:
```turtle
GRAPH ctx:AdultStageGraph {
    # All statements valid in adult stage
}
```

---

**End of Primer - Part 1**

Continue to [Advanced Topics and Integration Guide](PRIMER-ADVANCED.md) for:
- Integration with other ontologies (PROV, OWL-Time)
- Custom SHACL rules
- Performance optimization
- Real-world case studies
