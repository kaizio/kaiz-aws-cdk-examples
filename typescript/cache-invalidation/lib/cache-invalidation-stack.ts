import * as cdk from 'aws-cdk-lib';
import { LambdaFunction } from 'aws-cdk-lib/aws-events-targets';
import { Function, InlineCode, Runtime } from 'aws-cdk-lib/aws-lambda';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';

export class CacheInvalidationStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Create s3 bucket
    const bucket = new cdk.aws_s3.Bucket(this, 'Website', {
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      eventBridgeEnabled: true,
    });

    // Create CloudFront distribution
    const distribution = new cdk.aws_cloudfront.Distribution(this, 'Distribution', {
      defaultRootObject: 'index.html',
      defaultBehavior: {
        origin: new cdk.aws_cloudfront_origins.S3Origin(bucket),
        allowedMethods: cdk.aws_cloudfront.AllowedMethods.ALLOW_GET_HEAD,
        cachedMethods: cdk.aws_cloudfront.CachedMethods.CACHE_GET_HEAD,
      },
    });

    // Create lambda function for invalidating cache
    const edgeLambda = new Function(this, 'InvalidateCache', {
      handler: 'index.handler',
      runtime: Runtime.NODEJS_20_X,
      environment: {
        distributionId: distribution.distributionId,
        path: '/*'
      },
      code: InlineCode.fromInline(`
  const { CloudFrontClient, CreateInvalidationCommand } = require("@aws-sdk/client-cloudfront");

  exports.handler = async (event, context) => {
  // Get the distribution ID and paths to invalidate from the event
  const distributionId = process.env.distributionId;
  const path = process.env.path;
  
  console.log('Distribution ID:', distributionId);
  console.log('Path:', path);

  // Create a CloudFront client
  const cloudfront = new CloudFrontClient();

  // Create the invalidation request
  const command = new CreateInvalidationCommand({
    DistributionId: distributionId,
    InvalidationBatch: {
      Paths: {
        Quantity: 1,
        Items: [path]
      },
      CallerReference: new Date().toISOString()
    }
  });

  const response = await cloudfront.send(command);

  // Return the invalidation request ID
  return {
    statusCode: 200,
    body: response.Invalidation.Id
  };
};
      `),
    });

    // Grant lambda function permission to invalidate cache
    distribution.grantCreateInvalidation(edgeLambda);

    // Create an EventBridge rule that triggers the edgelambda to run whenever index.html is uploaded to the s3 bucket
    const rule = new cdk.aws_events.Rule(this, 'Rule', {
      eventPattern: {
        source: ['aws.s3'],
        detailType: ['Object Created'],
        detail: {
          bucket: {
            name: [bucket.bucketName]
          },
          object: {
            key: ['index.html']
          }
        }
      },
      targets: [new LambdaFunction(edgeLambda)],
    });

  }
}
