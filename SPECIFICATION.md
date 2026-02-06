# Annotation Context Ontology - Technical Specification

**Version:** 1.0.0  
**Status:** Working Draft  
**Date:** 2026-02-05  
**Editors:** [Your Name]

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Namespace Declarations](#2-namespace-declarations)
3. [Classes](#3-classes)
4. [Properties](#4-properties)
5. [SHACL Shapes](#5-shacl-shapes)
6. [Inference Rules](#6-inference-rules)
7. [Conformance](#7-conformance)
8. [References](#8-references)

---

## 1. Introduction

### 1.1 Purpose

The Annotation Context Ontology (ACO) provides a formal framework for representing **contextual truth** in RDF data. ACO enables statements to be annotated with conditions under which they hold true, fail, or remain undefined.

### 1.2 Scope

ACO covers:
- Context definition and classification
- Contextual validity of RDF statements
- Context relationships (subsumption, exclusion)
- Integration with RDF-star reification
- Validation and inference rules

### 1.3 Design Principles

1. **RDF-star Native**: Uses Turtle 1.2 annotation syntax
2. **Modular**: Core + optional extensions (temporal, epistemic, modal, spatial)
3. **Inference-Enabled**: SHACL rules for automatic reasoning
4. **Validation-First**: Comprehensive constraints for data quality
5. **Standards-Compliant**: Compatible with W3C recommendations

### 1.4 Conformance Classes

- **ACO Core**: Basic context scoping (REQUIRED)
- **ACO Temporal**: Time-based contexts (OPTIONAL)
- **ACO Spatial**: Location-based contexts (OPTIONAL)
- **ACO Epistemic**: Knowledge source contexts (OPTIONAL)
- **ACO Modal**: Possible worlds and modality (OPTIONAL)

---

## 2. Namespace Declarations

### 2.1 Ontology Namespaces

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
@prefix sh: <http://www.w3.org/ns/shacl#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix time: <http://www.w3.org/2006/time#> .
```

### 2.2 Preferred Prefix

The preferred namespace prefix for ACO is `ctx`.

### 2.3 Ontology Metadata

```turtle
<http://ontologist.substack.com/ns/context#> a owl:Ontology ;
    rdfs:label "Annotation Context Ontology"@en ;
    rdfs:comment "Framework for representing contextual truth in RDF"@en ;
    owl:versionInfo "1.0.0" ;
    owl:versionIRI <http://ontologist.substack.com/ns/context#1.0.0/> ;
    prov:wasAttributedTo <https://example.org/people/author> ;
    prov:generatedAtTime "2026-02-05"^^xsd:date .
```

---

## 3. Classes

### 3.1 Core Classes

#### 3.1.1 ctx:Context

**IRI:** `http://ontologist.substack.com/ns/context#Context`

**Definition:** A scope or situation within which statements hold, fail, or remain undefined.

**SubClass Of:** `rdfs:Resource`

**Disjoint With:** `rdf:Statement`

**Properties:**
- `rdfs:label` (required, 1..1, xsd:string)
- `rdfs:comment` (optional, 0..1, xsd:string)
- `ctx:subsumes` (optional, 0..*, ctx:Context)
- `ctx:excludes` (optional, 0..*, ctx:Context)
- `ctx:requires` (optional, 0..*, rdfs:Resource)

**Constraints:**
- MUST have exactly one `rdfs:label` between 3-200 characters
- MUST NOT subsume or exclude itself
- MUST NOT create circular subsumption chains
- If excludes another context, that context MUST exclude this one (symmetry)

**Example:**
```turtle
ctx:DefaultContext a ctx:Context ;
    rdfs:label "Default Context" ;
    rdfs:comment "The context assumed when no other context is specified" .
```

---

#### 3.1.2 ctx:TemporalContext

**IRI:** `http://ontologist.substack.com/ns/context#TemporalContext`

**Definition:** A context defined by temporal boundaries or conditions.

**SubClass Of:** `ctx:Context`

**Properties:** Inherits from `ctx:Context`, plus:
- `ctx:requires` SHOULD specify temporal constraints

**Constraints:**
- SHOULD specify age-related or time-based requirements

**Example:**
```turtle
ctx:AdultStage a ctx:TemporalContext ;
    rdfs:label "Adult Stage" ;
    ctx:requires [
        animal:ageInYears [ 
            sh:minInclusive 100 ;
            sh:maxExclusive 500 
        ]
    ] .
```

---

#### 3.1.3 ctx:SpatialContext

**IRI:** `http://ontologist.substack.com/ns/context#SpatialContext`

**Definition:** A context defined by spatial boundaries or location.

**SubClass Of:** `ctx:Context`

**Properties:** Inherits from `ctx:Context`, plus:
- `ctx:requires` MUST specify spatial constraints

**Example:**
```turtle
ctx:InsideMountain a ctx:SpatialContext ;
    rdfs:label "Inside Mountain" ;
    ctx:requires [
        geo:within :LonelyMountain
    ] .
```

---

#### 3.1.4 ctx:EpistemicContext

**IRI:** `http://ontologist.substack.com/ns/context#EpistemicContext`

**Definition:** A context based on knowledge source, belief system, or epistemic status.

**SubClass Of:** `ctx:Context`

**Properties:** Inherits from `ctx:Context`

**Example:**
```turtle
ctx:WelshMythology a ctx:EpistemicContext ;
    rdfs:label "Welsh Mythology" ;
    rdfs:comment "Context of traditional Welsh mythological accounts" .
```

---

#### 3.1.5 ctx:ModalContext

**IRI:** `http://ontologist.substack.com/ns/context#ModalContext`

**Definition:** A context representing a possible world or modal qualification.

**SubClass Of:** `ctx:Context`

**Properties:** Inherits from `ctx:Context`

**Example:**
```turtle
ctx:ActualWorld a ctx:ModalContext ;
    rdfs:label "Actual World" ;
    rdfs:comment "The way things actually are" .
```

---

### 3.2 Supporting Classes

#### 3.2.1 ctx:ContextConflict

**IRI:** `http://ontologist.substack.com/ns/context#ContextConflict`

**Definition:** Represents a detected conflict between mutually exclusive contexts.

**Properties:**
- `ctx:conflictingContexts` (required, 2..*, ctx:Context)
- `rdfs:comment` (required, 1..1, xsd:string)

**Note:** Automatically generated by inference rules.

---

#### 3.2.2 ctx:ConfidenceWarning

**IRI:** `http://ontologist.substack.com/ns/context#ConfidenceWarning`

**Definition:** Warning about confidence propagation issues.

**Properties:**
- `rdfs:comment` (required, 1..1, xsd:string)

**Note:** Automatically generated by validation rules.

---

#### 3.2.3 ctx:ApplicabilityViolation

**IRI:** `http://ontologist.substack.com/ns/context#ApplicabilityViolation`

**Definition:** Violation where context requirements are not met.

**Properties:**
- `ctx:inapplicableContext` (required, 1..1, ctx:Context)
- `rdfs:comment` (required, 1..1, xsd:string)

---

## 4. Properties

### 4.1 Context Validity Properties

#### 4.1.1 ctx:holdsIn

**IRI:** `http://ontologist.substack.com/ns/context#holdsIn`

**Definition:** The annotated statement is true within the specified context.

**Domain:** `rdf:Statement`  
**Range:** `ctx:Context`  
**Cardinality:** 0..*  
**Functional:** No

**Constraints:**
- MUST reference a valid `ctx:Context` instance
- MUST NOT specify both `holdsIn` and `failsIn` for the same context
- If statement holds in context A, and A subsumes B, statement holds in B (inherited via inference)

**Usage:**
```turtle
dragon:Smaug animal:hasLength 23 
    ~ _:assertion {| 
        ctx:holdsIn ctx:AdultStage 
    |} .
```

---

#### 4.1.2 ctx:failsIn

**IRI:** `http://ontologist.substack.com/ns/context#failsIn`

**Definition:** The annotated statement is false within the specified context.

**Domain:** `rdf:Statement`  
**Range:** `ctx:Context`  
**Cardinality:** 0..*  
**Functional:** No

**Constraints:**
- MUST reference a valid `ctx:Context` instance
- MUST NOT specify both `holdsIn` and `failsIn` for the same context
- If statement fails in context A, and B subsumes A, statement fails in B (inherited via inference)

**Usage:**
```turtle
dragon:Smaug animal:hasLength 23 
    ~ _:assertion {| 
        ctx:failsIn ctx:JuvenileStage 
    |} .
```

---

#### 4.1.3 ctx:undefinedIn

**IRI:** `http://ontologist.substack.com/ns/context#undefinedIn`

**Definition:** The truth value of the annotated statement is undefined within the specified context.

**Domain:** `rdf:Statement`  
**Range:** `ctx:Context`  
**Cardinality:** 0..*  
**Functional:** No

**Usage:**
```turtle
dragon:Unknown animal:hasLength 15 
    ~ {| 
        ctx:undefinedIn ctx:ModernEra ;
        rdfs:comment "No reliable data exists for this period"
    |} .
```

---

#### 4.1.4 ctx:defaultContext

**IRI:** `http://ontologist.substack.com/ns/context#defaultContext`

**Definition:** The context assumed when no explicit context is specified.

**Domain:** `rdf:Statement`  
**Range:** `ctx:Context`  
**Cardinality:** 0..1  
**Functional:** Yes

**Constraints:**
- Maximum one default context per statement

**Usage:**
```turtle
_:stmt ctx:defaultContext ctx:DefaultContext .
```

---

#### 4.1.5 ctx:confidence

**IRI:** `http://ontologist.substack.com/ns/context#confidence`

**Definition:** Degree of confidence in the contextual statement (0.0 = no confidence, 1.0 = absolute certainty).

**Domain:** `rdf:Statement`  
**Range:** `xsd:decimal`  
**Cardinality:** 0..1  
**Functional:** Yes

**Constraints:**
- MUST be between 0.0 and 1.0 inclusive
- If child context has higher confidence than parent, generates warning

**Usage:**
```turtle
dragon:Smaug animal:hasLength 23 
    ~ {| 
        ctx:holdsIn ctx:AdultStage ;
        ctx:confidence 0.95
    |} .
```

---

### 4.2 Context Relationship Properties

#### 4.2.1 ctx:subsumes

**IRI:** `http://ontologist.substack.com/ns/context#subsumes`

**Definition:** This context is more general than (includes) the other context.

**Domain:** `ctx:Context`  
**Range:** `ctx:Context`  
**Cardinality:** 0..*  
**Characteristics:** Transitive (via inference)

**Constraints:**
- MUST NOT create circular subsumption chains
- MUST NOT subsume itself
- If A subsumes B and A excludes C, then B SHOULD exclude C (propagation via inference)

**Transitivity Rule:** If A subsumes B and B subsumes C, then A subsumes C (inferred).

**Usage:**
```turtle
ctx:AllDragons ctx:subsumes ctx:WelshDragons .
ctx:WelshDragons ctx:subsumes ctx:RedDragons .
# Inferred: ctx:AllDragons ctx:subsumes ctx:RedDragons .
```

---

#### 4.2.2 ctx:excludes

**IRI:** `http://ontologist.substack.com/ns/context#excludes`

**Definition:** This context is incompatible with the other context (both cannot hold simultaneously).

**Domain:** `ctx:Context`  
**Range:** `ctx:Context`  
**Cardinality:** 0..*  
**Characteristics:** Symmetric (enforced via validation and inference)

**Constraints:**
- MUST be symmetric: if A excludes B, then B MUST exclude A
- MUST NOT exclude itself
- SHOULD NOT both subsume and exclude the same context

**Usage:**
```turtle
ctx:InFlight ctx:excludes ctx:AtRest .
ctx:AtRest ctx:excludes ctx:InFlight .  # Symmetric
```

---

#### 4.2.3 ctx:requires

**IRI:** `http://ontologist.substack.com/ns/context#requires`

**Definition:** Conditions that must be satisfied for this context to be applicable.

**Domain:** `ctx:Context`  
**Range:** `rdfs:Resource` (typically blank nodes with constraints)  
**Cardinality:** 0..*

**Usage:**
```turtle
ctx:AdultStage ctx:requires [
    animal:ageInYears [ 
        sh:minInclusive 100 
    ]
] .
```

---

### 4.3 Conflict and Warning Properties

#### 4.3.1 ctx:hasConflict

**IRI:** `http://ontologist.substack.com/ns/context#hasConflict`

**Definition:** Links a statement to a detected context conflict.

**Domain:** `rdf:Statement`  
**Range:** `ctx:ContextConflict`  
**Note:** Generated automatically by inference rules

---

#### 4.3.2 ctx:hasWarning

**IRI:** `http://ontologist.substack.com/ns/context#hasWarning`

**Definition:** Links a statement to a detected warning.

**Domain:** `rdf:Statement`  
**Range:** `ctx:ConfidenceWarning`  
**Note:** Generated automatically by inference rules

---

#### 4.3.3 ctx:hasViolation

**IRI:** `http://ontologist.substack.com/ns/context#hasViolation`

**Definition:** Links a statement to an applicability violation.

**Domain:** `rdf:Statement`  
**Range:** `ctx:ApplicabilityViolation`  
**Note:** Generated automatically by inference rules

---

#### 4.3.4 ctx:conflictingContexts

**IRI:** `http://ontologist.substack.com/ns/context#conflictingContexts`

**Definition:** Identifies contexts involved in a conflict.

**Domain:** `ctx:ContextConflict`  
**Range:** `ctx:Context`  
**Cardinality:** 2..*

---

#### 4.3.5 ctx:inapplicableContext

**IRI:** `http://ontologist.substack.com/ns/context#inapplicableContext`

**Definition:** Context that cannot be applied due to unmet requirements.

**Domain:** `ctx:ApplicabilityViolation`  
**Range:** `ctx:Context`  
**Cardinality:** 1..1

---

## 5. SHACL Shapes

### 5.1 Core Shapes

#### 5.1.1 ctx:ContextShape

**Target:** `sh:targetClass ctx:Context`

**Purpose:** Validates all context instances

**Constraints:**

1. **Label Requirement**
   - Path: `rdfs:label`
   - Min Count: 1
   - Max Count: 1
   - Datatype: `xsd:string`
   - Min Length: 3
   - Max Length: 200

2. **Comment Optional**
   - Path: `rdfs:comment`
   - Max Count: 1
   - Datatype: `xsd:string`
   - Max Length: 1000

3. **Subsumption Type**
   - Path: `ctx:subsumes`
   - Class: `ctx:Context`

4. **Exclusion Type**
   - Path: `ctx:excludes`
   - Class: `ctx:Context`

**SPARQL Constraints:**

1. **No Self-Subsumption:**
```sparql
SELECT $this
WHERE {
    $this ctx:subsumes $this .
}
```

2. **No Self-Exclusion:**
```sparql
SELECT $this
WHERE {
    $this ctx:excludes $this .
}
```

3. **No Circular Subsumption:**
```sparql
SELECT $this
WHERE {
    $this ctx:subsumes+ $this .
}
```

4. **Symmetric Exclusion:**
```sparql
SELECT $this ?other
WHERE {
    $this ctx:excludes ?other .
    FILTER NOT EXISTS { ?other ctx:excludes $this }
}
```

---

#### 5.1.2 ctx:ReifiedStatementShape

**Target:** `sh:targetSubjectsOf ctx:holdsIn, ctx:failsIn, ctx:undefinedIn, ctx:defaultContext`

**Purpose:** Validates contextually annotated statements

**Constraints:**

1. **Reification Requirement**
   - Path: `rdf:reifies`
   - Min Count: 1
   - Max Count: 1

2. **Confidence Range**
   - Path: `ctx:confidence`
   - Datatype: `xsd:decimal`
   - Min Inclusive: 0.0
   - Max Inclusive: 1.0

**SPARQL Constraints:**

1. **No Contradictory Contexts:**
```sparql
SELECT $this ?ctx
WHERE {
    $this ctx:holdsIn ?ctx ;
          ctx:failsIn ?ctx .
}
```

2. **No Conflicting Exclusions:**
```sparql
SELECT $this ?ctx1 ?ctx2
WHERE {
    $this ctx:holdsIn ?ctx1, ?ctx2 .
    ?ctx1 ctx:excludes ?ctx2 .
    FILTER(?ctx1 != ?ctx2)
}
```

---

### 5.2 Specialized Context Shapes

#### 5.2.1 ctx:TemporalContextShape

**Target:** `sh:targetClass ctx:TemporalContext`

**Inherits:** `ctx:ContextShape`

**Additional Constraints:**
- Path: `ctx:requires`
- Min Count: 1
- Should specify temporal constraints (Warning level)

---

#### 5.2.2 ctx:SpatialContextShape

**Target:** `sh:targetClass ctx:SpatialContext`

**Inherits:** `ctx:ContextShape`

**Additional Constraints:**
- Path: `ctx:requires`
- Min Count: 1
- Should specify spatial constraints (Warning level)

---

#### 5.2.3 ctx:EpistemicContextShape

**Target:** `sh:targetClass ctx:EpistemicContext`

**Inherits:** `ctx:ContextShape`

**Additional Constraints:**
- Should specify knowledge source requirements (Info level)

---

#### 5.2.4 ctx:ModalContextShape

**Target:** `sh:targetClass ctx:ModalContext`

**Inherits:** `ctx:ContextShape`

---

### 5.3 Property Shapes

#### 5.3.1 ctx:HoldsInShape

**Path:** `ctx:holdsIn`

**Constraints:**
- Class: `ctx:Context`
- Must not reference excluded contexts

---

#### 5.3.2 ctx:FailsInShape

**Path:** `ctx:failsIn`

**Constraints:**
- Class: `ctx:Context`

---

#### 5.3.3 ctx:SubsumptionShape

**Path:** `ctx:subsumes`

**Constraints:**
- Class: `ctx:Context`
- Transitive closure check (Info level)

---

#### 5.3.4 ctx:ExclusionShape

**Path:** `ctx:excludes`

**Constraints:**
- Class: `ctx:Context`
- No simultaneous subsumption and exclusion
- Inheritance propagation check

---

### 5.4 Data Quality Shapes

#### 5.4.1 ctx:FullySpecifiedStatementShape

**Purpose:** Best practice validation for well-documented statements

**Severity:** `sh:Info`

**Constraints:**
1. Should have `ctx:holdsIn` (min 1)
2. Should have `ctx:confidence` (min 1)
3. Should have `rdfs:comment` (min 1)

---

#### 5.4.2 ctx:DataQualityShape

**Purpose:** Calculate data quality score (0-100)

**Scoring:**
- 20 points: `ctx:holdsIn` present
- 20 points: `ctx:confidence` present
- 20 points: `rdfs:comment` present
- 20 points: `prov:generatedAtTime` present
- 20 points: epistemic status present

**Output:** Generates score and suggestions for improvement

---

### 5.5 Performance and Optimization Shapes

#### 5.5.1 ctx:HierarchyValidationShape

**Purpose:** Detect hierarchy issues

**Checks:**
- Orphaned contexts (not connected to hierarchy)
- Ambiguous multiple parents
- Deep nesting (depth > 5)
- Broad fan-out (>10 direct children)

**Severity:** `sh:Info`

---

## 6. Inference Rules

### 6.1 Context Relationship Rules

#### 6.1.1 Subsumption Transitivity Rule

**Name:** `ctx:SubsumptionTransitiveRule`

**Purpose:** Compute transitive closure of subsumption

**Rule:**
```sparql
CONSTRUCT {
    ?ctx1 ctx:subsumes ?ctx3 .
}
WHERE {
    ?ctx1 ctx:subsumes ?ctx2 .
    ?ctx2 ctx:subsumes ?ctx3 .
    FILTER(?ctx1 != ?ctx3)
    FILTER NOT EXISTS { ?ctx1 ctx:subsumes ?ctx3 }
}
```

---

#### 6.1.2 Symmetric Exclusion Rule

**Name:** `ctx:SymmetricExclusionRule`

**Purpose:** Enforce symmetric exclusion relationships

**Rule:**
```sparql
CONSTRUCT {
    ?ctx2 ctx:excludes ?ctx1 .
}
WHERE {
    ?ctx1 ctx:excludes ?ctx2 .
    FILTER NOT EXISTS { ?ctx2 ctx:excludes ?ctx1 }
}
```

---

#### 6.1.3 Exclusion Propagation Rule

**Name:** `ctx:ExclusionPropagationRule`

**Purpose:** Propagate exclusions through subsumption hierarchy

**Rule:**
```sparql
CONSTRUCT {
    ?ctx1 ctx:excludes ?subContext .
}
WHERE {
    ?ctx1 ctx:excludes ?ctx2 .
    ?ctx2 ctx:subsumes ?subContext .
    FILTER(?ctx2 != ?subContext)
    FILTER NOT EXISTS { ?ctx1 ctx:excludes ?subContext }
}
```

---

### 6.2 Statement Validity Rules

#### 6.2.1 Inherited Holds In Rule

**Name:** `ctx:InheritedHoldsInRule`

**Purpose:** Propagate validity down subsumption hierarchy

**Rule:**
```sparql
CONSTRUCT {
    ?stmt ctx:holdsIn ?subContext .
}
WHERE {
    ?stmt ctx:holdsIn ?superContext .
    ?superContext ctx:subsumes ?subContext .
    FILTER NOT EXISTS { ?stmt ctx:holdsIn ?subContext }
    FILTER NOT EXISTS { ?stmt ctx:failsIn ?subContext }
}
```

---

#### 6.2.2 Inherited Fails In Rule

**Name:** `ctx:InheritedFailsInRule`

**Purpose:** Propagate invalidity up subsumption hierarchy

**Rule:**
```sparql
CONSTRUCT {
    ?stmt ctx:failsIn ?superContext .
}
WHERE {
    ?stmt ctx:failsIn ?subContext .
    ?superContext ctx:subsumes ?subContext .
    FILTER NOT EXISTS { ?stmt ctx:failsIn ?superContext }
    FILTER NOT EXISTS { ?stmt ctx:holdsIn ?superContext }
}
```

---

#### 6.2.3 Default Context Assignment Rule

**Name:** `ctx:DefaultContextRule`

**Purpose:** Assign default context to unannotated statements

**Rule:**
```sparql
CONSTRUCT {
    ?stmt ctx:holdsIn ctx:DefaultContext .
}
WHERE {
    ?stmt rdf:reifies ?triple .
    FILTER NOT EXISTS {
        ?stmt ctx:holdsIn|ctx:failsIn|ctx:undefinedIn ?anyContext .
    }
    FILTER NOT EXISTS {
        ?stmt ctx:defaultContext ?defaultCtx .
    }
}
```

---

### 6.3 Conflict Detection Rules

#### 6.3.1 Conflict Detection Rule

**Name:** `ctx:ConflictDetectionRule`

**Purpose:** Detect statements holding in mutually exclusive contexts

**Rule:**
```sparql
CONSTRUCT {
    ?stmt ctx:hasConflict [
        a ctx:ContextConflict ;
        ctx:conflictingContexts ?ctx1, ?ctx2 ;
        rdfs:comment ?message
    ] .
}
WHERE {
    ?stmt ctx:holdsIn ?ctx1, ?ctx2 .
    ?ctx1 ctx:excludes ?ctx2 .
    FILTER(?ctx1 != ?ctx2)
    BIND(CONCAT("Statement holds in mutually exclusive contexts: ", 
                STR(?ctx1), " and ", STR(?ctx2)) AS ?message)
}
```

---

#### 6.3.2 Confidence Propagation Rule

**Name:** `ctx:ConfidencePropagationRule`

**Purpose:** Warn when child context has higher confidence than parent

**Severity:** `sh:Warning`

**Rule:**
```sparql
CONSTRUCT {
    ?childStmt ctx:hasWarning [
        a ctx:ConfidenceWarning ;
        rdfs:comment ?message
    ] .
}
WHERE {
    ?parentStmt ctx:holdsIn ?parentCtx ;
                ctx:confidence ?parentConf .
    ?childStmt ctx:holdsIn ?childCtx ;
               ctx:confidence ?childConf .
    ?parentCtx ctx:subsumes ?childCtx .
    ?parentStmt rdf:reifies ?triple .
    ?childStmt rdf:reifies ?triple .
    FILTER(?childConf > ?parentConf)
    BIND(CONCAT("Child context confidence (", STR(?childConf), 
                ") exceeds parent confidence (", STR(?parentConf), ")") AS ?message)
}
```

---

#### 6.3.3 Applicability Check Rule

**Name:** `ctx:ApplicabilityCheckRule`

**Purpose:** Verify contexts are applicable to their subjects

**Rule:**
```sparql
CONSTRUCT {
    ?stmt ctx:hasViolation [
        a ctx:ApplicabilityViolation ;
        ctx:inapplicableContext ?context ;
        rdfs:comment "Context requirements not met by subject"
    ] .
}
WHERE {
    ?stmt ctx:holdsIn ?context ;
          rdf:reifies <<?subject ?predicate ?object>> .
    ?context ctx:requires ?requirement .
    FILTER NOT EXISTS {
        ?subject ?reqProp ?reqValue .
        ?requirement ?reqProp ?constraint .
    }
}
```

---

## 7. Conformance

### 7.1 Conformance Levels

#### Level 1: Core Conformance (REQUIRED)

An implementation conforms to ACO Core if it:

1. **Supports all core classes:**
   - `ctx:Context`
   - Ability to create context instances

2. **Supports all core properties:**
   - `ctx:holdsIn`
   - `ctx:failsIn`
   - `ctx:subsumes`
   - `ctx:excludes`

3. **Validates against core constraints:**
   - Label requirements
   - No circular subsumption
   - Symmetric exclusion

4. **Implements at least the following inference rules:**
   - Subsumption transitivity
   - Symmetric exclusion

#### Level 2: Extended Conformance (OPTIONAL)

An implementation conforms to ACO Extended if it meets Level 1 and additionally:

1. **Supports specialized context types:**
   - At least one of: Temporal, Spatial, Epistemic, Modal

2. **Implements all inference rules:**
   - All rules from Section 6

3. **Validates data quality:**
   - Quality scoring
   - Best practice recommendations

#### Level 3: Full Conformance (OPTIONAL)

An implementation conforms to ACO Full if it meets Level 2 and additionally:

1. **Supports all context types**
2. **Implements all SHACL shapes**
3. **Provides performance optimization warnings**
4. **Supports integration with external ontologies** (PROV, OWL-Time, etc.)

---

### 7.2 Validation Requirements

#### Minimal Validation

Implementations MUST validate:
- Context label presence and format
- No self-reference in relationships
- Type consistency

#### Standard Validation

Implementations SHOULD validate:
- Circular subsumption detection
- Exclusion symmetry
- Context-statement contradictions
- Confidence bounds

#### Complete Validation

Implementations MAY validate:
- Data quality scores
- Optimization warnings
- Best practice conformance

---

### 7.3 Serialization Requirements

#### Required Formats

Implementations MUST support:
- Turtle 1.2 with RDF-star annotation syntax
- RDF 1.2 (N-Triples star format acceptable)

#### Recommended Formats

Implementations SHOULD support:
- JSON-LD 1.1 with RDF-star
- TriG 1.2 with RDF-star (for named graphs)

#### Optional Formats

Implementations MAY support:
- RDF/XML with reification
- N-Quads with RDF-star

---

### 7.4 Query Requirements

#### Required

Implementations MUST support:
- SPARQL 1.1 basic graph patterns
- Property paths (for transitive queries)
- FILTER expressions

#### Recommended

Implementations SHOULD support:
- SPARQL 1.2 with RDF-star triple patterns: `<< ?s ?p ?o >>`
- Named graphs for context isolation
- Inference/reasoning during queries

---

## 8. References

### 8.1 Normative References

- **[RDF12-CONCEPTS]** RDF 1.2 Concepts and Abstract Syntax. W3C Recommendation. 2024.
  https://www.w3.org/TR/rdf12-concepts/

- **[TURTLE12]** RDF 1.2 Turtle. W3C Working Draft. 2026.
  https://www.w3.org/TR/2026/WD-rdf12-turtle-20260129/

- **[RDF-STAR]** RDF-star and SPARQL-star. W3C Community Group Draft. 2024.
  https://w3c.github.io/rdf-star/

- **[SHACL]** Shapes Constraint Language (SHACL). W3C Recommendation. 2017.
  https://www.w3.org/TR/shacl/

- **[SHACL-ADVANCED]** SHACL Advanced Features. W3C Note. 2017.
  https://www.w3.org/TR/shacl-af/

- **[SPARQL11]** SPARQL 1.1 Query Language. W3C Recommendation. 2013.
  https://www.w3.org/TR/sparql11-query/

### 8.2 Informative References

- **[PROV-O]** PROV-O: The PROV Ontology. W3C Recommendation. 2013.
  https://www.w3.org/TR/prov-o/

- **[OWL-TIME]** Time Ontology in OWL. W3C Recommendation. 2017.
  https://www.w3.org/TR/owl-time/

- **[SKOS]** SKOS Simple Knowledge Organization System Reference. W3C Recommendation. 2009.
  https://www.w3.org/TR/skos-reference/

---

## Appendix A: Complete Class Hierarchy

```
rdfs:Resource
└── ctx:Context
    ├── ctx:TemporalContext
    ├── ctx:SpatialContext
    ├── ctx:EpistemicContext
    └── ctx:ModalContext

ctx:ContextConflict
ctx:ConfidenceWarning
ctx:ApplicabilityViolation
```

---

## Appendix B: Complete Property List

### Object Properties
- `ctx:holdsIn`
- `ctx:failsIn`
- `ctx:undefinedIn`
- `ctx:defaultContext`
- `ctx:subsumes`
- `ctx:excludes`
- `ctx:requires`
- `ctx:hasConflict`
- `ctx:hasWarning`
- `ctx:hasViolation`
- `ctx:conflictingContexts`
- `ctx:inapplicableContext`

### Datatype Properties
- `ctx:confidence` (xsd:decimal)

---

## Appendix C: SHACL Shapes Summary

### Node Shapes (10)
1. `ctx:ContextShape`
2. `ctx:TemporalContextShape`
3. `ctx:SpatialContextShape`
4. `ctx:EpistemicContextShape`
5. `ctx:ModalContextShape`
6. `ctx:ReifiedStatementShape`
7. `ctx:FullySpecifiedStatementShape`
8. `ctx:DataQualityShape`
9. `ctx:HierarchyValidationShape`
10. `ctx:IntegratedStatementShape`

### Property Shapes (4)
1. `ctx:HoldsInShape`
2. `ctx:FailsInShape`
3. `ctx:SubsumptionShape`
4. `ctx:ExclusionShape`

### Inference Rules (9)
1. `ctx:SubsumptionTransitiveRule`
2. `ctx:SymmetricExclusionRule`
3. `ctx:ExclusionPropagationRule`
4. `ctx:InheritedHoldsInRule`
5. `ctx:InheritedFailsInRule`
6. `ctx:DefaultContextRule`
7. `ctx:ConflictDetectionRule`
8. `ctx:ConfidencePropagationRule`
9. `ctx:ApplicabilityCheckRule`

---

## Appendix D: Change Log

### Version 1.0.0 (2026-02-05)
- Initial specification release
- Core context ontology defined
- Specialized context types added
- Complete SHACL validation framework
- Comprehensive inference rules
- Conformance levels established

---

**End of Specification**
