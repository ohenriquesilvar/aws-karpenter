# Comparação de Autoscalers: Karpenter vs Cluster Autoscaler

## Tabela Comparativa

| Métrica                           | Karpenter       | Cluster Autoscaler   | Diferença        |
| --------------------------------- | --------------- | -------------------- | ---------------- |
| **Nós necessários (30 réplicas)** | 7               | 10                   | -30% (Karpenter) |
| **Densidade máxima (pods/nó)**    | 4.29            | 3.0                  | +43% (Karpenter) |
| **Tempo para primeiro nó (s)**    | 80-81           | 75                   | +7% (CAS)        |
| **Tempo para remover nó (s)**     | 155             | 704                  | -78% (Karpenter) |
| **Duração total do teste (s)**    | 2504            | 2312                 | +8% (CAS)        |
| **Tipos de instâncias**           | m5.large + spot | 4t.medium + 6m.large | Diversificado    |
| **Retorno ao estado inicial**     | Sim (2 nós)     | Sim (2 nós)          | Igual            |

## Comportamento de Escalonamento

### Fase de 5 Réplicas

- **Karpenter**: Adicionou 2 nós (total 4), depois otimizou para 3 nós
- **CAS**: Não adicionou novos nós, usou os 2 nós existentes
- **Vencedor**: CAS (melhor eficiência com recursos existentes)

### Fase de 10 Réplicas

- **Karpenter**: Utilizou 4 nós com densidade de 2.5 pods/nó
- **CAS**: Utilizou 4 nós com densidade de 2.5 pods/nó
- **Vencedor**: Empate (ambos utilizaram os mesmos recursos)

### Fase de 30 Réplicas

- **Karpenter**: Escalonou para 7 nós com densidade de 4.29 pods/nó
- **CAS**: Escalonou para 10 nós com densidade de 3.0 pods/nó
- **Vencedor**: Karpenter (30% menos nós para a mesma carga)

### Fase de Scale-down

- **Karpenter**: Primeira remoção em 155s, duração total de 1153s
- **CAS**: Primeira remoção em 704s, duração total de 1056s
- **Vencedor**: Karpenter (remoção inicial 78% mais rápida)

## Análise de Desempenho

### Velocidade de Resposta

- **Karpenter**: Tempo consistente de 80-81s para provisionamento, independente da carga
- **CAS**: Tempo consistente de 75s para provisionamento, independente da carga
- **Análise**: O CAS foi ligeiramente mais rápido (5-6s) no provisionamento inicial, mas a diferença é marginal (7%)

### Eficiência de Recursos

- **Karpenter**: Maior densidade (4.29 pods/nó) e otimização com instâncias spot
- **CAS**: Menor densidade (3.0 pods/nó) e tipos de instância homogêneos
- **Análise**: Karpenter utiliza 30% menos recursos computacionais para a mesma carga, além de otimizar custo com instâncias spot

### Comportamento de Scale-down

- **Karpenter**: Removeu o primeiro nó em 155s, 78% mais rápido que o CAS
- **CAS**: Demorou 704s para iniciar a remoção de nós
- **Análise**: Karpenter demonstra vantagem significativa na velocidade de liberação de recursos ociosos

### Duração Total

- **Karpenter**: 2504 segundos para o ciclo completo
- **CAS**: 2312 segundos para o ciclo completo
- **Análise**: CAS completou o teste 8% mais rápido, principalmente devido a não escalar na fase inicial

## Principais Diferenças

### Estratégia de Provisionamento

- **Karpenter**:

  - Provisiona diretamente instâncias EC2 (sem grupos de nós)
  - Utiliza uma combinação de instâncias on-demand e spot para otimização de custos
  - Provisiona com base em requisitos exatos dos pods

- **Cluster Autoscaler**:
  - Trabalha com grupos de nós predefinidos
  - Usa tipos homogêneos de instâncias
  - Provisiona com base em templates de grupos de nós

### Consumo de Recursos

- **Karpenter**: Alcançou densidade 43% maior, indicando melhor utilização dos recursos
- **CAS**: Densidade mais baixa, utilizando mais recursos para a mesma carga

### Flexibilidade

- **Karpenter**: Escolhe dinamicamente entre diferentes tipos de instâncias baseado na demanda
- **CAS**: Limitado aos tipos de instâncias definidos nos grupos de nós

## Conclusão

Ambos os autoscalers demonstraram desempenho competente, mas com características distintas:

### Vantagens do Karpenter

- **Economia de recursos**: 30% menos nós para a mesma carga de trabalho
- **Economia de custos**: Uso de instâncias spot para otimização
- **Scale-down rápido**: Liberação de recursos 78% mais rápida
- **Alta densidade**: 43% mais pods por nó
- **Flexibilidade**: Provisiona instâncias específicas para cada carga

### Vantagens do Cluster Autoscaler

- **Provisionamento ligeiramente mais rápido**: 7% mais veloz para escalar
- **Utilização eficiente de recursos existentes**: Não escalou desnecessariamente para 5 réplicas
- **Estabilidade comprovada**: Tecnologia mais madura e amplamente testada
- **Duração total do teste menor**: 8% mais rápido no ciclo completo

### Recomendações

1. **Para workloads com variações frequentes**: Karpenter oferece vantagens claras devido ao scale-down rápido e otimização de recursos.

2. **Para ambientes com foco em custo**: Karpenter apresenta economia significativa através de maior densidade e uso de instâncias spot.

3. **Para cargas previsíveis e estáveis**: CAS pode ser suficiente, especialmente em ambientes onde a estabilidade e previsibilidade são prioritárias.

4. **Para grandes clusters com pods heterogêneos**: Karpenter demonstra vantagens na alocação eficiente de recursos variados.

Os resultados sugerem que o Karpenter representa um avanço importante na tecnologia de autoscaling para Kubernetes, especialmente em ambientes AWS, oferecendo melhor economicidade e eficiência de recursos em troca de uma pequena diferença no tempo de provisionamento inicial.
