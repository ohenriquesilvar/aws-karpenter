# AWS EKS com Karpenter

Este projeto implementa um cluster EKS (Elastic Kubernetes Service) na AWS com Karpenter para autoscaling automático de nós. O Karpenter é uma solução de autoscaling que oferece melhor performance e custo-eficiência comparada ao Cluster Autoscaler tradicional.

## Arquitetura

O projeto implementa:

- Cluster EKS com Kubernetes 1.30
- VPC dedicada com subnets públicas e privadas
- NAT Gateway para acesso à internet das subnets privadas
- Karpenter para autoscaling de nós
- Node Pool configurado para usar instâncias EC2 pequenas (t2 e m5)
- SSM para gerenciamento de instâncias

## Pré-requisitos

- Terraform >= 1.0.0
- AWS CLI configurado
- kubectl instalado
- Helm instalado (opcional, para gerenciamento de releases)

## Configuração

1. Clone o repositório:

```bash
git clone https://github.com/ohenriquesilvar/cluster-autoscaler
cd aws-karpenter
```

2. Configure as variáveis necessárias no arquivo `terraform.tfvars`:

```hcl
aws_account_id = "seu-account-id"
cluster_name   = "nome-do-seu-cluster"
region         = "us-east-1"  # ou sua região preferida
environment    = "dev"        # ou "prod", "staging", etc.
```

3. Inicialize o Terraform:

```bash
cd terraform
terraform init
```

4. Revise o plano de execução:

```bash
terraform plan
```

5. Aplique a infraestrutura:

```bash
terraform apply
```

## Variáveis Configuráveis

| Nome                | Descrição                          | Tipo         | Padrão          |
| ------------------- | ---------------------------------- | ------------ | --------------- |
| aws_account_id      | ID da conta AWS                    | string       | -               |
| cluster_name        | Nome do cluster EKS                | string       | -               |
| region              | Região AWS                         | string       | "us-east-1"     |
| vpc_cidr            | CIDR da VPC                        | string       | "10.0.0.0/16"   |
| environment         | Nome do ambiente                   | string       | "dev"           |
| cluster_version     | Versão do Kubernetes               | string       | "1.30"          |
| instance_categories | Categorias de instâncias (t2 e m5) | list(string) | ["t", "m"]      |
| instance_cpu_values | CPUs para instâncias pequenas      | list(string) | ["1", "2", "4"] |
| node_pool_cpu_limit | Limite total de CPUs               | number       | 100             |

## Configuração do Karpenter

O projeto configura o Karpenter com as seguintes características:

- Usa AMI AL2023
- Suporta instâncias t2 (burstable) e m5 (general purpose)
- CPUs de 1 a 4 cores
- Usa instâncias Nitro
- Geração 2 ou superior
- Consolidação automática após 30s de inatividade
- Limite total de 100 CPUs no cluster

### Tipos de Instâncias Suportadas

- **t2**: Instâncias burstable para cargas de trabalho com uso intermitente

  - t2.micro (1 vCPU)
  - t2.small (1 vCPU)
  - t2.medium (2 vCPU)
  - t2.large (2 vCPU)

- **m5**: Instâncias de propósito geral para cargas de trabalho estáveis
  - m5.large (2 vCPU)
  - m5.xlarge (4 vCPU)

## Monitoramento e Manutenção

Para monitorar o cluster e os nós do Karpenter:

1. Configure o kubeconfig:

```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

2. Verifique os nós:

```bash
kubectl get nodes
```

3. Monitore os pods do Karpenter:

```bash
kubectl get pods -n kube-system | grep karpenter
```

## Limpeza

Para remover a infraestrutura:

```bash
terraform destroy
```

**Importante**: Certifique-se de remover todos os recursos Kubernetes antes de destruir a infraestrutura para evitar recursos órfãos.

## Segurança

- O cluster EKS é configurado com acesso público para o endpoint da API
- As subnets dos nós são privadas
- NAT Gateway é usado para acesso à internet
- SSM é habilitado para gerenciamento seguro das instâncias
- IAM roles e policies seguem o princípio do menor privilégio

## Contribuindo

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.
