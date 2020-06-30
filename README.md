# CONFIGURAÇÃO AWS CLUSTER EKS

## Pré-requisitos:

- *aws cli*:
```
  https://docs.aws.amazon.com/pt_br/cli/latest/userguide/install-linux-al2017.html
```

- *kubectl*:
```
  https://docs.aws.amazon.com/pt_br/eks/latest/userguide/install-kubectl.html
```

- *aws-iam-authenticator*:
```
  https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
```  

- *Getting-started-with-eksctl*
```
  https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html
```

- *Python versão > `2.9.3`*:
```
  https://realpython.com/installing-python/
```
-----------------------------------------------------------------------------

## Criar uma policy com as seguinte permissões para administração do cluster EKS:

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeInstances",
                "ec2:CreateNatGateway",
                "ec2:CreateRoute",
                "ec2:CreateSecurityGroup",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:DescribeRouteTables",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:DescribeKeyPairs",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:TerminateInstances",
                "ec2:CreateTags",
                "ec2:DeleteRoute",
                "ec2:RunInstances",
                "ec2:DescribeNatGateways",
                "ec2:DescribeSecurityGroups",
                "ec2:DeleteNatGateway",
                "ec2:DescribeNetworkInterfaces"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "eksAccess",
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "ecr:*",
                "s3:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "LogsAccess",
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogGroups",
                "logs:CreateLogGroup",
                "logs:DeleteLogGroup"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:GetHostedZone",
                "route53:GetChange"
            ],
            "Resource": [
                "arn:aws:route53:::hostedzone/*",
                "arn:aws:route53:::change/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets",
                "route53:AssociateVPCWithHostedZone"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:CreateInstanceProfile",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:DeleteRole",
                "iam:DetachRolePolicy",
                "iam:AttachRolePolicy",
                "iam:DeleteRolePolicy",
                "iam:PutRolePolicy",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:UntagRole",
                "iam:TagRole"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:AddTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DeleteScalingGroup",
                "autoscaling:DeleteAutoScalingGroup",
                "autoscaling:DescribeAutoScalingInstances"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CreateLaunchConfiguration",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:DeleteLaunchConfiguration"
            ],
            "Resource": [
                "arn:aws:autoscaling:us-east-1:000000000000:autoScalingGroup:*:autoScalingGroupName/*",
                "arn:aws:autoscaling:us-east-1:000000000000:launchConfiguration:*:launchConfigurationName/*}",
                "arn:aws:autoscaling:*:*:autoScalingGroupName/*}"
            ]
        }
    ]
}
```
-----------------------------------------------------------------------------

## Criar um usuario (eksadmin) para administração do cluster eks e atachar a policy criada no passo anterior.

*Configurar o profile AWS para utilizar o usuario eksadmin, criado no passo anterior.*

Para confirmar o usuário que está configurado, utilize o comando:

```
  aws sts get-caller-identity

  {
    "UserId": "XXXXXXXXXXXXXXXXXXXXX",
    "Account": "000000000000",
    "Arn": "arn:aws:iam::000000000000:user/eksadmin"
}
```

-----------------------------------------------------------------------------

## AJUSTAR AS CONFIGURAÇÕES DE ACORDO COM O AMBIENTE E ORGANIZAÇÃO:

`1)` No arquivo `cluster-prd.yml`, informar o nome da VPC criada anteriormente, conforme exemplo abaixo:

```
vpc:
  subnets:
    private:
      us-east-1a: { id: subnet-<ID> }
      us-east-1b: { id: subnet-<ID> }
      us-east-1c: { id: subnet-<ID> }
```

`OBS:` Caso não exista é necessário criar uma VPC e suas subnets antes.

`2)` No arquivo `cluster-prd.yml`, informar o nome da key criada anteriormente, conforme exemplo abaixo:

```
    ssh:
      allow: true
      publicKeyName: "key-cluster-prd"
```

`OBS:` Caso não exista é necessário criar uma ssh-key antes.


-----------------------------------------------------------------------------

## CONFIGURANDO K8S EXISTENTE NO GITLAB-RUNNER

Siga as orientacoes para configurar um `runner` para o o projeto em:

```
    https://gitlab.com/help/user/project/clusters/add_remove_clusters#add-existing-cluster
```

- *TAGS*: 

A tag do k8s utilizado neste projeto esta no arquivo `.gitlab-ci.yml`, conforme exemplo abaixo:

```
  tags:
    - backend-services-shell-01    

```

`OBS:` Necessario configurar o runner para o projeto antes de executar, caso nao exista um runner com a tag
`backend-services-shell-01` disponivel, o projeto ficara eternamente no status de `pending` para mais informacoes,
verificar documentacao mencionada anterirmente.

## APLICANDO AS CREDENCIAIS NO CLIENT ELK

Ao aplicar o stage `k8s-deploy-monit-core` e antes de seguir com o proximo stage em sua pipeline no gitlab,
acesse o cliente (que ja foi provisionado no nosso cluster) atravez do kubectl de modo interativo,
aplique as credenciais para o Kibana com o seguinte comando:

```
kubectl exec -ti $(kubectl get pod -n monitoring | grep elasticsearch-client | sed -n 1p | awk '{print $1}') -n monitoring -- bin/elasticsearch-setup-passwords interactive
```

Credenciais estao em `0.2.0-eck/.secrets/.elk-pw-prd-credentials.yaml`


`OBS:` Necessario instalar o gawk caso esteja rodando o kubectl no MacOs em:
```
    https://brewinstall.org/Install-gawk-on-Mac-with-Brew/
```


-----------------------------------------------------------------------------
# Tasklists


| TASK                                                       |   STATUS     |
|------------------------------------------------------------|--------------|
| Implementar CI/CD Gitlab                                   |     OK       |
| Implementar Aplicacao VOTE                                 |     OK       |
| Implementar Elasticsearch-master                           |     OK       |
| Implementar Elasticsearch-client                           |     OK       |
| Implementar Elasticsearch-data                             |     OK       |
| Implementar Metricbeats                                    |     OK       |
| Implementar Filebeats                                      |     OK       |
| Implementar Heartbeat                                      |     OK       |
| Implementar Logstash                                       |     OK       |
| Implementar APM                                            |     OK       |
| Implementar Index Life lifecycle management                |     OK       |
| Implementar Grafana                                        |     OK       |
| Implementar Prometheus                                     |     OK       |
| Implementar Work nodes spot instances - Auto scaling group |     OK       |
| Implementar Work nodes spot instances - Lounch config      |     OK       |

-----------------------------------------------------------------------------
## TROUBLESHOOTING



-----------------------------------------------------------------------------

