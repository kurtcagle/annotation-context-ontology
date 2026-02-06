# Contributing to Annotation Context Ontology

Thank you for your interest in contributing to ACO!

## How to Contribute

### Reporting Issues

- Use GitHub Issues to report bugs
- Include minimal reproducible examples
- Specify your RDF library and version

### Suggesting Features

- Open a GitHub Issue with label "enhancement"
- Describe the use case and benefit
- Provide example data if possible

### Code Contributions

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Add tests for new functionality
5. Run validation: `./scripts/validate-all.sh`
6. Commit with clear messages
7. Push and create a Pull Request

## Development Setup

```bash
# Clone repository
git clone https://github.com/yourusername/annotation-context-ontology.git
cd annotation-context-ontology

# Install dependencies
pip install rdflib pyshacl pytest

# Run tests
pytest tests/
```

## Style Guidelines

- Use Turtle format for all RDF files
- Follow naming conventions in SPECIFICATION.md
- Add comments for complex SPARQL queries
- Include examples in documentation

## Questions?

Open a GitHub Discussion or email the maintainers.
