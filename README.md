# Annotation Context Ontology (ACO)

**Version:** 1.0.0  
**Status:** Working Draft  
**Last Updated:** 2026-02-05

## Overview

The Annotation Context Ontology (ACO) is a comprehensive framework for representing **contextual truth** in RDF data using RDF-star annotations. ACO enables you to express that statements are true under certain conditions, within specific contexts, or from particular perspectives—essential for domains like historical records, scientific data, multi-agent systems, and knowledge graphs with conflicting sources.

### Key Capabilities

- ✅ **Context Scoping**: Define when and where statements hold true
- ✅ **RDF-star Native**: Uses Turtle 1.2 annotation syntax (`~ {| ... |}`)
- ✅ **Multi-dimensional**: Temporal, spatial, epistemic, and modal contexts
- ✅ **Validation**: Comprehensive SHACL 1.2 constraints and rules
- ✅ **Inference**: Automatic reasoning over context hierarchies
- ✅ **Interoperable**: Integrates with PROV, OWL-Time, and other W3C standards

## Quick Start

### Installation

```bash
git clone https://github.com/kurtcagle/annotation-context-ontology.git
cd annotation-context-ontology
```

### Basic Example

```turtle
@prefix ctx: <http://ontologist.substack.com/ns/context#> .
@prefix dragon: <http://example.org/dragons/> .
@prefix animal: <http://example.org/animal/> .

# Define contexts
ctx:JuvenileStage a ctx:TemporalContext ;
    rdfs:label "Juvenile Stage" ;
    ctx:requires [ animal:ageInYears [ sh:maxExclusive 100 ] ] .

ctx:AdultStage a ctx:TemporalContext ;
    rdfs:label "Adult Stage" ;
    ctx:requires [ animal:ageInYears [ sh:minInclusive 100 ] ] .

# Contextual statement
dragon:Smaug animal:hasLength 8 
    ~ _:juvenileAssertion {| 
        ctx:holdsIn ctx:JuvenileStage ;
        ctx:failsIn ctx:AdultStage ;
        ctx:confidence 0.95
    |} .

dragon:Smaug animal:hasLength 23 
    ~ _:adultAssertion {| 
        ctx:holdsIn ctx:AdultStage ;
        ctx:failsIn ctx:JuvenileStage ;
        ctx:confidence 0.98
    |} .
```

## Repository Structure

```
annotation-context-ontology/
├── README.md                          # This file
├── SPECIFICATION.md                   # Complete technical specification
├── PRIMER.md                          # Tutorial and use cases
├── ontology/
│   ├── context-core.ttl              # Core ontology
│   ├── context-temporal.ttl          # Temporal extensions
│   ├── context-epistemic.ttl         # Epistemic extensions
│   ├── context-modal.ttl             # Modal logic extensions
│   └── context-full.ttl              # All modules combined
├── validation/
│   └── context-shapes.ttl            # SHACL 1.2 validation
├── examples/
│   ├── example-temporal.ttl          # Temporal context examples
│   ├── example-epistemic.ttl         # Provenance examples
│   ├── example-modal.ttl             # Possible worlds examples
│   ├── example-multi-agent.ttl       # Multiple perspectives
│   └── example-integrated.ttl        # Combined patterns
├── tests/
│   ├── valid/                        # Valid test cases
│   └── invalid/                      # Invalid test cases
├── docs/
│   └── images/                       # Diagrams and figures
├── LICENSE                           # MIT License
└── CONTRIBUTING.md                   # Contribution guidelines
```

## Documentation

- **[SPECIFICATION.md](SPECIFICATION.md)** - Formal specification of all classes, properties, shapes, and rules
- **[PRIMER.md](PRIMER.md)** - Tutorial with practical examples and use cases
- **[Examples](examples/)** - Runnable code examples for different scenarios

## Features

### 1. Context Types

- **Temporal Contexts**: Time-based validity (age, date ranges, events)
- **Spatial Contexts**: Location-based validity (regions, positions)
- **Epistemic Contexts**: Knowledge source and belief systems
- **Modal Contexts**: Possible worlds and counterfactuals

### 2. Context Relationships

- **Subsumption**: Hierarchical context relationships
- **Exclusion**: Mutually incompatible contexts
- **Requirements**: Conditions for context applicability

### 3. Statement Properties

- **holdsIn**: Statement is true in this context
- **failsIn**: Statement is false in this context
- **undefinedIn**: Truth value undefined in this context
- **confidence**: Degree of confidence (0.0-1.0)

### 4. SHACL Validation

- ✓ Core constraints (labels, types, cardinality)
- ✓ Relationship validation (circular references, symmetry)
- ✓ Inference rules (transitive closure, inheritance)
- ✓ Conflict detection (mutually exclusive contexts)
- ✓ Data quality scoring and suggestions

## Use Cases

ACO is designed for:

1. **Historical Records**: Conflicting accounts from different sources
2. **Scientific Data**: Measurements under varying conditions
3. **Multi-Agent Systems**: Different perspectives and beliefs
4. **Temporal Data**: Properties that change over time
5. **Provenance**: Tracking source and reliability of information
6. **Modal Reasoning**: Possible, necessary, and counterfactual statements
7. **Knowledge Graphs**: Integrating data from multiple sources

## Requirements

### Software

- **RDF Library**: Any RDF 1.2 / RDF-star compatible library
  - Apache Jena 4.7.0+
  - RDFLib 7.0.0+ (Python)
  - Oxigraph
  - MarkLogic Semantics

- **SHACL Validator**: SHACL 1.2 compatible validator
  - pySHACL 0.20.0+
  - Apache Jena with SHACL
  - TopBraid SHACL API

- **Turtle 1.2**: Parser supporting RDF-star annotation syntax

### Standards

- RDF 1.2 (2024)
- Turtle 1.2 with RDF-star (2026 Working Draft)
- SHACL 1.2 (2024)
- SPARQL 1.2 with RDF-star extensions

## Validation

Validate your data against ACO constraints:

```bash
# Using pySHACL
pyshacl -s validation/context-shapes.ttl \
        -e validation/context-shapes.ttl \
        -i rdfs \
        -f turtle \
        your-data.ttl

# Using Apache Jena
riot --validate your-data.ttl
shacl validate --shapes=validation/context-shapes.ttl --data=your-data.ttl
```

## SPARQL Queries

Query contextual data:

```sparql
PREFIX ctx: <http://ontologist.substack.com/ns/context#>

# Get all statements valid in a specific context
SELECT ?subject ?predicate ?object ?confidence
WHERE {
    ?subject ?predicate ?object .
    ?stmt rdf:reifies << ?subject ?predicate ?object >> ;
          ctx:holdsIn ctx:AdultStage ;
          ctx:confidence ?confidence .
}
ORDER BY DESC(?confidence)
```

See [PRIMER.md](PRIMER.md) for more query examples.

## Integration with Other Ontologies

ACO is designed to work with:

- **PROV-O**: Provenance tracking (`prov:wasAttributedTo`, `prov:generatedAtTime`)
- **OWL-Time**: Temporal intervals and instants
- **SKOS**: Concept hierarchies for context taxonomies
- **Dublin Core**: Metadata about contexts and sources
- **Schema.org**: Linking contexts to real-world entities

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Contribute

- 🐛 Report bugs and issues
- 💡 Suggest new features or context types
- 📝 Improve documentation
- ✨ Submit example use cases
- 🧪 Add test cases
- 🔧 Fix bugs or implement features

## Testing

Run the test suite:

```bash
# Validate all examples
for file in examples/*.ttl; do
    echo "Validating $file..."
    pyshacl -s validation/context-shapes.ttl -e validation/context-shapes.ttl "$file"
done

# Run unit tests (requires pytest)
pytest tests/
```

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## Citation

If you use ACO in your research, please cite:

```bibtex
@misc{aco2026,
  title={Annotation Context Ontology: A Framework for Contextual Truth in RDF},
  author={[Your Name]},
  year={2026},
  url={https://github.com/yourusername/annotation-context-ontology}
}
```

## Authors

- **[Your Name]** - Initial work

## Acknowledgments

- W3C RDF-star Community Group
- SHACL Community Group
- Semantic Web community

## Resources

- **Specification**: [https://w3c.github.io/rdf-star/](https://w3c.github.io/rdf-star/)
- **Turtle 1.2**: [https://www.w3.org/TR/rdf12-turtle/](https://www.w3.org/TR/rdf12-turtle/)
- **SHACL**: [https://www.w3.org/TR/shacl/](https://www.w3.org/TR/shacl/)
- **RDF 1.2**: [https://www.w3.org/TR/rdf12-concepts/](https://www.w3.org/TR/rdf12-concepts/)

## Versioning

We use [SemVer](http://semver.org/) for versioning. For available versions, see the [tags on this repository](https://github.com/yourusername/annotation-context-ontology/tags).

## Changelog

### Version 1.0.0 (2026-02-05)
- Initial release
- Core context ontology
- Temporal, spatial, epistemic, and modal extensions
- Complete SHACL 1.2 validation
- Comprehensive documentation and examples

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/annotation-context-ontology/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/annotation-context-ontology/discussions)
- **Email**: your.email@example.com

## Roadmap

- [ ] Python library for programmatic context management
- [ ] JavaScript/TypeScript library
- [ ] Visual context editor
- [ ] Integration with popular triple stores
- [ ] Extended examples for specific domains (healthcare, finance, etc.)
- [ ] Performance optimization guidelines
- [ ] RDFS/OWL reasoning integration

---

**Star ⭐ this repository if you find it useful!**
