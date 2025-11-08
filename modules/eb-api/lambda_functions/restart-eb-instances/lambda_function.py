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
        print(f"[reboot-env] Rebooting instances for {env_name}: {ids}")
        ec2.reboot_instances(InstanceIds=ids)
    else:
        print(f"[reboot-env] No instances found for environment {env_name}")

    return ids


def lambda_handler(event, context):
    # Log the full event so we can see if CodePipeline.job is present
    print("[handler] Event:", json.dumps(event))

    job = event.get("CodePipeline.job")
    job_id = job.get("id") if job else None
    if job_id:
        print(f"[handler] Detected CodePipeline job id: {job_id}")
    else:
        print("[handler] No CodePipeline.job found in event (likely manual invoke)")

    try:
        env_web = os.environ.get("EB_ENV_WEB_NAME")
        env_worker = os.environ.get("EB_ENV_WORKER_NAME")

        print(f"[handler] EB_ENV_WEB_NAME={env_web}, EB_ENV_WORKER_NAME={env_worker}")

        all_ids = []
        all_ids += reboot_env(env_web)
        all_ids += reboot_env(env_worker)

        if not all_ids:
            print("[handler] No instances rebooted.")
            if job_id:
                print("[handler] Sending PutJobSuccessResult (no_instances).")
                cp.put_job_success_result(jobId=job_id)
            return {"status": "no_instances"}

        print(f"[handler] Rebooted instances: {all_ids}")

        if job_id:
            print("[handler] Sending PutJobSuccessResult (reboot_triggered).")
            cp.put_job_success_result(jobId=job_id)

        return {"status": "reboot_triggered", "instances": all_ids}

    except Exception as e:
        print(f"[handler] ERROR: {e}")

        if job_id:
            try:
                print("[handler] Sending PutJobFailureResult.")
                cp.put_job_failure_result(
                    jobId=job_id,
                    failureDetails={
                        "type": "JobFailed",
                        "message": str(e),
                    },
                )
            except Exception as inner:
                print(f"[handler] ERROR sending PutJobFailureResult: {inner}")

        raise
