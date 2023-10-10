import { KubectlV29Layer } from "@aws-cdk/lambda-layer-kubectl-v29";
import * as cdk from "aws-cdk-lib";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as eks from "aws-cdk-lib/aws-eks";
import * as iam from "aws-cdk-lib/aws-iam";

class EKSCluster extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create a new VPC for our cluster
    const vpc = new ec2.Vpc(this, "EKSVpc");

    // Create Cluster with no default capacity (node group will be added later)
    const eksCluster = new eks.Cluster(this, "EKSCluster", {
      vpc: vpc,
      defaultCapacity: 0,
      version: eks.KubernetesVersion.V1_29,
      kubectlLayer: new KubectlV29Layer(this, "kubectl"),
      ipFamily: eks.IpFamily.IP_V4,
      clusterLogging: [
        // eks.ClusterLoggingTypes.API,
        // eks.ClusterLoggingTypes.AUTHENTICATOR,
        // eks.ClusterLoggingTypes.SCHEDULER,
        eks.ClusterLoggingTypes.AUDIT,
        // eks.ClusterLoggingTypes.CONTROLLER_MANAGER,
      ],
      outputClusterName: true,
      outputConfigCommand: true,
    });

    eksCluster.addNodegroupCapacity("custom-node-group", {
      amiType: eks.NodegroupAmiType.AL2_X86_64,
      instanceTypes: [new ec2.InstanceType("m5.large")],
      desiredSize: 2,
      diskSize: 20,
      nodeRole: new iam.Role(this, "eksClusterNodeGroupRole", {
        roleName: "eksClusterNodeGroupRole",
        assumedBy: new iam.ServicePrincipal("ec2.amazonaws.com"),
        managedPolicies: [
          iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEKSWorkerNodePolicy"),
          iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEC2ContainerRegistryReadOnly"),
          iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEKS_CNI_Policy"),
        ],
=======
    const vpc = new ec2.Vpc(this, 'EKSVpc');  // Create a new VPC for our cluster

    // IAM role for our EC2 worker nodes
    const workerRole = new iam.Role(this, 'EKSWorkerRole', {
      assumedBy: new iam.ServicePrincipal('ec2.amazonaws.com')
    });

    const eksCluster = new eks.Cluster(this, 'Cluster', {
      vpc: vpc,
      defaultCapacity: 0,  // we want to manage capacity our selves
      version: eks.KubernetesVersion.V1_27,
      kubectlLayer: new KubectlLayer(this, 'KubectlLayer'),
    });

    const onDemandASG = new autoscaling.AutoScalingGroup(this, 'OnDemandASG', {
      vpc: vpc,
      role: workerRole,
      minCapacity: 1,
      maxCapacity: 10,
      allowAllOutbound: false,
      instanceType: new ec2.InstanceType('t3.medium'),
      machineImage: new eks.EksOptimizedImage({
        kubernetesVersion: eks.KubernetesVersion.V1_27.version,
        nodeType: eks.NodeType.STANDARD  // without this, incorrect SSM parameter for AMI is resolved
>>>>>>> b29d87a (Fix(ts:eks/cluster): Fix Warnings)
      }),
    });

    // Managed Addon: kube-proxy
    const kubeProxy = new eks.CfnAddon(this, "addonKubeProxy", {
      addonName: "kube-proxy",
      clusterName: eksCluster.clusterName,
    });

    // Managed Addon: coredns
    const coreDns = new eks.CfnAddon(this, "addonCoreDns", {
      addonName: "coredns",
      clusterName: eksCluster.clusterName,
    });

    // Managed Addon: vpc-cni
    const vpcCni = new eks.CfnAddon(this, "addonVpcCni", {
      addonName: "vpc-cni",
      clusterName: eksCluster.clusterName,
    });
  }
}

const app = new cdk.App();
new EKSCluster(app, "MyEKSCluster");
app.synth();
