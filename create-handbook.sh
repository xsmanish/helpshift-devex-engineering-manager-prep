#!/bin/bash
# ====================================================
# create-handbook.sh
# Repository creation script for:
# helpshift-engineering-manager-handbook
# ====================================================

set -e

PROJECT_ROOT="helpshift-engineering-manager-handbook"

echo "Creating $PROJECT_ROOT..."

# Create root directory
mkdir -p "$PROJECT_ROOT"

# Create directory structure
mkdir -p "$PROJECT_ROOT/01-company-profile"
mkdir -p "$PROJECT_ROOT/02-technical-preparation"
mkdir -p "$PROJECT_ROOT/03-management-preparation"
mkdir -p "$PROJECT_ROOT/04-mock-interviews"
mkdir -p "$PROJECT_ROOT/assets/diagrams"
mkdir -p "$PROJECT_ROOT/assets/images"
mkdir -p "$PROJECT_ROOT/assets/notes"

echo "Directory structure created."
echo ""
echo "Next steps:"
echo "1. Copy all markdown files from each section into the corresponding directories."
echo "2. Add .gitignore."
echo "3. Initialize git and push to GitHub."
echo ""
echo "Repository tree:"
echo ""
echo "helpshift-engineering-manager-handbook/"
echo "├── README.md"
echo "├── .gitignore"
echo "├── 01-company-profile/"
echo "│   ├── README.md"
echo "│   ├── 01-company-overview.md"
echo "│   ├── 02-products-customers-competitors.md"
echo "│   ├── 03-engineering-culture-developer-productivity.md"
echo "│   └── 04-why-helpshift-and-role-fit.md"
echo "├── 02-technical-preparation/"
echo "│   ├── README.md"
echo "│   ├── 01-developer-productivity-platform-engineering.md"
echo "│   ├── 02-dora-exdora-space-metrics.md"
echo "│   ├── 03-cicd-build-systems-release-engineering.md"
echo "│   ├── 04-kubernetes-eks-gitops.md"
echo "│   ├── 05-cloud-platform-engineering-aws.md"
echo "│   ├── 06-sre-observability-devsecops.md"
echo "│   ├── 07-system-design-scenarios.md"
echo "│   ├── 08-my-project-stories.md"
echo "│   └── 09-technical-question-bank.md"
echo "├── 03-management-preparation/"
echo "│   ├── README.md"
echo "│   ├── 01-engineering-management-fundamentals.md"
echo "│   ├── 02-leadership-stakeholder-management.md"
echo "│   ├── 03-roadmaps-strategy-execution.md"
echo "│   ├── 04-behavioural-interview-preparation.md"
echo "│   ├── 05-my-leadership-stories.md"
echo "│   ├── 06-first-90-days-plan.md"
echo "│   └── 07-management-question-bank.md"
echo "├── 04-mock-interviews/"
echo "│   ├── 01-technical-mock-interview.md"
echo "│   ├── 02-management-mock-interview.md"
echo "│   ├── 03-hiring-manager-round.md"
echo "│   └── 04-final-revision-cheatsheet.md"
echo "└── assets/"
echo "    ├── diagrams/"
echo "    ├── images/"
echo "    └── notes/"
echo ""
echo "Done."