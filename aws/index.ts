import { DatabaseCluster, DatabaseClusterEngine } from "@aws-cdk/aws-rds";
import { App, Stack, StackProps } from '@aws-cdk/core';
import { InstanceType, InstanceClass, InstanceSize, Vpc, SubnetType } from "@aws-cdk/aws-ec2";


class ZoneminderStack extends Stack {
  constructor(scope: App, id: string, props?: StackProps) {
    super(scope, id, props);

    const vpc = Vpc.fromLookup(this, "VPC", { isDefault: true });

    new DatabaseCluster(this, 'mysql', {
      engine: DatabaseClusterEngine.AURORA_MYSQL,
      masterUser: {
        username: 'admin'
      },
      instanceProps: {
        vpc,
        vpcSubnets: {
          subnetType: SubnetType.PUBLIC,
        },
        instanceType: InstanceType.of(InstanceClass.A1, InstanceSize.LARGE),
      },
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
app.synth();



