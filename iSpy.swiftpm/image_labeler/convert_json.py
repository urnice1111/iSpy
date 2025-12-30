#!/usr/bin/env python3
"""
Convert JSON annotations from "filename" to "image" field.
Usage: python convert_json.py input.json output.json
   or: python convert_json.py input.json  (overwrites the same file)
"""

import json
import sys

def convert_json(input_path, output_path=None):
    if output_path is None:
        output_path = input_path
    
    # Read the JSON file
    with open(input_path, 'r') as f:
        data = json.load(f)
    
    # Convert each entry
    converted = []
    for item in data:
        # Get filename from either "filename" or "image" field
        filename = item.get("filename", item.get("image", ""))
        annotations = item.get("annotations", [])
        
        converted.append({
            "image": filename,
            "annotations": annotations
        })
    
    # Write the converted JSON
    with open(output_path, 'w') as f:
        json.dump(converted, f, indent=4)
    
    print(f"✅ Converted {len(converted)} entries")
    print(f"   Input:  {input_path}")
    print(f"   Output: {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python convert_json.py input.json [output.json]")
        print("  If output.json is not provided, overwrites input.json")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    convert_json(input_file, output_file)

