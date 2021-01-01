import { DatabaseCluster, DatabaseClusterEngine } from "@aws-cdk/aws-rds";
import { App, Stack, StackProps } from '@aws-cdk/core';
import { InstanceClass, InstanceSize, InstanceType, SecurityGroup, SubnetType, Vpc } from "@aws-cdk/aws-ec2";


class ZoneminderStack extends Stack {
  constructor(scope: App, id: string, props?: StackProps) {
    super(scope, id, props);

    const vpc = Vpc.fromLookup(this, "VPC", { isDefault: true });

    /*const rdsClusterPrameterGroup = new ClusterParameterGroup(this, 'rdsClusterPrameterGroup', {
      description: 'MySQL 5.7',
      family: 'aurora-mysql5.7',
      parameters: {},
    })*/

    new DatabaseCluster(this, 'mysql', {
      engine: DatabaseClusterEngine.AURORA_MYSQL,
      engineVersion: '5.7',
      masterUser: {
        username: 'admin'
      },
      instanceProps: {
        vpc,
        vpcSubnets: {
          subnetType: SubnetType.PUBLIC,
        },
        instanceType: InstanceType.of(InstanceClass.T2, InstanceSize.SMALL),
        securityGroup: SecurityGroup.fromSecurityGroupId(this, 'sg', 'sg-178e4b6b'),
      },
      parameterGroup: {
        parameterGroupName: 'default.aurora-mysql5.7'
      } as any
    })


  }
}

const app = new App()
new ZoneminderStack(app, 'zoneminder', {
  env: {
    region: 'us-east-1',
    account: '818517237865',
  }
});



