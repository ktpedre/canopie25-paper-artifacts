# canopie25-paper-artifacts

This repo contains example run scripts and gnuplot files needed to reproduce results in the following paper:

```
Angel M. Beltre, Jeff Ogden, and Kevin Pedretti. Experience Deploying
Containerized GenAI Services at an HPC Center. In Proceedings of the 7th
International Workshop on Containers and New Orchestration Paradigms for
Isolated Environments in HPC (CANOPIE-HPC), November, 2025.
```

The HPC workflow for deploying vLLM and benchmarking it is located in the "hpc-workflow" directory.

The Kubernetes / OpenShift workflow for deploying vLLM is located in the
"k8s-workflow" directory.  Note that the Helm Chart in the
k8s-workflow/helm-chart directory is derived from the upstream vLLM project
(See "k8s-workflow/helm-chart/README-CANOPIE25.md" for details).

Gnuplot scripts for ploting results in the paper are located in the "plots" directory.
