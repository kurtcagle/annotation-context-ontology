# Quick Start Guide

## Installation

```bash
# Clone repository
git clone https://github.com/yourusername/annotation-context-ontology.git
cd annotation-context-ontology

# Install Python dependencies
pip install rdflib pyshacl
```

## Your First Context

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix ex: <http://example.org/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

# Define context
ctx:Summer a ctx:TemporalContext ;
    rdfs:label "Summer Season" .

# Use context
ex:Temperature ex:hasValue 25 
    ~ {| 
        ctx:holdsIn ctx:Summer ;
        ctx:confidence 0.9
    |} .
```

## Validate

```bash
pyshacl -s validation/context-shapes.ttl -df turtle your-data.ttl
```

## Query

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

SELECT ?value
WHERE {
    ?subject ?predicate ?value .
    ?stmt rdf:reifies << ?subject ?predicate ?value >> ;
          ctx:holdsIn ctx:Summer .
}
```

## Learn More

- [Full Specification](SPECIFICATION.md)
- [Primer with Examples](PRIMER.md)
- [Examples Directory](examples/)
