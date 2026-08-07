# FRED JABBARI

**St. Louis, MO • 314-370-3779 • ffjabbari@gmail.com • [ffjconsultingllc.com](https://ffjconsultingllc.com)**

Principal Agentic AI Architect / Principal Cloud Architect (Agentic Systems, MCP, AWS, Kubernetes, Platform Engineering)

US Citizen • Active Security Clearance

---

## SUMMARY

Principal Agentic AI Architect and hands-on engineer with 25+ years building enterprise platforms, now specialising in autonomous agent systems on AWS. Designs and ships multi-agent architectures end to end: Model Context Protocol (MCP) servers exposing enterprise systems as governed agent tools, sub-agent orchestration with dependency-ordered execution, retrieval-augmented reasoning over vector search, and human-in-the-loop controls that keep AI-assisted delivery auditable and standards-compliant. Hands-on across Amazon Bedrock and AgentCore, Amazon Q, Kiro, Claude, Cursor, ChatGPT and the OpenAI API, on a foundation of AWS, Kubernetes/EKS, microservices, CI/CD and API management. Currently sole architect and developer of an autonomous SDLC governance platform at Charter Communications spanning EKS, DocumentDB, OpenSearch vector search and Bedrock. M.S. Artificial Intelligence and M.S. Computer Science, Washington University in St. Louis.

---

## KEY SKILLS

**Agentic AI & Orchestration:** Multi-agent architectures, Model Context Protocol (MCP) servers and agent ecosystems, sub-agent delegation, dependency-ordered task graphs, event-driven agent hooks, spec-driven AI development (Amazon Kiro), human-in-the-loop approval gates, AI governance controls for automated delivery

**AI Platforms & Models:** Amazon Bedrock, Bedrock AgentCore, Bedrock Data Automation (BDA), Amazon Q, Claude (Anthropic), ChatGPT / OpenAI API, GitHub Copilot, Cursor, SageMaker, LangChain, prompt engineering, LLM integration

**Vector Search & RAG:** Amazon OpenSearch Serverless (kNN vector search), Bedrock Titan Embeddings v2, embedding pipelines, semantic retrieval, pluggable vector-store abstractions, Textract / IDP

**Languages:** Java, Spring Boot, Python, C#, .NET Core, Go, TypeScript, JavaScript, Svelte/SvelteKit, Node.js

**AWS & Cloud:** EKS, ECS, Lambda, API Gateway, S3, VPC, IAM, CloudWatch, CloudTrail, EventBridge, SQS, Karpenter, Textract, IDP; Azure

**Containers & Platform:** Docker, Kubernetes (EKS), Helm, Rancher, Red Hat OpenShift (enterprise Kubernetes; deployment on cloud and on‑prem)

**Data & persistence:** PostgreSQL, Microsoft SQL Server, MongoDB, Amazon DocumentDB, OpenSearch, NoSQL, Redis, ElastiCache

**Kubernetes & GitOps:** Amazon EKS, Istio service mesh, Helm, ArgoCD, Sealed Secrets, HPA, Karpenter, Rancher, Red Hat OpenShift

**DevOps & CI/CD:** Jenkins, GitHub Actions, GitLab CI/CD, Bitbucket, SonarQube, Terraform, CloudFormation, AWS CDK, CDKTF, Octopus, env0

**Integration & Messaging:** Apigee, API Gateway, SQS, RabbitMQ, EventBridge, REST APIs, event-driven architecture

**Architecture:** Microservices, modernization, resiliency, integration patterns, IaC, internal developer platforms

**Security:** SSO, OAuth2, SAML, JWT, Okta, RBAC, certificate validation

**Additional:** Maven, Gradle, REST/OpenAPI, SQL, Agile (Scrum), Jira, message queues, and related enterprise tooling

---

## PROFESSIONAL EXPERIENCE

### FFJ Consulting LLC (Client: Charter Communications) — St. Louis, MO
**Principal Agentic AI Architect / Enterprise Cloud Architect** | May 2026 – Present

Sole architect and developer of an autonomous SDLC governance platform ("OSK" / E-KIRO) that evaluates every production deployment request against enterprise governance rules, built across three repositories and roughly 890 commits.

**Agentic AI Platform & Orchestration**

- Architected and built a multi-agent SDLC governance platform in which AI agents ingest specifications, evaluate deployment tickets against 16 codified governance rules, and surface violations to engineers — replacing manual release review with automated, auditable evaluation.
- Implemented Model Context Protocol (MCP) servers exposing JIRA and GitLab as governed agent tools, giving AI agents structured, permissioned access to enterprise systems instead of unmanaged API calls.
- Designed agent orchestration patterns including sub-agent delegation, dependency-ordered task execution (17-wave execution graphs), event-driven hooks on tool use and task lifecycle, and mandatory human approval gates on destructive operations.
- Built a spec-driven development pipeline — requirements → design → tasks — in which agents generate reviewable engineering artifacts with full traceability from requirement to implementation to test.
- Delivered a three-tier steering and standards engine (Enterprise → Domain → Application) with override, add, delete and locked-policy semantics, so architectural, security and coding standards — required TLS versions, required Java versions, operational rules — are injected automatically into every AI-assisted development session.
- Applied Amazon Bedrock AgentCore, Amazon Bedrock, Amazon Q, Kiro, Claude, Cursor, ChatGPT and the OpenAI API across the platform's agent workflows.

**Vector Search, RAG & Retrieval**

- Built a semantic discovery agent on Amazon OpenSearch Serverless with kNN vector search, indexing enterprise standards and engineering artifacts for retrieval-augmented agent reasoning.
- Generated 1024-dimension embeddings with Amazon Bedrock Titan Embeddings v2 and used Claude Sonnet 4 through Bedrock for keyword extraction and content classification.
- Implemented a pluggable vector-store abstraction supporting both a local TF-IDF backend for offline development and the AWS OpenSearch/Bedrock backend for production, selected at runtime via SSM configuration.

**Cloud-Native Engineering on AWS**

- Designed and built Java 17 / Spring Boot microservices deployed to Amazon EKS with Istio service mesh, Helm, ArgoCD GitOps, Sealed Secrets and horizontal pod autoscaling.
- Modelled and delivered the platform's persistence layer on Amazon DocumentDB using materialised, pre-joined documents so read APIs serve without computation at request time.
- Integrated JIRA and GitLab REST APIs from inside a restricted private VPC — the only network path with reach to either system — including paged synchronisation of production deployment tickets and ingestion of ArgoCD production-state manifests across six business domains and four environments.
- Built 32 AWS Lambda functions with EventBridge, SQS, S3, SSM Parameter Store and Secrets Manager, provisioned through Terraform and AWS CDK.
- Delivered a React dashboard on CloudFront and S3 presenting governance verdicts, deployment plans, branch readiness and service dependency views.
- Implemented IRSA-based workload identity, runtime secret retrieval from SSM and Secrets Manager, and GitLab CI/CD pipelines with automated build, container publish and ArgoCD-driven deployment.
- Applied property-based testing (jqwik, Hypothesis) to prove correctness properties rather than example cases, including provability tests that verify a governance rule is structurally capable of failing.

### FFJ Consulting LLC (Client: Fidelity) — St. Louis, MO
**Enterprise Cloud Architect / Principal Engineer** | Apr 2022 – May 2026

**AI-Native Engineering, Agentic Workflows & MCP**

- Established spec-driven AI-assisted development as a repeatable engineering practice using Amazon Kiro, introducing a requirements → design → tasks workflow that converts ad-hoc prompting into reviewable, auditable engineering artifacts.
- Integrated Model Context Protocol (MCP) servers to connect AI agents with development tools, project artifacts, issue trackers, source repositories and enterprise resources — giving engineers governed, tool-mediated access to enterprise systems from inside the IDE rather than through unmanaged prompting.
- Built agentic development workflows using sub-agent delegation, dependency-ordered task execution and event-driven automation hooks, enabling multi-step delivery to run end to end while preserving human approval gates.
- Designed human-in-the-loop engineering automation in which AI proposes changes and developers review and approve them within PR workflows.
- Authored organization-wide steering and standards files that inject architectural, security and coding standards into every AI-assisted session, making standards compliance the default rather than a review-time correction.
- Implemented governance controls for AI-assisted delivery: pre- and post-tool-use authorization hooks, mandatory human approval on destructive operations, provenance tracking on generated artifacts, and enforced automated test coverage on AI-authored code.
- Leveraged MCP-enabled AI workflows for code generation, refactoring, debugging, documentation and architecture analysis while maintaining developer oversight and secure engineering practices.
- Applied agentic AI development patterns across Amazon Kiro, Amazon Bedrock, Amazon Q, GitHub Copilot, Cursor and ChatGPT to accelerate enterprise modernization and reduce manual engineering effort.
- Designed and delivered Retrieval-Augmented Generation (RAG) architectures on AWS using Amazon Q, Amazon Bedrock, SageMaker and LangChain, integrating proprietary enterprise data with large language models for grounded, context-aware responses.
- Built secure enterprise knowledge retrieval over internal corpora, improving response accuracy for business users while keeping proprietary data within controlled AWS boundaries.

**Cloud Modernization & Platform Engineering**

- Lead modernization of legacy enterprise systems into AWS cloud-native services (EKS, Lambda, API Gateway, SQS, EventBridge) and microservices using Python, Java, Spring Boot, .NET, C#, Terraform, CDK, ElastiCache, Kubernetes, Bitbucket and GitHub Actions.
- Drive secure architecture, deployment standards and scalable platform patterns across environments (Kubernetes, Red Hat OpenShift, Karpenter, API Gateway, Apigee); design containerized platform solutions aligned with automated CI/CD and cloud-ready distributed application patterns.
- Led design of AWS-hosted Financial Planning platforms with a focus on scalability and accessibility; applied Textract and Intelligent Document Processing (IDP) for document extraction and automation.
- Defined modernization roadmaps integrating legacy systems with cloud-native services; partnered with stakeholders to drive alignment and adoption.
- Used TypeScript and Svelte/SvelteKit on enterprise web and customer-facing initiatives as part of broader platform modernization and delivery.
- Implemented IdP/SSO integrations (Okta) for authentication and authorization to AWS-based services.
- Delivered Infrastructure as Code using CloudFormation, Terraform, AWS CDK and CDKTF; built proofs of concept for automated AWS tagging with EventBridge.
- Built CI/CD pipelines using GitHub Actions, GitLab CI/CD, Bitbucket, Jenkins, SonarQube, Octopus and env0 for AWS and on‑prem deployments; collaborate in Agile delivery with Jira and standard Scrum practices.
- Monitored and optimized systems using CloudWatch and Trusted Advisor to improve reliability and resource utilization.
- Applied PII and accessibility guidelines and AWS security best practices (IAM, VPC, encryption) in regulated environments; used PostgreSQL, Microsoft SQL Server, MongoDB and Redis/ElastiCache for data and caching layers in containerized (Docker/Kubernetes) services.

### FFJ Consulting LLC (Client: Nike) — St. Louis, MO
**Enterprise Cloud Architect / Senior Developer** | Nov 2019 – Apr 2022

- Delivered AWS modernization solutions using Python, Java, Spring Boot, .NET, C#, Terraform, CDK, EventBridge, Lambda, API Gateway, ElastiCache, EKS, Kubernetes, Bitbucket and GitHub Actions; built containerized and serverless components.
- Used TypeScript and Svelte in project work for modern UI layers and integrations within the AWS modernization program.
- Implemented secure authentication/authorization patterns, Apigee/API Gateway policies and API security best practices.
- Supported enterprise workflows through microservices, RabbitMQ/event-driven processing and scalable integrations; used Jenkins, Bitbucket and SonarQube in CI/CD; deployed services with Docker/Kubernetes; integrated PostgreSQL, MongoDB and Redis/ElastiCache for persistence and caching.

### Connectria — St. Louis, MO
**Senior Full-Stack Developer / Cloud Architect** | Jan 2018 – Jan 2019

- Architected and built cloud-native applications on AWS and Azure using C#/.NET Core, Azure, Kubernetes, API Gateway, SQS and RabbitMQ in microservices patterns.
- Used TypeScript and Svelte in full-stack delivery alongside .NET, Node.js and cloud-native services.
- Delivered Kubernetes-based platforms with Terraform/CloudFormation IaC and Jenkins CI/CD for repeatable deployment pipelines; integrated SonarQube for code quality.
- Developed full-stack solutions using modern UI frameworks and backend services across .NET, Node.js and PostgreSQL; used Docker/Kubernetes for deployment; MongoDB and Redis for data and caching.

### American Fork / Park City, UT
**Senior Full-Stack Developer / Cloud-Native Engineer** | Jan 2017 – Jan 2018

- Designed and built cloud-native microservices in Go, Redis and EKS supporting high availability and distributed workloads on AWS (SQS, API Gateway).
- Implemented Kubernetes/Rancher deployments, Karpenter-style scaling and service configuration/discovery patterns.
- Delivered secure and scalable services using RabbitMQ and event-driven architectures; used Jenkins and SonarQube in CI/CD; Docker/Kubernetes; PostgreSQL and Redis for data and caching.

### Earlier Career (Selected)

*Technologies across these roles: C#/.NET, Java, Python, AWS, Azure, Docker, Kubernetes, EKS, PostgreSQL, MongoDB, Redis, ElastiCache, API Gateway, Apigee, SQS, RabbitMQ, EventBridge, Lambda, Terraform, CDK, Jenkins, GitHub Actions, Bitbucket, SonarQube, microservices, and enterprise integration.*

- **CDK Enterprises** — Senior Full-Stack Developer (Cloud Native / Kubernetes, Helm, AWS) | 2016 – 2017
- **SAIC** — Senior Full-Stack Developer (Cloud Native / Kubernetes, Terraform, AWS) | 2015 – 2016
- **Spectrum Health** — Senior Full-Stack Developer (Microservices, RabbitMQ, Kubernetes, AWS) | 2013 – 2015
- **US Bank** — Senior Full-Stack Developer / Architect (Microservices, API Gateway, event-driven) | 2012 – 2013
- **General Electric (Mayo Clinic IoT)** — Senior Developer (IoT, C#, Azure, AWS, enterprise integration) | 2009 – 2012
- **Boeing** — Senior Developer (Java, Spring Boot, enterprise platforms, messaging) | 2007 – 2009
- **American Family** — Senior Developer (.NET, C#, APIs, integration) | 2005 – 2007
- **Express Scripts** — Senior Developer (C#, SQL Server, enterprise integration) | 2003 – 2005
- **Southwestern Bell** — Developer (C#, Java, enterprise development) | 2000 – 2003

**Healthcare Domain Highlights**

- Led design of AWS-hosted CMS platforms (EKS, API Gateway, Lambda) with a focus on scalability and accessibility; C#/.NET, TypeScript and PostgreSQL.
- Ensured compliance with HIPAA and MARS‑E alongside AWS security best practices (IAM, VPC, encryption) and PII/accessibility guidelines.

---

## EDUCATION

**Washington University in St. Louis, Missouri**
- M.S. Artificial Intelligence
- M.S. Computer Science

---

## CERTIFICATIONS

- AWS Certified Solutions Architect – Associate
- PMP – Project Management Professional
- Scrum Master (Scrum Alliance)
- Oracle SQL / PL/SQL (Oracle Professional)

---

## ADDITIONAL HIGHLIGHTS

- Builds agentic AI systems end to end — agent orchestration, MCP tool integration, vector retrieval and governance controls — rather than consuming AI tools alone.
- Enterprise domain experience across financial services, telecommunications, healthcare and pharmacy/PBM.
- Strong record of modernization, cloud migration patterns and large-scale integration delivery.
- Mainframe background: z/OS, Assembler, COBOL, C, C++, JCL, VSAM, CICS, TCAM, VTAM and operating system services.

---

## Additional Resources

**FFJ Consulting — Cloud and AI Hands-On Architecture**
Visit the website: [https://ffjconsultingllc.com](https://ffjconsultingllc.com)

**AI History, Past and Present**
Read the AI Revolution article: [https://ffjconsultingllc.com/article/ai-revolution-demo](https://ffjconsultingllc.com/article/ai-revolution-demo)

**GitHub Source Code**
View how this website was built: [https://github.com/ffjabbari/FFJ-CONSULTING-LLC](https://github.com/ffjabbari/FFJ-CONSULTING-LLC)
