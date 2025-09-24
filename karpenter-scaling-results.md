# Resultados do Teste de Escalonamento - Karpenter

## Tabela de Dados Agregados

| Métrica                     | 5 Réplicas | 10 Réplicas | 30 Réplicas | Scale-down |
| --------------------------- | ---------- | ----------- | ----------- | ---------- |
| Nós provisionados           | 2          | 1           | 3           | -5         |
| Total de nós                | 4          | 4           | 7           | 2          |
| Tempo primeira resposta (s) | 80         | N/A         | 81          | 155        |
| Densidade (pods/nó)         | 1.25       | 2.5         | 4.29        | 0          |
| Pods em estado pendente     | 5→0        | 3→0         | 20→0        | 0          |
| Duração da fase (s)         | ~394       | ~377        | ~558        | 1153       |

## Resumo do Teste

O teste foi realizado em três fases de escalonamento (5, 10 e 30 réplicas) seguidas por uma fase de redução (scale-down). O Karpenter demonstrou os seguintes comportamentos:

1. **Fase de 5 réplicas**:

   - Adicionou 2 novos nós (tipo spot)
   - Primeiro nó adicionado após 80 segundos
   - Inicialmente 5 pods pendentes até provisionamento de novos nós
   - Estabilizou com 4 nós (2 m5.large + 2 spot), depois otimizou para 3 nós

2. **Fase de 10 réplicas**:

   - Adicionou 1 novo nó (total de 4)
   - Inicialmente 3 pods pendentes até provisionamento completo
   - Densidade de 2.5 pods por nó
   - Todos os pods em execução após 80 segundos

3. **Fase de 30 réplicas**:

   - Adicionou 3 novos nós (total de 7)
   - Resposta rápida com provisionamento de novo nó em 81 segundos
   - 20 pods permaneceram pendentes durante o provisionamento inicial
   - Alcançou alta densidade de 4.29 pods por nó

4. **Fase de redução (scale-down)**:
   - Reduziu de 7 para 2 nós (removeu 5 nós)
   - Primeira remoção ocorreu após 155 segundos
   - Duração total de 1153 segundos para estabilizar em 2 nós

## Métricas Detalhadas

### Tempos de Resposta

- Tempo para provisionar primeiro nó após escalar para 5 réplicas: 80 segundos
- Tempo para provisionar primeiro nó após escalar para 30 réplicas: 81 segundos
- Tempo para primeira remoção de nó: 155 segundos
- Duração total do scale-up: 1329 segundos
- Duração total do scale-down: 1153 segundos
- Duração total do teste: 2504 segundos

### Comportamento de Escala

- Estado inicial: 2 nós (m5.large)
- 5 réplicas: expandiu para 4 nós (2 m5.large + 2 spot), depois otimizou para 3 nós
- 10 réplicas: expandiu para 4 nós
- 30 réplicas: expandiu para 7 nós (2 m5.large + 5 spot)
- Após scale-down: retornou para 2 nós (m5.large)

### Eficiência de Recursos

- Densidade com 5 réplicas: 1.25 pods/nó (inicialmente), 1.67 pods/nó (otimizado)
- Densidade com 10 réplicas: 2.5 pods/nó
- Densidade com 30 réplicas: 4.29 pods/nó
- Densidade após scale-down: 0 pods/nó (escala para 0 réplicas)

### Observações

- O Karpenter utilizou instâncias spot para escalar, demonstrando otimização de custos
- Os tipos de instância foram corretamente identificados como m5.large (nós iniciais) e spot (nós provisionados)
- Resposta consistentemente rápida entre as fases (~80 segundos para provisionamento)
- Capacidade de otimizar recursos durante as fases (consolidação de nós)
- Remoção completa de todos os nós provisionados quando escalonado para zero réplicas

## Conclusão

O Karpenter demonstrou capacidade de escalonamento rápido e eficiente em todos os níveis de carga. Diferente do Cluster Autoscaler, o tempo de resposta permaneceu consistente (80-81s) mesmo com o aumento da carga para 30 réplicas. O scale-down foi mais rápido (1153s vs 1415s do Cluster Autoscaler), com a primeira remoção ocorrendo em 155 segundos.

O Karpenter também mostrou melhor eficiência de recursos, alcançando maior densidade de pods por nó (4.29 na fase de 30 réplicas) e usando uma combinação de instâncias on-demand (m5.large) e spot para otimizar custos. A capacidade de escalonar para 30 réplicas com apenas 7 nós (vs. 11 nós para o Cluster Autoscaler) demonstra melhor utilização dos recursos.

A duração total do teste foi significativamente mais curta (2504s vs. 3757s para o Cluster Autoscaler), indicando maior eficiência nos ciclos de provisionamento e desprovisionamento de recursos. Para cargas de trabalho com variações frequentes, o Karpenter oferece vantagens claras em termos de velocidade de resposta e eficiência de custos.

Destaca-se também a capacidade do Karpenter em remover completamente os recursos quando não há demanda, retornando ao estado inicial de 2 nós, maximizando a economia de custos em ambientes de produção.
