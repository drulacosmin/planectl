"""
Pulumi program: team namespace provisioner.

For each team, creates:
  - A Namespace labelled managed-by=pulumi
  - A ResourceQuota scoped to that namespace

Config:
  pulumi config set teams '["alpha","beta","gamma"]'   # override team list
"""

import pulumi
import pulumi_kubernetes as k8s

config = pulumi.Config()
teams: list[str] = config.get_object("teams") or ["alpha", "beta"]

for team in teams:
    ns = k8s.core.v1.Namespace(
        f"ns-{team}",
        metadata=k8s.meta.v1.ObjectMetaArgs(
            name=f"team-{team}",
            labels={
                "managed-by": "pulumi",
                "team": team,
            },
        ),
    )

    k8s.core.v1.ResourceQuota(
        f"quota-{team}",
        metadata=k8s.meta.v1.ObjectMetaArgs(
            name="default-quota",
            namespace=ns.metadata.name,
        ),
        spec=k8s.core.v1.ResourceQuotaSpecArgs(
            hard={
                "pods": "10",
                "requests.cpu": "2",
                "requests.memory": "4Gi",
                "limits.cpu": "4",
                "limits.memory": "8Gi",
            }
        ),
        opts=pulumi.ResourceOptions(parent=ns),
    )

    pulumi.export(f"team_{team}_namespace", ns.metadata.name)
