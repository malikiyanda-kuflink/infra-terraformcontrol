import os
import json
import boto3

eb = boto3.client("elasticbeanstalk")
ec2 = boto3.client("ec2")
cp = boto3.client("codepipeline")


def reboot_env(env_name: str):
    if not env_name:
        return []

    resp = eb.describe_environment_resources(EnvironmentName=env_name)
    instances = resp.get("EnvironmentResources", {}).get("Instances", [])
    ids = [i["Id"] for i in instances]

    if ids:
        print(f"Rebooting instances for {env_name}: {ids}")
        ec2.reboot_instances(InstanceIds=ids)
    else:
        print(f"No instances found for environment {env_name}")

    return ids


def lambda_handler(event, context):
    # Log full event so we can see CodePipeline.job structure
    print("Event:", json.dumps(event))

    job = event.get("CodePipeline.job")
    job_id = job.get("id") if job else None

    try:
        env_web = os.environ.get("EB_ENV_WEB_NAME")
        env_worker = os.environ.get("EB_ENV_WORKER_NAME")

        all_ids = []
        all_ids += reboot_env(env_web)
        all_ids += reboot_env(env_worker)

        if not all_ids:
            print("No instances rebooted.")
            if job_id:
                cp.put_job_success_result(jobId=job_id)
            # For non-CodePipeline manual test invokes
            return {"status": "no_instances"}

        print(f"Rebooted instances: {all_ids}")

        if job_id:
            cp.put_job_success_result(jobId=job_id)

        return {"status": "reboot_triggered", "instances": all_ids}

    except Exception as e:
        print(f"Error during restart-eb-instances: {e}")

        if job_id:
            # Tell CodePipeline this action failed
            cp.put_job_failure_result(
                jobId=job_id,
                failureDetails={
                    "type": "JobFailed",
                    "message": str(e),
                },
            )

        # Make sure error is visible in logs
        raise
