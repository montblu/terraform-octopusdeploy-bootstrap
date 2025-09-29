#!/usr/bin/env python3
import json
import re
import subprocess
import os.path


################################################################################
# Internal variables. Verify if they apply to your terraform code:
__tf_module_resource = "module.octopus_deployment_process"
__supported_provider = 'provider["registry.terraform.io/octopusdeploy/octopusdeploy"]'
__tb_site = "k8s"
__tb_prefix = f"terrabutler tf -site {__tb_site}"
__tb_site_dir = f"site_{__tb_site}"
################################################################################

def get_tfstate():
    p = subprocess.run(
        args=[*__tb_prefix.split(" "), "state", "pull"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=False,
        check=False,
    )

    if p.returncode > 0:
        print("Error:")
        print(p.stderr.decode("UTF-8"))
        exit(p.returncode)

    with open(f"{__tb_site_dir}/.ignore.tfstate.origin.json", "w") as f:
        f.write(p.stdout.decode("UTF-8"))

    tfstate = json.loads(p.stdout.decode("UTF-8"))
    tfstate["serial"] += 1

    # save a rollback (serial must always increase)
    tfstate_rollback = json.loads(p.stdout.decode("UTF-8"))
    tfstate_rollback["serial"] += 4
    with open(f"{__tb_site_dir}/.ignore.tfstate.rollback.json", "w") as f:
        json.dump(tfstate_rollback, f, indent=2)

    return tfstate


def get_legacy_process_resource(tfstate):
    legacy_process_resource = None
    for i, resource in enumerate(tfstate["resources"]):
        if (
            resource.get("module", "") == __tf_module_resource
            and resource.get("type", "") == "octopusdeploy_deployment_process"
            and resource.get("name", "") == "all"
        ):
            if resource["provider"] != __supported_provider:
                print(
                    f"WARN: support to migrate only with '{__supported_provider}', "
                    f"found {resource["provider"]}. STOP IF YOU DO NOT KNOW WHAT THIS MEANS!"
                )

            legacy_process_resource = resource
            tfstate["resources"].pop(i)
            break
    else:
        print("No legacy resources found. Exiting...")
        exit(0)

    return legacy_process_resource


def build_new_resources_dict():

    new_tf_resources = {
        "process": {
            "module": __tf_module_resource,
            "mode": "managed",
            "type": "octopusdeploy_process",
            "name": "all",
            "provider": __supported_provider,
            "instances": [],
        },
        "process_steps_order": {
            "module": __tf_module_resource,
            "mode": "managed",
            "type": "octopusdeploy_process_steps_order",
            "name": "steps_order",
            "provider": __supported_provider,
            "instances": [],
        },
        "step-slack": {
            "module": __tf_module_resource,
            "mode": "managed",
            "type": "octopusdeploy_process_templated_step",
            "name": "slack_notification_step",
            "provider": __supported_provider,
            "instances": [],
        },
    }
    for name in ["set_image", "cronjob", "newrelic", "optional", "global_optional"]:
        new_tf_resources[f"step-{name}"] = {
            "module": __tf_module_resource,
            "mode": "managed",
            "type": "octopusdeploy_process_step",
            "name": f"{name}_step",
            "provider": __supported_provider,
            "instances": [],
        }
    return new_tf_resources


def new_step_resource(key, id, p_id, space_id):
    return {
        "index_key": key,
        "schema_version": 0,
        "attributes": {
            "id": id,
            "process_id": p_id,
            "space_id": space_id,
            "steps": [],  # irrelevant for steps
        },
        "sensitive_attributes": [],
        "dependencies": [],
    }


def rebuild_tf_resources(legacy_process_resource):
    new_tf_resources = build_new_resources_dict()

    removed_deployment_processes = []
    _r_target = ".".join(
        [
            f"{legacy_process_resource["module"]}",
            f"{legacy_process_resource["type"]}",
            f"{legacy_process_resource["name"]}",
        ]
    )

    for l_process in legacy_process_resource["instances"]:
        key = l_process["index_key"]
        p_id = l_process["attributes"]["id"]
        space_id = l_process["attributes"]["space_id"]

        removed_deployment_processes.append(f'{_r_target}["{key}"]')

        for i, step in enumerate(l_process["attributes"].get("step", [])):

            if i == 0:
                new_tf_resources["process_steps_order"]["instances"].append(
                    new_step_resource(key, p_id, p_id, space_id)
                )

            new_tf_resources["process_steps_order"]["instances"][-1]["attributes"]["steps"].append(step["id"])
            if step["name"].startswith("Set image on for "):
                proj = step["name"].split("Set image on for ")[1]
                new_tf_resources["step-set_image"]["instances"].append(
                    new_step_resource(key, f"{p_id}:{step['id']}", p_id, space_id)
                )
            elif step["name"].startswith("Set image for "):
                proj = step["name"].split("Set image for ")[1]
                new_tf_resources["step-cronjob"]["instances"].append(
                    new_step_resource(key, f"{p_id}:{step['id']}", p_id, space_id)
                )
            elif step["name"].startswith("New Relic Deployment for "):
                proj = step["name"].split("New Relic Deployment for ")[1]
                new_tf_resources["step-newrelic"]["instances"].append(
                    new_step_resource(key, f"{p_id}:{step['id']}", p_id, space_id)
                )
            elif step["name"].startswith("Slack Detailed Notification for "):
                proj = step["name"].split("Slack Detailed Notification for ")[1]
                new_tf_resources["step-slack"]["instances"].append(
                    {
                        "index_key": key,
                        "schema_version": 0,
                        "attributes": {
                            "id": f"{p_id}:{step['id']}",
                            "process_id": p_id,
                            "space_id": space_id,
                            "template_id": step["run_script_action"][0]["action_template"][0]["id"],
                            "template_version": step["run_script_action"][0]["action_template"][0]["version"],
                        },
                        "sensitive_attributes": [],
                        "dependencies": [],
                    }
                )
            else:
                if step["run_kubectl_script_action"]["name"].startswith("Optional Step for - "):
                    proj = step["name"]
                    new_tf_resources["step-optional"]["instances"].append(
                        new_step_resource(key, f"{p_id}:{step['id']}", p_id, space_id)
                    )
                elif step["run_kubectl_script_action"]["name"].startswith("Optional Step for "):
                    proj = step["name"].split(" - ")[-1]
                    new_tf_resources["step-global_optional"]["instances"].append(
                        new_step_resource(key, f"{p_id}:{step['id']}", p_id, space_id)
                    )
                else:
                    print("Error! Step resource could not be guessed:")
                    print(json.dumps(step))
                    exit(5)

        del l_process["attributes"]["step"]
        new_tf_resources["process"]["instances"].append(
            {
                "index_key": proj,
                "schema_version": 0,
                "attributes": l_process["attributes"],
                "sensitive_attributes": [],
                "dependencies": [],
            }
        )
    return new_tf_resources, removed_deployment_processes


def build_tf_imports(new_tf_resources):
    lines = []
    for resource in new_tf_resources:
        m = resource["module"]
        t = resource["type"]
        n = resource["name"]

        if "instances" not in resource:
            id = instance["attributes"]["id"]
            lines.append("import {")
            lines.append(f"  to = {m}.{t}.{n}")
            lines.append(f'  id = "{id}"')
            lines.append("}")
            lines.append("")

        for instance in resource.get("instances", []):
            key = instance["index_key"]
            id = instance["attributes"]["id"]
            lines.append("import {")
            lines.append(f'  to = {m}.{t}.{n}["{key}"]')
            lines.append(f'  id = "{id}"')
            lines.append("}")
            lines.append("")

    return "\n".join(lines)


########################################################################################################################


def main():
    print()
    print(f"DEBUG: calling {__tb_prefix} state pull")
    tfstate = get_tfstate()
    print()

    legacy_process_resource = get_legacy_process_resource(tfstate)
    new_tf_resources, removed_deployment_processes = rebuild_tf_resources(legacy_process_resource)

    print("# To remove legacy resources from tfstate, execute:")
    print(__tb_prefix, "state rm", *[f"'{s}'" for s in removed_deployment_processes])
    print("")

    tf_imports = build_tf_imports(new_tf_resources.values())
    with open(f"{__tb_site_dir}/octopus_imports.tf", "w") as f:
        f.write(tf_imports)
    print(f"DEBUG: wrote imports to: {__tb_site_dir}/octopus_imports.tf")

    print("")
    print(f"{__tb_prefix} apply")
    print(f"# {__tb_prefix} state push .ignore.tfstate.rollback.json # ROLLBACK")


if __name__ == "__main__":
    raise SystemExit(main())
