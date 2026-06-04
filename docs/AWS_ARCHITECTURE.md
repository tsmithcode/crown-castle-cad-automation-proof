# AWS Architecture Addendum

This addendum extends the CAD automation proof with an AWS-native service map for an API-callable drawing automation platform.

## One-Line Flow

```text
Internal UI -> API Gateway / API service -> job record -> S3 input package -> Step Functions + SQS -> CAD worker -> S3 output package -> review UI / notification -> CloudWatch + CloudTrail audit trail
```

## What The Technical Discussion Clarified

- The first release should improve the deterministic 60-70% automated path instead of forcing 100% automation before data quality supports it.
- The system should bring sensitive CAD automation workflow execution in-house where appropriate.
- The architecture should make uncertainty visible to reviewers: source-of-truth driven, rule-derived, assumed, conflicting, or missing.
- The worker layer is the key risk because CAD runtime and licensing constraints determine whether the execution path is Windows, containerized, Autodesk Platform Services, or hybrid.

## Expected AWS Services

| Service | Expected role | Why |
|---|---|---|
| [Amazon API Gateway](https://docs.aws.amazon.com/apigateway/) | Job submission and status API front door. | Keeps intake secure, versionable, and callable by internal apps. |
| [AWS Lambda](https://docs.aws.amazon.com/lambda/) | Lightweight validation, routing, metadata normalization, notifications. | Good for small event-driven work; not the place for heavy CAD execution. |
| [Amazon ECS/Fargate](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-configuration.html) | Containerized API services or workers when feasible. | Useful when workloads can be packaged as containers without managing server clusters directly. |
| [Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) | Kubernetes-hosted services/workers if that is the internal platform standard. | Fits teams already standardizing background jobs and deployment operations on Kubernetes. |
| [Amazon DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/) or [Amazon RDS/Aurora](https://docs.aws.amazon.com/rds/) | Job records, order references, rule versions, validation status, review state. | DynamoDB fits simple job state; RDS/Aurora fits relational reporting and structured rule history. |
| [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/userguide/) | Versioned input/output packages. | Stores DWGs, PDFs, JSON, templates, SOW/rules, reports, logs, and generated artifacts. |
| [AWS Step Functions](https://docs.aws.amazon.com/step-functions/latest/dg/welcome.html) | Multi-stage orchestration. | Coordinates gather-inputs, validate, generate, QA, package, notify, retry, and exception paths. |
| [Amazon SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html) | Async broker between intake and CAD workers. | Decouples web/API traffic from long-running CAD execution and provides backpressure. |
| [Amazon CloudWatch](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/) | Logs, metrics, dashboards, alarms. | Shows what each job did, how long it took, why it failed, and which workers are healthy. |
| [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-user-guide.html) | AWS API activity audit trail. | Supports traceability, governance, and security review. |
| [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html) | Encryption key management. | Protects proprietary drawing packages, metadata, and service data at rest. |
| [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) | Managed credentials and rotation. | Avoids hard-coded credentials in services, workers, and deployment configuration. |

## CAD Worker Runtime Decision

| Option | Use when | First spike question |
|---|---|---|
| Windows EC2 worker | Full AutoCAD, COM automation, installed plugins, fonts, CTB/STB, or desktop plotting behavior is required. | Can the worker run unattended, isolated, licensed, and cleaned up after each job? |
| ECS/Fargate worker | The CAD execution path can be containerized without desktop AutoCAD behavior. | Can required dependencies, binaries, and output behavior run reliably in a container? |
| EKS worker | Crown Castle already uses Kubernetes for services or background jobs. | Is the platform standard EKS, and can CAD jobs be modeled as worker pods/jobs? |
| Autodesk Platform Services / Design Automation | Required DWG operations fit APS bundles, work items, dependencies, and timeouts. | Do AutoLISP/.NET/plugin dependencies and plotting expectations fit APS execution? |
| Hybrid | AWS controls intake, orchestration, storage, and audit while CAD execution runs in a specialized worker boundary. | Which layer owns retries, artifact cleanup, and failure evidence? |

## Review-Ready Output Contract

Each job should produce:

- Updated DWG.
- PDF preview.
- Validation report.
- Change summary.
- Structured job log.
- Confidence flags: source-of-truth driven, rule-derived, assumed, conflicting, or missing.
- Reviewer notes and final approval state.

## Gaps To Qualify Early

1. Which AWS platform patterns are already standard: ECS/Fargate, EKS, EC2, Lambda, or mixed?
2. Which CAD runtime is required for faithful AutoCAD behavior?
3. What data source owns the order, tower asset, equipment, template, and drawing package metadata?
4. Which fields are never safe to infer?
5. What must happen on partial success: generate valid portions, block the job, or route to review?
6. What security boundary is required for proprietary drawings and source-system metadata?
