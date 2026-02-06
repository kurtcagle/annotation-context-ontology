#!/bin/bash
echo "ACO Validation Suite"
echo "===================="
for file in examples/*.ttl; do
    echo "Validating $file..."
    pyshacl -s validation/context-shapes.ttl -df turtle "$file" 2>/dev/null && echo "✓ Pass" || echo "✗ Fail"
done
