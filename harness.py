import asyncio
import os
import subprocess
import sys
import logging
from google.antigravity import Agent, LocalAgentConfig
from google.antigravity.hooks.policy import allow

# Hide verbose debug logs unless needed
logging.getLogger("google.antigravity").setLevel(logging.WARNING)

async def run_workflow(agent, prompt: str):
    """Executes a workflow and streams the response."""
    response = await agent.chat(prompt)
    async for chunk in response:
        # Print each token/chunk to stdout as it arrives
        print(chunk, end="", flush=True)
    print("\n")
    return response

def verify_scripts():
    """Runs local verification scripts and returns True if successful."""
    print("\n🔍 Running Post-Execution Verification...")
    
    # Run BigQuery Vector verification
    vector_result = subprocess.run(
        ["bash", ".agents/skills/provision-bigquery-vector/scripts/verify_bq_vector.sh"],
        capture_output=True, text=True
    )
    print(vector_result.stdout)
    if vector_result.returncode != 0:
        print(f"❌ BigQuery Vector verification failed:\n{vector_result.stderr}", file=sys.stderr)
        return False, vector_result.stderr

    # Run BigQuery verification
    bq_result = subprocess.run(
        ["bash", ".agents/skills/stream-to-bigquery/scripts/verify_bq.sh"],
        capture_output=True, text=True
    )
    print(bq_result.stdout)
    if bq_result.returncode != 0:
        print(f"❌ BigQuery verification failed:\n{bq_result.stderr}", file=sys.stderr)
        return False, bq_result.stderr

    print("✅ All automated verifications passed successfully!")
    return True, ""

async def main():
    workspace_path = os.path.abspath(".")
    
    config = LocalAgentConfig(
        workspaces=[workspace_path],
        vertex=True,
        project=os.environ.get("PROJECT_ID"),
        location="global",
        policies=[allow("run_command")]
    )
    
    async with Agent(config) as agent:
        print(f"\n🚀 Starting Data Engineer Workflow in {workspace_path}...\n")
        
        # Iteration 1
        await run_workflow(agent, "/dataengineer")
        
        success, error_msg = verify_scripts()
        
        # Self-healing loop (max 1 retry)
        if not success:
            print("\n⚠️ Verification failed! Engaging self-healing loop for 1 retry...\n")
            retry_prompt = (
                f"The verification failed with the following error:\n{error_msg}\n"
                "Please analyze the failure and run the necessary commands to fix it."
            )
            await run_workflow(agent, retry_prompt)
            
            # Verify again
            success, _ = verify_scripts()
            if not success:
                print("\n❌ Workflow failed after retry. Please inspect manually.")
                sys.exit(1)
                
if __name__ == "__main__":
    asyncio.run(main())
