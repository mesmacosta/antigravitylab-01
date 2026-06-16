import os
import json
import random
import subprocess

def seed_data():
    project = os.environ.get("PROJECT_ID")
    table_id = f"{project}.enterprise_analytics.document_embeddings"

    filename = "dummy_data.jsonl"
    print("Generating 5000 dummy embeddings (this takes a few seconds)...")
    with open(filename, "w") as f:
        for i in range(5000):
            row = {
                "id": str(i),
                "filename": f"dummy_{i}.txt",
                "content": "dummy content",
                "embedding": [random.random() for _ in range(768)],
                "metadata": "{}"
            }
            f.write(json.dumps(row) + "\n")

    print(f"Truncating any existing dirty data in {table_id}...")
    subprocess.run([
        "bq", "query", "--use_legacy_sql=false", 
        f"TRUNCATE TABLE `{table_id}`"
    ], capture_output=True)

    print(f"Loading data into {table_id}...")
    result = subprocess.run([
        "bq", "load", "--source_format=NEWLINE_DELIMITED_JSON",
        table_id, filename
    ], capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"✅ Successfully seeded {table_id}.")
    else:
        print(f"❌ Failed to seed table:\n{result.stderr}")
        
    os.remove(filename)

if __name__ == "__main__":
    seed_data()
