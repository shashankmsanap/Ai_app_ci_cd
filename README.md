# AI Recording System - Extracting data from the speech | DevOps Implementation

**About Application**: Flask-based AI application that records/processes voice data and stores information in JSON.

**Objectives**: Implement full CI/CD automation for Python based AI app with Github actions, Terraform, Azure , docker ensuring zero-downtime deployments. 

## 🚀 Technical Stack

### Core Application
- **Language**: Python 3.9
- **Libraries**: SpeechRecognition, Flask
- **Data Format**: JSON

**Tech Stack**: 

- Programming        :: Python 3.9 + Flask, 
- Version Control    :: Git, Github
- CI CD              :: GitHub Actions.
- Containerization   :: Docker 
- Infrastructure     :: Terraform (IaC).
- Cloud deployment   :: Azure app service.
- Monitoring         :: Azure Monitor, Network watcher.
- Incident management:: Jira.

**DevOps Pipeline Features**: 

# GitHub Actions Workflow Highlights:
- Parallel test execution
- Terraform plan/apply with approval gates
- Environment-specific deployments

User GitHub Actions → pytest → Terraform Plan (Manual Approval) → Azure App Service Deployment → Automated Infrastructure Provisioning (West Europe).  

**Future Implementation**: 
1. Blue/green deployments
2. Azure Key Vault integration
3. Docker containerization
4. Azure AI Services embedding.
